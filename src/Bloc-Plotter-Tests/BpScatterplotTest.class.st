"
I test `BpScatterPlot`: one marker per point, sizes, colors given or mapped through a color map, alpha, edges, unfilled markers and legend entries.
"
Class {
	#name : 'BpScatterPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpScatterPlotTest >> scatter [

	^ BpScatterPlot x: #( 1 2 3 ) y: #( 4 5 6 )
]

{ #category : 'tests' }
BpScatterPlotTest >> testAlphaMakesTheFacesTransparent [

	self
		assert: (self scatter
			 alpha: 0.5;
			 yourself) patches first background paint color alpha
		closeTo: 0.5
		precision: 0.01
]

{ #category : 'tests' }
BpScatterPlotTest >> testCGivesOneColorForAllPoints [

	self
		assert: ((self scatter
			  c: Color red;
			  yourself) patches collect: [ :each | each background paint color ] as: Set) asArray
		equals: { Color red }
]

{ #category : 'tests' }
BpScatterPlotTest >> testCGivesOneColorPerPoint [

	| colors |
	colors := {
		          Color red.
		          Color green.
		          Color blue }.
	self
		assert: ((self scatter
	  c: colors;
	  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: colors
]

{ #category : 'tests' }
BpScatterPlotTest >> testColorMapCanBeABlock [

	self
		assert: (self scatter
			 c: #( 0 1 2 );
			 colorMap: [ :fraction | Color gray: fraction ];
			 yourself) patches last background paint color
		equals: (Color gray: 1)
]

{ #category : 'tests' }
BpScatterPlotTest >> testColorMapCanBeAPalette [

	| palette |
	palette := BpInterpolatedPalette name: 'ends' anchors: (BpSequentialPalette greys: 9) colors.
	self
		assert: (self scatter
			 c: #( 0 1 2 );
			 colorMap: palette;
			 yourself) patches last background paint color
		equals: (palette colorAt: 1)
]

{ #category : 'tests' }
BpScatterPlotTest >> testDefaultColorIsTheFirstColorOfTheCycle [

	self assert: self scatter patches first background paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests' }
BpScatterPlotTest >> testDefaultSizeIsTheSquareOfASixPointMarker [

	self assert: self scatter patches first area equals: 36
]

{ #category : 'tests' }
BpScatterPlotTest >> testEdgeColorsGivesTheEdgeColor [

	self
		assert: (self scatter
			 edgeColors: Color black;
			 yourself) patches first border paint color
		equals: Color black
]

{ #category : 'tests' }
BpScatterPlotTest >> testEdgeHasTheFaceColorByDefault [

	| patch |
	patch := (self scatter c: Color red;
		          yourself) patches first.
	self assert: patch border paint color equals: Color red
]

{ #category : 'tests' }
BpScatterPlotTest >> testLabelGivesALegendEntry [

	self
		assert: ((self scatter
	  label: 'points';
	  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'points' )
]

{ #category : 'tests' }
BpScatterPlotTest >> testLineWidthsAreInPoints [

	self assert: ((self scatter
		  edgeColors: Color black;
		  lineWidths: 2;
		  yourself) patches first border width closeTo: 2 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpScatterPlotTest >> testMarkerIsGivenToThePatches [

	self
		assert: (self scatter
			 marker: '^';
			 yourself) patches first marker vertices size
		equals: 3
]

{ #category : 'tests' }
BpScatterPlotTest >> testMarkerSideIsTheSquareRootOfTheSizeInPoints [

	self assert: ((self scatter
		  s: 100;
		  yourself) patches first side closeTo: 10 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpScatterPlotTest >> testNoLegendEntryWithoutLabel [

	self assert: self scatter legendEntries isEmpty
]

{ #category : 'tests' }
BpScatterPlotTest >> testNumbersOfCAreMappedThroughViridis [

	self
		assert: ((self scatter
	  c: #( 0 5 10 );
	  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: {
			(BpInterpolatedPalette viridis colorAt: 0).
			(BpInterpolatedPalette viridis colorAt: 0.5).
			(BpInterpolatedPalette viridis colorAt: 1) }
]

{ #category : 'tests' }
BpScatterPlotTest >> testOffsetsArePointsOfXAndY [

	self assert: self scatter offsets equals: {
		(1 @ 4).
		(2 @ 5).
		(3 @ 6) }
]

{ #category : 'tests' }
BpScatterPlotTest >> testOnePatchPerPoint [

	| scatter |
	scatter := self scatter.
	self assert: (scatter patches collect: [ :each | each dataPoint ] as: Array) equals: scatter offsets
]

{ #category : 'tests' }
BpScatterPlotTest >> testPatchCoversOnlyItsPointInDataCoordinates [

	self assert: self scatter patches first dataBounds equals: (1 @ 4 corner: 1 @ 4)
]

{ #category : 'tests' }
BpScatterPlotTest >> testPatchesKnowTheValueOfC [

	self
		assert: ((self scatter
	  c: #( 7 8 9 );
	  yourself) patches collect: [ :each | each amount ] as: Array)
		equals: #( 7 8 9 )
]

{ #category : 'tests' }
BpScatterPlotTest >> testPatchesKnowTheirIndex [

	self assert: (self scatter patches collect: [ :each | each index ] as: Array) equals: #( 1 2 3 )
]

{ #category : 'tests' }
BpScatterPlotTest >> testSizesCanBeGivenPerPoint [

	self
		assert: ((self scatter
	  s: #( 10 20 30 );
	  yourself) patches collect: [ :each | each area ] as: Array)
		equals: #( 10 20 30 )
]

{ #category : 'tests' }
BpScatterPlotTest >> testTransparentEdgeColorRemovesTheEdge [

	self
		assert: (self scatter
			 edgeColors: Color transparent;
			 yourself) patches first border width
		equals: 0
]

{ #category : 'tests' }
BpScatterPlotTest >> testUnfilledMarkerIsDrawnWithItsColor [

	| patch |
	patch := (self scatter c: Color red;
		          marker: '+';
		          yourself) patches first.
	self assert: patch background isTransparent.
	self assert: patch border paint color equals: Color red
]

{ #category : 'tests' }
BpScatterPlotTest >> testVMinAndVMaxClipTheColorMap [

	self
		assert: ((self scatter
			  c: #( 0 3 10 );
			  vMin: 2;
			  vMax: 4;
			  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: {
			(BpInterpolatedPalette viridis colorAt: 0).
			(BpInterpolatedPalette viridis colorAt: 0.5).
			(BpInterpolatedPalette viridis colorAt: 1) }
]

{ #category : 'tests - errors' }
BpScatterPlotTest >> testXAndYOfDifferentSizesRaiseError [

	self should: [ BpScatterPlot x: #( 1 2 ) y: #( 1 ) ] raise: Error
]
