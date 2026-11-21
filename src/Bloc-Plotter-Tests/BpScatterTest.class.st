"
I test `BpScatter`: one marker per point, sizes, colors given or mapped through a colormap, alpha, edges, unfilled markers and legend entries.
"
Class {
	#name : 'BpScatterTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpScatterTest >> scatter [

	^ BpScatter x: #( 1 2 3 ) y: #( 4 5 6 )
]

{ #category : 'tests' }
BpScatterTest >> testAlphaMakesTheFacesTransparent [

	self
		assert: (self scatter
			 alpha: 0.5;
			 yourself) patches first background paint color alpha
		closeTo: 0.5
		precision: 0.01
]

{ #category : 'tests' }
BpScatterTest >> testCGivesOneColorPerPoint [

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
BpScatterTest >> testCNamesOneColorForAllPoints [

	self
		assert: ((self scatter
	  c: 'red';
	  yourself) patches collect: [ :each | each background paint color ] as: Set) asArray
		equals: { (BpColors named: 'red') }
]

{ #category : 'tests' }
BpScatterTest >> testCmapCanBeABlock [

	self
		assert: (self scatter
			 c: #( 0 1 2 );
			 cmap: [ :fraction | Color gray: fraction ];
			 yourself) patches last background paint color
		equals: (Color gray: 1)
]

{ #category : 'tests' }
BpScatterTest >> testDefaultColorIsTheFirstColorOfTheCycle [

	self assert: self scatter patches first background paint color equals: BpColors tab10 first
]

{ #category : 'tests' }
BpScatterTest >> testDefaultSizeIsTheSquareOfTheMarkerSizeOfMatplotlib [

	self assert: self scatter patches first area equals: 36
]

{ #category : 'tests' }
BpScatterTest >> testEdgeHasTheFaceColorByDefault [

	| patch |
	patch := (self scatter
		          c: 'red';
		          yourself) patches first.
	self assert: patch border paint color equals: (BpColors named: 'red')
]

{ #category : 'tests' }
BpScatterTest >> testEdgecolorsGivesTheEdgeColor [

	self
		assert: (self scatter
			 edgecolors: Color black;
			 yourself) patches first border paint color
		equals: Color black
]

{ #category : 'tests' }
BpScatterTest >> testEdgecolorsNoneRemovesTheEdge [

	self
		assert: (self scatter
			 edgecolors: 'none';
			 yourself) patches first border width
		equals: 0
]

{ #category : 'tests' }
BpScatterTest >> testLabelGivesALegendEntry [

	self
		assert: ((self scatter
	  label: 'points';
	  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'points' )
]

{ #category : 'tests' }
BpScatterTest >> testLinewidthsAreInPoints [

	self assert: ((self scatter
		  edgecolors: Color black;
		  linewidths: 2;
		  yourself) patches first border width closeTo: 2 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpScatterTest >> testMarkerIsGivenToThePatches [

	self
		assert: (self scatter
			 marker: '^';
			 yourself) patches first marker vertices size
		equals: 3
]

{ #category : 'tests' }
BpScatterTest >> testMarkerSideIsTheSquareRootOfTheSizeInPoints [

	self assert: ((self scatter
		  s: 100;
		  yourself) patches first side closeTo: 10 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpScatterTest >> testNoLegendEntryWithoutLabel [

	self assert: self scatter legendEntries isEmpty
]

{ #category : 'tests' }
BpScatterTest >> testNumbersOfCAreMappedThroughViridis [

	self
		assert: ((self scatter
	  c: #( 0 5 10 );
	  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: {
			(BpColors viridis: 0).
			(BpColors viridis: 0.5).
			(BpColors viridis: 1) }
]

{ #category : 'tests' }
BpScatterTest >> testOffsetsArePointsOfXAndY [

	self assert: self scatter offsets equals: {
		(1 @ 4).
		(2 @ 5).
		(3 @ 6) }
]

{ #category : 'tests' }
BpScatterTest >> testOnePatchPerPoint [

	| scatter |
	scatter := self scatter.
	self assert: (scatter patches collect: [ :each | each dataPoint ] as: Array) equals: scatter offsets
]

{ #category : 'tests' }
BpScatterTest >> testPatchCoversOnlyItsPointInDataCoordinates [

	self assert: self scatter patches first dataBounds equals: (1 @ 4 corner: 1 @ 4)
]

{ #category : 'tests' }
BpScatterTest >> testPatchesKnowTheValueOfC [

	self
		assert: ((self scatter
	  c: #( 7 8 9 );
	  yourself) patches collect: [ :each | each amount ] as: Array)
		equals: #( 7 8 9 )
]

{ #category : 'tests' }
BpScatterTest >> testPatchesKnowTheirIndex [

	self assert: (self scatter patches collect: [ :each | each index ] as: Array) equals: #( 1 2 3 )
]

{ #category : 'tests' }
BpScatterTest >> testSizesCanBeGivenPerPoint [

	self
		assert: ((self scatter
	  s: #( 10 20 30 );
	  yourself) patches collect: [ :each | each area ] as: Array)
		equals: #( 10 20 30 )
]

{ #category : 'tests' }
BpScatterTest >> testUnfilledMarkerIsDrawnWithItsColor [

	| patch |
	patch := (self scatter
		          c: 'red';
		          marker: '+';
		          yourself) patches first.
	self assert: patch background isTransparent.
	self assert: patch border paint color equals: (BpColors named: 'red')
]

{ #category : 'tests' }
BpScatterTest >> testVminAndVmaxClipTheColormap [

	self
		assert: ((self scatter
	  c: #( 0 3 10 );
	  vmin: 2;
	  vmax: 4;
	  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: {
			(BpColors viridis: 0).
			(BpColors viridis: 0.5).
			(BpColors viridis: 1) }
]

{ #category : 'tests - errors' }
BpScatterTest >> testXAndYOfDifferentSizesRaiseError [

	self should: [ BpScatter x: #( 1 2 ) y: #( 1 ) ] raise: Error
]
