"
I check `BpFillBetween`, as `BpChart>>fillBetweenX:y1:y2:` and `BpChart>>fillBetweenY:x1:x2:` create it: the vertices of the polygons (including the regions selected by where, the interpolated crossings and the three step styles), the broadcasting of single values, horizontal fills, colors and outlines, the legend entry and the colors of the palette.

## Implementation Notes

- My fixture fills between y1 = 1, 3, 2, 4 and 0 at x = 0, 1, 2, 3. Fractions keep the expected vertices exact.
- The fill is not in a figure: the polygons are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpFillBetweenTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpFillBetweenTest >> crossing [
	"The curves of the gallery 'Selectively filling horizontal regions': y1 = 0.8, 0.8, 0.2, 0.2 and y2 = 0, 0, 1, 1 cross between x = 1 and 2."

	^ BpFillBetween new
		  x: #( 0 1 2 3 ) y1: {
			  (4 / 5).
			  (4 / 5).
			  (1 / 5).
			  (1 / 5) }
		  y2: #( 0 0 1 1 );
		  where: #( true true false false );
		  yourself
]

{ #category : 'tests' }
BpFillBetweenTest >> fill [
	"The area between y1 = 1, 3, 2, 4 and 0, at x = 0, 1, 2, 3."

	^ BpFillBetween new
		  x: #( 0 1 2 3 ) y1: #( 1 3 2 4 ) y2: 0;
		  yourself
]

{ #category : 'tests' }
BpFillBetweenTest >> steps: aSymbol [

	^ (BpFillBetween new
		   x: #( 0 1 2 ) y1: #( 1 2 3 ) y2: 0;
		   step: aSymbol;
		   yourself) patches first dataVertices
]

{ #category : 'tests' }
BpFillBetweenTest >> testAlphaMakesTheFillTransparent [

	self assert: ((self fill
		  alpha: 0.3;
		  yourself) patches first background paint color alpha closeTo: 0.3 precision: 0.01)
]

{ #category : 'tests' }
BpFillBetweenTest >> testChartFillBetweenXY1FillsDownToZero [

	| chart fill |
	chart := BpChart new.
	fill := chart fillBetweenX: #( 0 1 ) y1: #( 2 3 ).
	self assert: (chart artists includes: fill).
	self assert: fill patches first dataVertices first equals: 0 @ 0
]

{ #category : 'tests' }
BpFillBetweenTest >> testChartFillBetweenYX1X2FillsHorizontally [

	| fill |
	fill := BpChart new fillBetweenY: #( 0 1 ) x1: 0 x2: #( 2 3 ).
	self assert: fill orientation equals: #horizontal.
	self assert: fill patches first dataVertices second equals: 0 @ 0.
	self assert: fill patches first dataVertices fourth equals: 3 @ 1
]

{ #category : 'tests' }
BpFillBetweenTest >> testColorSetsTheFillAndTheOutline [

	| polygon |
	polygon := (self fill color: (BpPalette default colorAt: 4);
		            yourself) patches first.
	self assert: polygon background paint color equals: (BpPalette default colorAt: 4).
	self assert: polygon border paint color equals: (BpPalette default colorAt: 4)
]

{ #category : 'tests' }
BpFillBetweenTest >> testEdgeColorAndLineWidthOutlineTheFill [

	| polygon |
	polygon := (self fill edgeColor: Color black;
		            lineWidth: 2;
		            yourself) patches first.
	self assert: polygon border paint color equals: Color black.
	self assert: (polygon border width closeTo: 2 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpFillBetweenTest >> testFaceColorSetsOnlyTheFill [

	| polygon |
	polygon := (self fill faceColor: (BpPalette default colorAt: 4);
		            yourself) patches first.
	self assert: polygon background paint color equals: (BpPalette default colorAt: 4).
	self assert: polygon border width equals: 0
]

{ #category : 'tests' }
BpFillBetweenTest >> testFillHasNoOutlineByDefault [

	self assert: self fill patches first border width equals: 0
]

{ #category : 'tests' }
BpFillBetweenTest >> testFillIsBelowTheGrid [

	self deny: self fill isAboveGrid
]

{ #category : 'tests' }
BpFillBetweenTest >> testFillTakesTheNextColorOfTheCycle [

	| chart |
	chart := BpChart new.
	chart addArtist: (BpLine x: #( 0 1 ) y: #( 0 1 )).
	self assert: (chart fillBetweenX: #( 0 1 ) y1: #( 1 2 )) patches first background paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests' }
BpFillBetweenTest >> testHandlersAreKeptWhenTheFillIsRebuilt [

	| fill clicked |
	fill := self fill.
	clicked := nil.
	fill whenPatch: BlClickEvent do: [ :event :polygon | clicked := polygon ].
	fill color: (BpPalette default colorAt: 4).
	BlEvent fireEvent: BlClickEvent new target: fill patches first.
	self assert: clicked identicalTo: fill patches first
]

{ #category : 'tests' }
BpFillBetweenTest >> testHorizontalSwapsTheCoordinates [

	self
		assert: (BpFillBetween new
			 x: #( 0 1 ) y1: #( 2 3 ) y2: 0;
			 orientation: #horizontal;
			 yourself) patches first dataVertices
		equals: {
			(0 @ 0).
			(2 @ 0).
			(3 @ 1).
			(0 @ 1).
			(0 @ 1).
			(0 @ 0) }
]

{ #category : 'tests' }
BpFillBetweenTest >> testInterpolateEndsTheRegionWhereTheCurvesCross [

	self
		assert: (self crossing
			 interpolate: true;
			 yourself) patches first dataVertices
		equals: {
			(0 @ (4 / 5)).
			(0 @ (4 / 5)).
			(1 @ (4 / 5)).
			(3 / 2 @ (1 / 2)).
			(1 @ 0).
			(0 @ 0) }
]

{ #category : 'tests' }
BpFillBetweenTest >> testInterpolateStartsTheRegionWhereTheCurvesCross [

	self
		assert: (self crossing
			 where: #( false false true true );
			 interpolate: true;
			 yourself) patches first dataVertices
		equals: {
			(3 / 2 @ (1 / 2)).
			(2 @ (1 / 5)).
			(3 @ (1 / 5)).
			(3 @ (1 / 5)).
			(3 @ 1).
			(2 @ 1) }
]

{ #category : 'tests' }
BpFillBetweenTest >> testLabelGivesALegendEntry [

	self
		assert: ((self fill
			  label: 'area';
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'area' )
]

{ #category : 'tests' }
BpFillBetweenTest >> testLineWidthZeroRemovesTheOutline [

	self
		assert: (self fill color: (BpPalette default colorAt: 4);
			 lineWidth: 0;
			 yourself) patches first border width
		equals: 0
]

{ #category : 'tests' }
BpFillBetweenTest >> testNoLabelGivesNoLegendEntry [

	self assert: self fill legendEntries isEmpty
]

{ #category : 'tests' }
BpFillBetweenTest >> testOneRegionByDefault [

	self assert: self fill patches size equals: 1
]

{ #category : 'tests' }
BpFillBetweenTest >> testPolygonGoesAlongY1AndBackAlongY2 [

	self assert: self fill patches first dataVertices equals: {
		(0 @ 0).
		(0 @ 1).
		(1 @ 3).
		(2 @ 2).
		(3 @ 4).
		(3 @ 0).
		(3 @ 0).
		(2 @ 0).
		(1 @ 0).
		(0 @ 0) }
]

{ #category : 'tests' }
BpFillBetweenTest >> testPolygonsAreClosed [

	self assert: self fill patches first isClosed
]

{ #category : 'tests' }
BpFillBetweenTest >> testStepMidChangesHalfwayBetweenTheXs [

	self assert: (self steps: #mid) equals: {
		(0 @ 0).
		(0 @ 1).
		(1 / 2 @ 1).
		(1 / 2 @ 2).
		(3 / 2 @ 2).
		(3 / 2 @ 3).
		(2 @ 3).
		(2 @ 0).
		(2 @ 0).
		(3 / 2 @ 0).
		(3 / 2 @ 0).
		(1 / 2 @ 0).
		(1 / 2 @ 0).
		(0 @ 0) }
]

{ #category : 'tests' }
BpFillBetweenTest >> testStepPostHoldsEachValueAfterItsX [

	self assert: (self steps: #post) equals: {
		(0 @ 0).
		(0 @ 1).
		(1 @ 1).
		(1 @ 2).
		(2 @ 2).
		(2 @ 3).
		(2 @ 0).
		(2 @ 0).
		(2 @ 0).
		(1 @ 0).
		(1 @ 0).
		(0 @ 0) }
]

{ #category : 'tests' }
BpFillBetweenTest >> testStepPreHoldsEachValueBeforeItsX [

	self assert: (self steps: #pre) equals: {
		(0 @ 0).
		(0 @ 1).
		(0 @ 2).
		(1 @ 2).
		(1 @ 3).
		(2 @ 3).
		(2 @ 0).
		(2 @ 0).
		(1 @ 0).
		(1 @ 0).
		(0 @ 0).
		(0 @ 0) }
]

{ #category : 'tests - errors' }
BpFillBetweenTest >> testUnknownOrientationRaisesError [

	self should: [ self fill orientation: #diagonal ] raise: Error
]

{ #category : 'tests - errors' }
BpFillBetweenTest >> testUnknownStepRaisesError [

	self should: [ self fill step: #middle ] raise: Error
]

{ #category : 'tests' }
BpFillBetweenTest >> testWhereFalseEverywhereFillsNothing [

	self assert: (self fill
		 where: #( false false false false );
		 yourself) patches isEmpty
]

{ #category : 'tests - errors' }
BpFillBetweenTest >> testWhereOfAnotherSizeRaisesError [

	self should: [ self fill where: #( true false ) ] raise: Error
]

{ #category : 'tests' }
BpFillBetweenTest >> testWhereSplitsTheFillIntoRegions [

	| patches |
	patches := (self fill
		            where: #( true true false true );
		            yourself) patches.
	self assert: patches size equals: 2.
	self assert: patches second dataVertices equals: {
		(3 @ 0).
		(3 @ 4).
		(3 @ 0).
		(3 @ 0) }
]

{ #category : 'tests' }
BpFillBetweenTest >> testWithoutInterpolationARegionEndsOnItsLastSelectedX [

	self assert: self crossing patches first dataVertices equals: {
		(0 @ 0).
		(0 @ (4 / 5)).
		(1 @ (4 / 5)).
		(1 @ 0).
		(1 @ 0).
		(0 @ 0) }
]

{ #category : 'tests - errors' }
BpFillBetweenTest >> testY1OfAnotherSizeRaisesError [

	self should: [ BpFillBetween new x: #( 0 1 2 ) y1: #( 1 2 ) y2: 0 ] raise: Error
]

{ #category : 'tests' }
BpFillBetweenTest >> testY2CanBeACurve [

	self
		assert: (BpFillBetween new
			 x: #( 0 1 ) y1: #( 2 3 ) y2: #( 1 -1 );
			 yourself) patches first dataVertices
		equals: {
			(0 @ 1).
			(0 @ 2).
			(1 @ 3).
			(1 @ -1).
			(1 @ -1).
			(0 @ 1) }
]
