"
I check `BpStemPlot`: the stems from the bottom to the heads, the markers on the heads, the baseline across the locations, the default colors and widths, the three format strings, horizontal stems, the legend entry and the color cycle left untouched.

## Implementation Notes

- My fixture has three stems at 1, 2 and 3, with heads 4, -1 and 2.
- The stem plot is not in a figure: the parts are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpStemPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpStemPlotTest >> ppp [

	^ BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpStemPlotTest >> stems [
	"Three stems at 1, 2 and 3, with heads 4, -1 and 2."

	^ BpStemPlot new
		  locations: #( 1 2 3 ) heads: #( 4 -1 2 );
		  yourself
]

{ #category : 'tests' }
BpStemPlotTest >> testAxesStemLocationsHeadsAddsAStemPlot [

	| axes stems |
	axes := BpAxes new.
	stems := axes stemLocations: #( 1 2 ) heads: #( 3 4 ).
	self assert: stems axes identicalTo: axes.
	self assert: (axes artists includes: stems).
	self assert: stems markerLine size equals: 2
]

{ #category : 'tests' }
BpStemPlotTest >> testBaseFormatStylesTheBaseline [

	| baseline |
	baseline := (self stems
		             baseFormat: 'k:';
		             yourself) baseLine.
	self assert: baseline border paint color equals: (BpColors named: 'k').
	self deny: baseline border style dashArray isEmpty
]

{ #category : 'tests' }
BpStemPlotTest >> testBaselineJoinsTheFirstAndTheLastLocations [

	self assert: self stems baseLine dataVertices equals: {
		(1 @ 0).
		(3 @ 0) }
]

{ #category : 'tests' }
BpStemPlotTest >> testBlankBaseFormatHidesTheBaseline [

	| stems |
	stems := self stems
		         baseFormat: ' ';
		         yourself.
	self assert: stems baseLine isNil.
	self assert: stems patches size equals: 6
]

{ #category : 'tests' }
BpStemPlotTest >> testBottomMovesTheStemsAndTheBaseline [

	| stems |
	stems := self stems
		         bottom: 1;
		         yourself.
	self assert: stems stemLines first dataVertices equals: {
		(1 @ 1).
		(1 @ 4) }.
	self assert: stems baseLine dataVertices equals: {
		(1 @ 1).
		(3 @ 1) }
]

{ #category : 'tests' }
BpStemPlotTest >> testDefaultBaselineIsC3 [

	self assert: self stems baseLine border paint color equals: (BpColors named: 'C3')
]

{ #category : 'tests' }
BpStemPlotTest >> testDefaultSizes [

	| stems |
	stems := self stems.
	self assert: (stems stemLines first border width closeTo: 1.5 * self ppp).
	self assert: (stems baseLine border width closeTo: 1.5 * self ppp).
	self assert: stems markerLine first area equals: 36
]

{ #category : 'tests' }
BpStemPlotTest >> testDefaultStemsAndMarkersAreC0Circles [

	| stems marker |
	stems := self stems.
	marker := stems markerLine first.
	self assert: stems stemLines first border paint color equals: BpColors tab10 first.
	self assert: marker background paint color equals: BpColors tab10 first.
	self assert: marker marker isCircle
]

{ #category : 'tests' }
BpStemPlotTest >> testHandlersAreKeptWhenTheStemsAreRebuilt [

	| stems clicked |
	stems := self stems.
	clicked := nil.
	stems whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	stems lineFormat: 'r'.
	BlEvent fireEvent: BlClickEvent new target: stems markerLine second.
	self assert: clicked identicalTo: stems markerLine second
]

{ #category : 'tests' }
BpStemPlotTest >> testHeadsAloneAreLocatedFromZero [

	self
		assert: ((BpStemPlot new
			  heads: #( 5 6 );
			  yourself) markerLine collect: [ :each | each dataPoint ] as: Array)
		equals: {
			(0 @ 5).
			(1 @ 6) }
]

{ #category : 'tests' }
BpStemPlotTest >> testHorizontalSwapsTheCoordinates [

	| stems |
	stems := self stems
		         orientation: #horizontal;
		         yourself.
	self assert: stems stemLines first dataVertices equals: {
		(0 @ 1).
		(4 @ 1) }.
	self assert: stems baseLine dataVertices equals: {
		(0 @ 1).
		(0 @ 3) }
]

{ #category : 'tests' }
BpStemPlotTest >> testLabelGivesALegendEntry [

	self
		assert: ((self stems
			  label: 'data';
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'data' )
]

{ #category : 'tests' }
BpStemPlotTest >> testLineFormatCanBeAColorName [

	self
		assert: (self stems
			 lineFormat: 'grey';
			 yourself) stemLines first border paint color
		equals: (BpColors named: 'grey')
]

{ #category : 'tests' }
BpStemPlotTest >> testLineFormatStylesTheStemsAndColorsTheMarkers [

	| stems |
	stems := self stems
		         lineFormat: 'r--';
		         yourself.
	self assert: stems stemLines first border paint color equals: (BpColors named: 'r').
	self deny: stems stemLines first border style dashArray isEmpty.
	self assert: stems markerLine first background paint color equals: (BpColors named: 'r')
]

{ #category : 'tests - errors' }
BpStemPlotTest >> testLocationsAndHeadsOfDifferentSizesRaiseError [

	self should: [ BpStemPlot new locations: #( 1 2 3 ) heads: #( 1 2 ) ] raise: Error
]

{ #category : 'tests' }
BpStemPlotTest >> testMarkerFaceColorNoneMakesHollowMarkers [

	| marker |
	marker := (self stems
		           markerFaceColor: 'none';
		           yourself) markerLine first.
	self assert: marker background paint color equals: Color transparent.
	self assert: marker border paint color equals: BpColors tab10 first
]

{ #category : 'tests' }
BpStemPlotTest >> testMarkerFormatGivesMarkerAndColor [

	| marker |
	marker := (self stems
		           markerFormat: 'gD';
		           yourself) markerLine first.
	self assert: marker marker vertices size equals: 4.
	self assert: marker background paint color equals: (BpColors named: 'g')
]

{ #category : 'tests' }
BpStemPlotTest >> testMarkersAreOnTheHeads [

	self assert: (self stems markerLine collect: [ :each | each dataPoint ] as: Array) equals: {
		(1 @ 4).
		(2 @ -1).
		(3 @ 2) }
]

{ #category : 'tests' }
BpStemPlotTest >> testNoLabelGivesNoLegendEntry [

	self assert: self stems legendEntries isEmpty
]

{ #category : 'tests' }
BpStemPlotTest >> testOneStemAndOneMarkerPerHead [

	| stems |
	stems := self stems.
	self assert: stems stemLines size equals: 3.
	self assert: stems markerLine size equals: 3
]

{ #category : 'tests' }
BpStemPlotTest >> testPartsAreDrawnStemsMarkersThenBaseline [

	| stems |
	stems := self stems.
	self assert: stems patches asArray equals: stems stemLines asArray , stems markerLine asArray , { stems baseLine }
]

{ #category : 'tests' }
BpStemPlotTest >> testStemGoesFromTheBottomToItsHead [

	self assert: self stems stemLines second dataVertices equals: {
		(2 @ 0).
		(2 @ -1) }
]

{ #category : 'tests' }
BpStemPlotTest >> testStemsAreAboveTheGrid [

	self assert: self stems isAboveGrid
]

{ #category : 'tests' }
BpStemPlotTest >> testStemsTakeNoColorOfTheCycle [

	| axes |
	axes := BpAxes new.
	axes stem: #( 1 2 ).
	self assert: (axes plotX: #( 1 2 ) y: #( 1 2 )) linePatch border paint color equals: BpColors tab10 first
]

{ #category : 'tests - errors' }
BpStemPlotTest >> testUnknownFormatCharacterRaisesError [

	self should: [ self stems lineFormat: 'q' ] raise: Error
]

{ #category : 'tests - errors' }
BpStemPlotTest >> testUnknownOrientationRaisesError [

	self should: [ self stems orientation: #diagonal ] raise: Error
]
