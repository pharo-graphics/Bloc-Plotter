"
I test `BpLine`: its line and markers, the matplotlib defaults of widths, sizes and colors, the dashes of the line styles, matplotlib format strings and their errors, and legend entries.
"
Class {
	#name : 'BpLineTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpLineTest >> line [

	^ BpLine x: #( 0 1 2 ) y: #( 0 1 4 )
]

{ #category : 'tests' }
BpLineTest >> ppp [

	^ BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpLineTest >> testAlphaMakesTheLineTransparent [

	self assert: ((self line
		  alpha: 0.5;
		  yourself) linePatch border paint color alpha closeTo: 0.5 precision: 0.01)
]

{ #category : 'tests' }
BpLineTest >> testColorAcceptsMatplotlibNames [

	self
		assert: (self line
			 color: 'r';
			 yourself) linePatch border paint color
		equals: (BpColors named: 'r')
]

{ #category : 'tests' }
BpLineTest >> testDashesGrowWithTheLineWidthAsInMatplotlib [

	self
		assert: (self line
			 lineStyle: #dashed;
			 lineWidth: 2;
			 yourself) linePatch border style dashArray
		equals: {
			(3.7 * 2 * self ppp).
			(1.6 * 2 * self ppp) }
]

{ #category : 'tests' }
BpLineTest >> testDefaultColorIsTheFirstColorOfTheCycle [

	self assert: self line linePatch border paint color equals: BpColors tab10 first
]

{ #category : 'tests' }
BpLineTest >> testDefaultLineWidthIsOneAndAHalfPoints [

	self assert: (self line linePatch border width closeTo: 1.5 * self ppp)
]

{ #category : 'tests' }
BpLineTest >> testDefaultMarkerEdgeWidthIsOnePoint [

	self assert: ((self line
		  marker: 'o';
		  yourself) markerPatches first border width closeTo: self ppp)
]

{ #category : 'tests' }
BpLineTest >> testDefaultMarkerSizeIsSixPoints [

	self
		assert: (self line
			 marker: 'o';
			 yourself) markerPatches first area
		equals: 36
]

{ #category : 'tests - format' }
BpLineTest >> testFormatColorOnlyKeepsTheSolidLine [

	| line |
	line := self line
		        format: 'r';
		        yourself.
	self assert: line linePatch border style dashArray isEmpty.
	self assert: line markerPatches isEmpty
]

{ #category : 'tests - format' }
BpLineTest >> testFormatCycleColor [

	self
		assert: (self line
			 format: 'C1';
			 yourself) linePatch border paint color
		equals: BpColors tab10 second
]

{ #category : 'tests - format' }
BpLineTest >> testFormatDashedLine [

	| line |
	line := self line
		        format: 'k--';
		        yourself.
	self assert: line linePatch border paint color equals: (BpColors named: 'k').
	self assert: line linePatch border style dashArray size equals: 2
]

{ #category : 'tests - format' }
BpLineTest >> testFormatFullColorName [

	self
		assert: (self line
			 format: 'tan';
			 yourself) linePatch border paint color
		equals: (BpColors named: 'tan')
]

{ #category : 'tests - format' }
BpLineTest >> testFormatInAnyOrder [

	| line |
	line := self line
		        format: '^k:';
		        yourself.
	self assert: line markerPatches first marker vertices size equals: 3.
	self assert: line linePatch border paint color equals: (BpColors named: 'k')
]

{ #category : 'tests - format' }
BpLineTest >> testFormatReadsDashDotBeforeDash [

	self
		assert: (self line
			 format: '-.';
			 yourself) linePatch border style dashArray size
		equals: 4
]

{ #category : 'tests - format' }
BpLineTest >> testFormatWithAMarkerOnlyDrawsNoLine [

	| line |
	line := self line
		        format: 'ro';
		        yourself.
	self assert: line linePatch isNil.
	self assert: line markerPatches first background paint color equals: (BpColors named: 'r')
]

{ #category : 'tests - format' }
BpLineTest >> testFormatWithMarkerAndLine [

	| line |
	line := self line
		        format: 'o-';
		        yourself.
	self assert: line linePatch isNotNil.
	self assert: line markerPatches size equals: 3
]

{ #category : 'tests' }
BpLineTest >> testLabelGivesALegendEntry [

	self
		assert: ((self line
			  label: 'model';
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'model' )
]

{ #category : 'tests' }
BpLineTest >> testLinePatchGoesThroughThePoints [

	self assert: self line linePatch dataVertices equals: {
		(0 @ 0).
		(1 @ 1).
		(2 @ 4) }
]

{ #category : 'tests' }
BpLineTest >> testLineStyleAcceptsMatplotlibStrings [

	| dashed |
	dashed := self line
		          lineStyle: '--';
		          yourself.
	self assert: dashed linePatch border style dashArray equals: (self line
		 lineStyle: #dashed;
		 yourself) linePatch border style dashArray
]

{ #category : 'tests' }
BpLineTest >> testLineStyleNoneDrawsOnlyTheMarkers [

	| line |
	line := self line
		        marker: 'o';
		        lineStyle: #none;
		        yourself.
	self assert: line linePatch isNil.
	self assert: line markerPatches size equals: 3
]

{ #category : 'tests' }
BpLineTest >> testLineWidthIsInPoints [

	self assert: ((self line
		  lineWidth: 2;
		  yourself) linePatch border width closeTo: 2 * self ppp)
]

{ #category : 'tests' }
BpLineTest >> testMarkerAddsOnePatchPerPoint [

	self
		assert: ((self line
			  marker: 'o';
			  yourself) markerPatches collect: [ :each | each dataPoint ] as: Array)
		equals: {
			(0 @ 0).
			(1 @ 1).
			(2 @ 4) }
]

{ #category : 'tests' }
BpLineTest >> testMarkerColorsCanBeGiven [

	| marker |
	marker := (self line
		           marker: 'o';
		           markerFaceColor: 'w';
		           markerEdgeColor: 'k';
		           yourself) markerPatches first.
	self assert: marker background paint color equals: (BpColors named: 'w').
	self assert: marker border paint color equals: (BpColors named: 'k')
]

{ #category : 'tests' }
BpLineTest >> testMarkerEdgeWidthIsInPoints [

	self assert: ((self line
		  marker: 'x';
		  markerEdgeWidth: 2;
		  yourself) markerPatches first border width closeTo: 2 * self ppp)
]

{ #category : 'tests' }
BpLineTest >> testMarkerSizeIsInPoints [

	self
		assert: (self line
			 marker: 'o';
			 markerSize: 10;
			 yourself) markerPatches first area
		equals: 100
]

{ #category : 'tests' }
BpLineTest >> testMarkersTakeTheColorOfTheLine [

	| marker |
	marker := (self line
		           color: 'g';
		           marker: 's';
		           yourself) markerPatches first.
	self assert: marker background paint color equals: (BpColors named: 'g').
	self assert: marker border paint color equals: (BpColors named: 'g')
]

{ #category : 'tests' }
BpLineTest >> testNoMarkersByDefault [

	self assert: self line markerPatches isEmpty
]

{ #category : 'tests' }
BpLineTest >> testPatchesAreTheLineThenTheMarkers [

	| line |
	line := self line
		        marker: 'o';
		        yourself.
	self assert: line patches asArray equals: { line linePatch } , line markerPatches asArray
]

{ #category : 'tests - format' }
BpLineTest >> testSettersAfterTheFormatWin [

	self
		assert: (self line
			 format: 'r--';
			 color: 'b';
			 yourself) linePatch border paint color
		equals: (BpColors named: 'b')
]

{ #category : 'tests' }
BpLineTest >> testSolidLineHasNoDashes [

	self assert: self line linePatch border style dashArray isEmpty
]

{ #category : 'tests - errors' }
BpLineTest >> testUnknownFormatCharacterRaisesError [

	self should: [ self line format: 'rz' ] raise: Error
]

{ #category : 'tests - errors' }
BpLineTest >> testUnknownLineStyleRaisesError [

	self should: [ self line lineStyle: #wavy ] raise: Error
]

{ #category : 'tests - errors' }
BpLineTest >> testXAndYOfDifferentSizesRaiseError [

	self should: [ BpLine x: #( 1 2 ) y: #( 1 ) ] raise: Error
]
