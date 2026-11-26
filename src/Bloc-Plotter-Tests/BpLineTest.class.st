"
I test `BpLine`: its line and markers, the default widths, sizes and colors, the dashes of the line styles, format strings and their errors, and legend entries.
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

{ #category : 'tests - style' }
BpLineTest >> testAlphaKeepsATransparentColorTransparent [

	self assert: (self line
		 format: 'o';
		 alpha: 0.5;
		 markerFaceColor: Color transparent;
		 yourself) markerPatches first background paint color isTransparent
]

{ #category : 'tests' }
BpLineTest >> testAlphaMakesTheLineTransparent [

	self assert: ((self line
		  alpha: 0.5;
		  yourself) linePatch border paint color alpha closeTo: 0.5 precision: 0.01)
]

{ #category : 'tests' }
BpLineTest >> testColorIsTheColorOfTheLine [

	self
		assert: (self line
			 color: Color red;
			 yourself) linePatch border paint color
		equals: Color red
]

{ #category : 'tests - errors' }
BpLineTest >> testColorNameRaisesError [

	self should: [ self line color: 'red' ] raise: Error
]

{ #category : 'tests' }
BpLineTest >> testDashesGrowWithTheLineWidth [

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

	self assert: self line linePatch border paint color equals: (BpPalette default colorAt: 1)
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
BpLineTest >> testFormatDashedLine [

	self
		assert: (self line
			 format: '--';
			 yourself) linePatch border style dashArray size
		equals: 2
]

{ #category : 'tests - format' }
BpLineTest >> testFormatInAnyOrder [

	| line |
	line := self line
		        format: ':^';
		        yourself.
	self assert: line markerPatches first marker vertices size equals: 3.
	self deny: line linePatch border style dashArray isEmpty
]

{ #category : 'tests - instances' }
BpLineTest >> testFormatInstancesAreLabeledLines [

	self
		assert: ({
			 BpLine instanceLinearDashed.
			 BpLine instanceQuadraticSquares.
			 BpLine instanceCubicTriangles } collect: [ :each | each legendEntries first key ])
		equals: #( 'linear' 'quadratic' 'cubic' )
]

{ #category : 'tests - format' }
BpLineTest >> testFormatKeepsTheColor [

	self
		assert: (self line
			 color: Color black;
			 format: 'o--';
			 yourself) linePatch border paint color
		equals: Color black
]

{ #category : 'tests - format' }
BpLineTest >> testFormatReadsDashDotBeforeDash [

	self
		assert: (self line
			 format: '-.';
			 yourself) linePatch border style dashArray size
		equals: 4
]

{ #category : 'tests - errors' }
BpLineTest >> testFormatWithAColorLetterRaisesError [

	self should: [ self line format: 'r--' ] raise: Error
]

{ #category : 'tests - errors' }
BpLineTest >> testFormatWithACycleNameRaisesError [

	self should: [ self line format: 'C1' ] raise: Error
]

{ #category : 'tests - format' }
BpLineTest >> testFormatWithAMarkerOnlyDrawsNoLine [

	| line |
	line := self line
		        format: 'o';
		        yourself.
	self assert: line linePatch isNil.
	self assert: line markerPatches size equals: 3
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

{ #category : 'tests - instances' }
BpLineTest >> testInstanceQuadraticSquaresDrawsOnlySquares [

	| line |
	line := BpLine instanceQuadraticSquares.
	self assert: line patches size equals: 25.
	self assert: line patches asArray equals: line markerPatches asArray
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
BpLineTest >> testLineStyleAcceptsStrings [

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
		           markerFaceColor: Color white;
		           markerEdgeColor: Color black;
		           yourself) markerPatches first.
	self assert: marker background paint color equals: Color white.
	self assert: marker border paint color equals: Color black
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
	marker := (self line color: Color green;
		           marker: 's';
		           yourself) markerPatches first.
	self assert: marker background paint color equals: Color green.
	self assert: marker border paint color equals: Color green
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

{ #category : 'tests - instances' }
BpLineTest >> testPlotTypeInstancesAreOneLineEach [

	self
		assert: ({
			 BpLine instancePlotTypeMarkers.
			 BpLine instancePlotTypeLine.
			 BpLine instancePlotTypeLineMarkers } collect: [ :each | each class ])
		equals: {
			BpLine.
			BpLine.
			BpLine }
]

{ #category : 'tests' }
BpLineTest >> testSolidLineHasNoDashes [

	self assert: self line linePatch border style dashArray isEmpty
]

{ #category : 'tests - errors' }
BpLineTest >> testUnknownFormatCharacterRaisesError [

	self should: [ self line format: '-z' ] raise: Error
]

{ #category : 'tests - errors' }
BpLineTest >> testUnknownLineStyleRaisesError [

	self should: [ self line lineStyle: #wavy ] raise: Error
]

{ #category : 'tests - errors' }
BpLineTest >> testXAndYOfDifferentSizesRaiseError [

	self should: [ BpLine x: #( 1 2 ) y: #( 1 ) ] raise: Error
]
