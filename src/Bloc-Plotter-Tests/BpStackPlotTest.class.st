"
I check `BpStackPlot`, as `BpStackPlot class>>x:ys:` creates it: the stacks and the vertices of each layer, the four baselines, the colors of the cycle and given colors, outlines, transparency, legend entries and handlers, and the sample instances.

## Implementation Notes

- My fixture stacks 1, 2, 3 and 2, 2, 2 over x = 1, 2, 3. Its baselines were computed by hand with fractions, so the expected values are exact.
- The stack is not in a figure: the polygons are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpStackPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpStackPlotTest >> stack [
	"Two layers over x = 1, 2, 3: 1, 2, 3 and then 2, 2, 2."

	^ BpStackPlot new
		  x: #( 1 2 3 ) ys: #( #( 1 2 3 ) #( 2 2 2 ) );
		  yourself
]

{ #category : 'tests' }
BpStackPlotTest >> stackWithBaseline: aSymbol [

	^ self stack
		  baseline: aSymbol;
		  yourself
]

{ #category : 'tests' }
BpStackPlotTest >> testAddArtistAddsTheStack [

	| chart stack |
	chart := BpChart new.
	stack := chart addArtist: (BpStackPlot x: #( 1 2 3 ) ys: #( #( 1 2 3 ) #( 2 2 2 ) )).
	self assert: chart artists last identicalTo: stack.
	self assert: stack stacks equals: #( #( 1 2 3 ) #( 3 4 5 ) )
]

{ #category : 'tests' }
BpStackPlotTest >> testAlphaMakesTheLayersTransparent [

	self assert: ((self stack
		  alpha: 0.3;
		  yourself) patches second background paint color alpha closeTo: 0.3 precision: 0.01)
]

{ #category : 'tests - instances' }
BpStackPlotTest >> testBaselineInstancesShareTheirLayers [

	self assert: BpStackPlot instanceZeroBaseline stacks first equals: BpStackPlot streamLayers first
]

{ #category : 'tests' }
BpStackPlotTest >> testBaselineShiftsTheStacks [

	self assert: (self stackWithBaseline: #wiggle) stacks first equals: {
		(-1 / 4).
		0.
		(1 / 4) }
]

{ #category : 'tests' }
BpStackPlotTest >> testColorsAreRepeatedWhenTooFew [

	self
		assert: ((self stack colors: { Color red };
			  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: {
			Color red.
			Color red }
]

{ #category : 'tests' }
BpStackPlotTest >> testColorsGiveOneColorPerLayer [

	self
		assert: ((self stack colors: {
	Color red.
	Color black };
			  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: {
			Color red.
			Color black }
]

{ #category : 'tests' }
BpStackPlotTest >> testEachLayerGoesFromThePreviousStackToItsTop [

	self assert: self stack patches second dataVertices asArray equals: {
		(1 @ 1).
		(1 @ 3).
		(2 @ 4).
		(3 @ 5).
		(3 @ 3).
		(3 @ 3).
		(2 @ 2).
		(1 @ 1) }
]

{ #category : 'tests' }
BpStackPlotTest >> testEachLayerTakesTheNextColorOfTheCycle [

	| chart stack |
	chart := BpChart new.
	stack := chart addArtist: (BpStackPlot x: #( 1 2 3 ) ys: #( #( 1 2 3 ) #( 2 2 2 ) )).
	self assert: (stack patches collect: [ :each | each background paint color ] as: Array) equals: (BpPalette default colors first: 2).
	self assert: (chart addArtist: (BpLine x: #( 1 2 ) y: #( 1 2 ))) linePatch border paint color equals: (BpPalette default colorAt: 3)
]

{ #category : 'tests' }
BpStackPlotTest >> testEdgeColorOutlinesTheLayers [

	| polygon |
	polygon := (self stack edgeColor: Color black;
		            lineWidth: 2;
		            yourself) patches second.
	self assert: polygon border paint color equals: Color black.
	self assert: (polygon border width closeTo: 2 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpStackPlotTest >> testFirstLayerGoesFromTheBaselineToTheFirstCurve [

	self assert: self stack patches first dataVertices asArray equals: {
		(1 @ 0).
		(1 @ 1).
		(2 @ 2).
		(3 @ 3).
		(3 @ 0).
		(3 @ 0).
		(2 @ 0).
		(1 @ 0) }
]

{ #category : 'tests' }
BpStackPlotTest >> testHandlersAreKeptWhenTheStackIsRebuilt [

	| stack clicked |
	stack := self stack.
	clicked := nil.
	stack whenPatch: BlClickEvent do: [ :event :polygon | clicked := polygon ].
	stack baseline: #sym.
	BlEvent fireEvent: BlClickEvent new target: stack patches second.
	self assert: clicked identicalTo: stack patches second
]

{ #category : 'tests - instances' }
BpStackPlotTest >> testInstanceWorldPopulationHasOneLayerPerContinent [

	self assert: BpStackPlot instanceWorldPopulation stacks size equals: 5
]

{ #category : 'tests' }
BpStackPlotTest >> testLabelsGiveOneLegendEntryPerLabeledLayer [

	self
		assert: ((self stack
			  label: #( 'below' nil );
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'below' )
]

{ #category : 'tests - errors' }
BpStackPlotTest >> testLayerOfAnotherSizeRaisesError [

	self should: [ BpStackPlot new x: #( 1 2 3 ) ys: #( #( 1 2 3 ) #( 1 2 ) ) ] raise: Error
]

{ #category : 'tests' }
BpStackPlotTest >> testLayersAreBelowTheGrid [

	self deny: self stack isAboveGrid
]

{ #category : 'tests' }
BpStackPlotTest >> testLayersHaveNoOutlineByDefault [

	self assert: (self stack patches allSatisfy: [ :each | each border width isZero ])
]

{ #category : 'tests' }
BpStackPlotTest >> testNoLabelGivesNoLegendEntry [

	self assert: self stack legendEntries isEmpty
]

{ #category : 'tests' }
BpStackPlotTest >> testOneCollectionOfNumbersIsOneLayer [

	self
		assert: (BpStackPlot new
			 x: #( 1 2 ) ys: #( 3 4 );
			 yourself) stacks
		equals: #( #( 3 4 ) )
]

{ #category : 'tests' }
BpStackPlotTest >> testOnePolygonPerLayer [

	| stack |
	stack := self stack.
	self assert: stack patches size equals: 2.
	self assert: (stack patches allSatisfy: [ :each | each isClosed ]).
	self assert: (stack patches collect: [ :each | each dataset ] as: Array) equals: #( 1 2 )
]

{ #category : 'tests' }
BpStackPlotTest >> testStacksAreRunningSums [

	self assert: self stack stacks equals: #( #( 1 2 3 ) #( 3 4 5 ) )
]

{ #category : 'tests' }
BpStackPlotTest >> testSymBaselineCentersTheStackOnZero [

	| stack |
	stack := self stackWithBaseline: #sym.
	self assert: stack baselineValues equals: {
		(-3 / 2).
		-2.
		(-5 / 2) }.
	self assert: stack stacks last equals: {
		(3 / 2).
		2.
		(5 / 2) }
]

{ #category : 'tests - errors' }
BpStackPlotTest >> testUnknownBaselineRaisesError [

	self should: [ self stack baseline: #middle ] raise: Error
]

{ #category : 'tests' }
BpStackPlotTest >> testWeightedWiggleBaselineFollowsTheGrowthOfTheLayers [

	self assert: (self stackWithBaseline: #weightedWiggle) baselineValues equals: {
		(-3 / 2).
		(-7 / 4).
		(-41 / 20) }
]

{ #category : 'tests' }
BpStackPlotTest >> testWiggleBaselineWeighsTheLowerLayersMore [

	self assert: (self stackWithBaseline: #wiggle) baselineValues equals: {
		(-5 / 4).
		-2.
		(-11 / 4) }
]

{ #category : 'tests - instances' }
BpStackPlotTest >> testXYsCreatesTheStack [

	self assert: (BpStackPlot x: #( 1 2 ) ys: #( #( 1 1 ) #( 2 3 ) )) stacks equals: #( #( 1 1 ) #( 3 4 ) )
]

{ #category : 'tests' }
BpStackPlotTest >> testZeroBaselineStartsAtZero [

	self assert: self stack baselineValues equals: #( 0 0 0 )
]
