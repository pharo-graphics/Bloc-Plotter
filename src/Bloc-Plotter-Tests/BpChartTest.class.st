"
I test `BpChart`: autoscaling with margins and sticky values, log scales, ticks, the grid, title, legend, the rendering of the patches of histograms and scatters, and the interaction handlers on their patches.
"
Class {
	#name : 'BpChartTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests - interaction' }
BpChartTest >> click: aChart atData: aDataPoint [
	"Click aChart, shown in a headless space, at a point given in data coordinates, once it is laid out."

	aChart inNewHeadlessSpaceDo: [ :space |
		space settle.
		aChart eventSimulator clickAt: aChart plotBounds origin + (aChart dataTransform pointFor: aDataPoint) ]
]

{ #category : 'tests' }
BpChartTest >> newChart [

	^ BpChart new
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpChartTest >> testBarIsPaintedWhereItsDataIs [
	"Sample the middle of the bar of the bin [0, 2), which holds 3 values."

	| chart form point |
	chart := self newChart.
	(chart hist: #( 1 1 1 3 ))
		bins: #( 0 2 4 );
		color: Color red.
	form := chart asForm.
	point := chart plotBounds origin + (chart dataTransform pointFor: 1 @ 1.5).
	self assert: (form colorAt: point rounded) equals: Color red.
	point := chart plotBounds origin + (chart dataTransform pointFor: 3 @ 1.5).
	self assert: (form colorAt: point rounded) equals: Color white
]

{ #category : 'tests - box plot' }
BpChartTest >> testBoxPlotAddsABoxPlot [

	| chart boxPlot |
	chart := BpChart new.
	boxPlot := chart boxPlot: #( #( 1 2 3 ) #( 4 5 6 ) ).
	self assert: chart artists asArray equals: { boxPlot }.
	self assert: boxPlot statistics size equals: 2
]

{ #category : 'tests - box plot' }
BpChartTest >> testBoxPlotLimitsAreHalfAUnitAroundThePositions [

	| chart |
	chart := BpChart new.
	chart boxPlot: #( #( 1 2 3 ) #( 4 5 6 ) ).
	self assert: chart dataTransform xLimits equals: #( 0.5 2.5 )
]

{ #category : 'tests - box plot' }
BpChartTest >> testBoxPlotPutsATickAtEachPosition [

	| chart |
	chart := BpChart new.
	chart boxPlot: #( #( 1 2 3 ) #( 4 5 6 ) ).
	self
		assert:
		((chart ticks select: [ :each | each axis = #x ]) collect: [ :each | each location -> each label text asString ] as: Array)
		equals: {
			(1 -> '1').
			(2 -> '2') }
]

{ #category : 'tests - box plot' }
BpChartTest >> testBoxPlotTickLabels [

	| chart |
	chart := BpChart new.
	(chart boxPlot: #( #( 1 2 3 ) #( 4 5 6 ) )) tickLabels: #( 'A' 'B' ).
	self
		assert: ((chart ticks select: [ :each | each axis = #x ]) collect: [ :each | each label text asString ] as: Array)
		equals: #( 'A' 'B' )
]

{ #category : 'tests' }
BpChartTest >> testChangingTheHistogramUpdatesThePlotArea [

	| chart histogram |
	chart := self newChart.
	histogram := chart hist: #( 1 2 3 ).
	histogram bins: 3.
	self assert: chart plotArea patches size equals: 3
]

{ #category : 'tests - palette' }
BpChartTest >> testChangingThePaletteRecolorsThePlots [

	| chart palette second |
	palette := BpQualitativePalette set1.
	chart := self newChart.
	chart plotX: #( 0 1 ) y: #( 0 1 ).
	second := chart plotX: #( 0 1 ) y: #( 1 2 ).
	chart palette: palette.
	self assert: second linePatch border paint color equals: (palette colorAt: 2)
]

{ #category : 'tests' }
BpChartTest >> testExplicitLimitsReplaceAutoScaling [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 ).
	chart xLimits: #( 0 100 ).
	self assert: chart xLimits equals: #( 0 100 )
]

{ #category : 'tests - box plot' }
BpChartTest >> testFixedTicksWinOverTheBoxPlotTicks [

	| chart |
	chart := BpChart new.
	chart boxPlot: #( #( 1 2 3 ) #( 4 5 6 ) ).
	chart xTicks: #( 1 1.5 2 ).
	self assert: ((chart ticks select: [ :each | each axis = #x ]) collect: [ :each | each location ] as: Array) equals: #( 1 1.5 2 )
]

{ #category : 'tests - grid' }
BpChartTest >> testGridFalseRemovesTheLines [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 ).
	chart
		grid: true;
		grid: false.
	self assert: chart plotArea gridLines isEmpty
]

{ #category : 'tests - grid' }
BpChartTest >> testGridHasOneLinePerTick [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 ).
	chart grid: true.
	self
		assert: (chart plotArea gridLines collect: [ :each | each location ] as: Array)
		equals: (chart ticks collect: [ :each | each location ] as: Array)
]

{ #category : 'tests - plot' }
BpChartTest >> testGridIsDrawnAboveScatterPoints [

	| chart scatter children |
	chart := BpChart new.
	scatter := chart scatterX: #( 0 1 ) y: #( 0 1 ).
	chart grid: true.
	children := chart plotArea children asArray.
	self assert: (children indexOf: scatter patches first) < (children findFirst: [ :each | each isKindOf: BpGridLine ])
]

{ #category : 'tests - plot' }
BpChartTest >> testGridIsDrawnBelowLines [

	| chart line children |
	chart := BpChart new.
	line := chart plotX: #( 0 1 ) y: #( 0 1 ).
	chart grid: true.
	children := chart plotArea children asArray.
	self assert: (children indexOf: line linePatch) > (children findLast: [ :each | each isKindOf: BpGridLine ])
]

{ #category : 'tests - grid' }
BpChartTest >> testGridLinesCrossThePlotArea [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 ).
	chart grid: true.
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: (chart plotArea gridLines detect: [ :each | each axis = #x ]) height equals: chart plotArea height ]
]

{ #category : 'tests' }
BpChartTest >> testHistAnswersAHistogramOfTheChart [

	| chart histogram |
	chart := self newChart.
	histogram := chart hist: #( 1 2 3 ).
	self assert: histogram chart identicalTo: chart.
	self assert: (chart artists includes: histogram)
]

{ #category : 'tests' }
BpChartTest >> testHistogramsTakeTheNextCycleColors [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 ).
	self assert: (chart hist: #( 1 2 3 )) patches first background paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests - box plot' }
BpChartTest >> testHorizontalBoxPlotPutsTheTicksOnTheYAxis [

	| chart |
	chart := BpChart new.
	(chart boxPlot: #( #( 1 2 3 ) )) orientation: #horizontal.
	self assert: ((chart ticks select: [ :each | each axis = #y ]) collect: [ :each | each location ] as: Array) equals: #( 1 )
]

{ #category : 'tests' }
BpChartTest >> testHorizontalHistogramsStickToZeroOnX [

	| chart |
	chart := self newChart.
	(chart hist: #( 1 1 ))
		bins: #( 0 10 );
		orientation: #horizontal.
	self assert: chart xLimits first equals: 0
]

{ #category : 'tests' }
BpChartTest >> testLegendShowsTheLabels [

	| chart |
	chart := self newChart.
	(chart hist: #( #( 1 ) #( 2 ) #( 3 ) )) label: #( 'red' 'tan' 'lime' ).
	chart legend.
	self assert: chart legendElement labels asArray equals: #( 'red' 'tan' 'lime' )
]

{ #category : 'tests' }
BpChartTest >> testLegendSkipsDatasetsWithoutLabel [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 ).
	(chart hist: #( 1 2 3 )) label: 'second'.
	chart legend.
	self assert: chart legendElement labels asArray equals: #( 'second' )
]

{ #category : 'tests' }
BpChartTest >> testLogHistogramPutsTheValueAxisOnALogScale [

	| chart |
	chart := self newChart.
	(chart hist: #( 1 2 2 3 3 3 )) log: true.
	self assert: chart yScale equals: #log.
	self assert: chart yLimits first > 0
]

{ #category : 'tests' }
BpChartTest >> testLogTicksArePowersOfTen [
	"All bars are 100 high: the limits go one decade below and above."

	| chart |
	chart := self newChart.
	(chart hist: ((1 to: 1000) collect: [ :each | each \\ 10 ])) log: true.
	self
		assert: ((chart ticks select: [ :each | each axis = #y ] thenCollect: [ :each | each location ]) as: Array)
		equals: #( 10 100 1000 )
]

{ #category : 'tests - grid' }
BpChartTest >> testNoGridByDefault [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 ).
	self assert: chart plotArea gridLines isEmpty
]

{ #category : 'tests' }
BpChartTest >> testNoLegendByDefault [

	| chart |
	chart := self newChart.
	(chart hist: #( 1 2 3 )) label: 'a'.
	self assert: chart legendElement isNil
]

{ #category : 'tests - palette' }
BpChartTest >> testPaletteColorsGoOnAfterARecolor [

	| chart palette third |
	palette := BpQualitativePalette set1.
	chart := self newChart.
	chart plotX: #( 0 1 ) y: #( 0 1 ).
	chart palette: palette.
	chart plotX: #( 0 1 ) y: #( 1 2 ).
	third := chart plotX: #( 0 1 ) y: #( 2 3 ).
	self assert: third linePatch border paint color equals: (palette colorAt: 3)
]

{ #category : 'tests - palette' }
BpChartTest >> testPaletteIsTab10ByDefault [

	self assert: self newChart palette name equals: 'tab10'
]

{ #category : 'tests' }
BpChartTest >> testPatchesAreShownInThePlotArea [

	| chart histogram |
	chart := self newChart.
	histogram := chart hist: #( 1 2 3 ).
	self assert: (histogram patches allSatisfy: [ :each | each parent == chart plotArea ])
]

{ #category : 'tests - plot' }
BpChartTest >> testPlotAddsALine [

	| chart line |
	chart := BpChart new.
	line := chart plotX: #( 0 1 2 ) y: #( 3 4 5 ).
	self assert: chart artists asArray equals: { line }.
	self assert: line points equals: {
		(0 @ 3).
		(1 @ 4).
		(2 @ 5) }
]

{ #category : 'tests - plot' }
BpChartTest >> testPlotAutoScalesOnItsPoints [

	| chart |
	chart := BpChart new.
	chart plotX: #( 0 10 ) y: #( 0 1 ).
	self assert: chart dataTransform xLimits equals: #( -0.5 10.5 )
]

{ #category : 'tests - plot' }
BpChartTest >> testPlotFormatSetsTheStyle [

	| line |
	line := BpChart new plotX: #( 0 1 ) y: #( 0 1 ) format: 'o'.
	self assert: line linePatch isNil.
	self assert: line markerPatches size equals: 2
]

{ #category : 'tests - palette' }
BpChartTest >> testPlotsTakeTheColorsOfThePalette [

	| chart palette first second |
	palette := BpQualitativePalette set1.
	chart := self newChart.
	chart palette: palette.
	first := chart plotX: #( 0 1 ) y: #( 0 1 ).
	second := chart plotX: #( 0 1 ) y: #( 1 2 ).
	self assert: first linePatch border paint color equals: (palette colorAt: 1).
	self assert: second linePatch border paint color equals: (palette colorAt: 2)
]

{ #category : 'tests - plot' }
BpChartTest >> testPlotsTakeTheNextColorsOfTheCycle [

	| chart |
	chart := BpChart new.
	chart plotX: #( 0 1 ) y: #( 0 1 ).
	self assert: (chart plotX: #( 0 1 ) y: #( 1 2 )) linePatch border paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests - scatter' }
BpChartTest >> testScatterAnswersAScatterOfTheChart [

	| chart scatter |
	chart := self newChart.
	scatter := chart scatterX: #( 1 2 ) y: #( 3 4 ).
	self assert: scatter chart identicalTo: chart.
	self assert: chart artists asArray equals: { scatter }
]

{ #category : 'tests - scatter' }
BpChartTest >> testScatterLimitsHaveFivePercentMarginsOnBothAxes [

	| chart |
	chart := self newChart.
	chart scatterX: #( 0 10 ) y: #( 0 20 ).
	self assert: chart xLimits equals: #( -0.5 10.5 ).
	self assert: chart yLimits equals: #( -1 21 )
]

{ #category : 'tests - scatter' }
BpChartTest >> testScatterMarkersArePlacedOnTheirPoints [

	| chart scatter |
	chart := self newChart.
	scatter := chart scatterX: #( 0 10 ) y: #( 0 20 ).
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: scatter patches first bounds center equals: (chart dataTransform pointFor: 0 @ 0) ]
]

{ #category : 'tests - scatter' }
BpChartTest >> testScatterTakesTheNextCycleColor [

	| chart scatter |
	chart := self newChart.
	chart hist: #( 1 2 ).
	scatter := chart scatterX: #( 1 ) y: #( 1 ).
	self assert: scatter patches first background paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests' }
BpChartTest >> testStepIsDrawnAsAnOutline [
	"The outline of an unfilled step goes up at the left edge; inside, the plot stays white."

	| chart form |
	chart := self newChart.
	(chart hist: #( 1 1 1 3 ))
		bins: #( 0 2 4 );
		histType: #step;
		color: Color red.
	form := chart asForm.
	self assert: (form colorAt: (chart plotBounds origin + (chart dataTransform pointFor: 1 @ 1.5)) rounded) equals: Color white.
	self assert: (form colorAt: (chart plotBounds origin + (chart dataTransform pointFor: 0 @ 1.5)) rounded) red > 0.8
]

{ #category : 'tests' }
BpChartTest >> testTickCountsAreSettingsNotDerivedFromTheSize [

	| chart |
	chart := self newChart.
	self assert: chart xTickCount equals: 6.
	self assert: chart yTickCount equals: 8
]

{ #category : 'tests' }
BpChartTest >> testTickFormatterGivesTheLabels [

	| chart |
	chart := self newChart.
	(chart hist: #( 1 2 3 )) density: true.
	chart yTickFormatter: [ :value | (value * 100) rounded printString , '%' ].
	self assert: (chart ticks detect: [ :each | each axis = #y ]) label text asString equals: '0%'
]

{ #category : 'tests' }
BpChartTest >> testTicksAreInsideTheLimits [

	| chart |
	chart := self newChart.
	chart hist: #( 1 2 3 7 ).
	self assert: (chart ticks allSatisfy: [ :each |
		 | limits |
		 limits := each axis = #x
			           ifTrue: [ chart xLimits ]
			           ifFalse: [ chart yLimits ].
		 each location between: limits first and: limits last ])
]

{ #category : 'tests' }
BpChartTest >> testTitle [

	| chart |
	chart := self newChart.
	chart title: 'stepfilled'.
	self assert: chart title equals: 'stepfilled'
]

{ #category : 'tests - interaction' }
BpChartTest >> testWhenPatchDoReceivesTheClickedBar [

	| chart histogram clicked |
	clicked := nil.
	chart := self newChart.
	histogram := chart hist: #( 1 1 1 3 ).
	histogram
		bins: #( 0 2 4 );
		whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	self click: chart atData: 3 @ 0.5.
	self assert: clicked identicalTo: histogram patches second
]

{ #category : 'tests - scatter' }
BpChartTest >> testWhenPatchDoReceivesTheClickedMarker [

	| chart scatter clicked |
	clicked := nil.
	chart := self newChart.
	scatter := chart scatterX: #( 0 5 10 ) y: #( 0 5 10 ).
	scatter
		s: 400;
		whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	self click: chart atData: 5 @ 5.
	self assert: clicked index equals: 2
]

{ #category : 'tests - interaction' }
BpChartTest >> testWhenPatchDoSurvivesARebuild [

	| chart histogram clicked |
	clicked := nil.
	chart := self newChart.
	histogram := chart hist: #( 1 1 1 3 ).
	histogram whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	histogram bins: #( 0 2 4 ).
	self click: chart atData: 1 @ 0.5.
	self assert: clicked identicalTo: histogram patches first
]

{ #category : 'tests' }
BpChartTest >> testXLimitsHaveFivePercentMargins [

	| chart |
	chart := self newChart.
	(chart hist: #( 1 )) bins: #( 0 10 ).
	self assert: chart xLimits equals: #( -0.5 10.5 )
]

{ #category : 'tests - plot' }
BpChartTest >> testXTicksAreTheGivenLocations [

	| chart |
	chart := BpChart new.
	chart plotX: #( 0 10 ) y: #( 0 10 ).
	chart xTicks: (1 to: 7).
	self
		assert: ((chart ticks select: [ :each | each axis = #x ]) collect: [ :each | each location ] as: Array)
		equals: #( 1 2 3 4 5 6 7 )
]

{ #category : 'tests' }
BpChartTest >> testYLimitsStickToZero [

	| chart |
	chart := self newChart.
	(chart hist: #( 1 1 )) bins: #( 0 10 ).
	self assert: chart yLimits first equals: 0.
	self assert: chart yLimits last closeTo: 2.1
]

{ #category : 'tests - plot' }
BpChartTest >> testYTicksAreTheGivenLocations [

	| chart |
	chart := BpChart new.
	chart plotX: #( 0 10 ) y: #( 0 10 ).
	chart yTicks: #( 2 4 ).
	self
		assert: ((chart ticks select: [ :each | each axis = #y ]) collect: [ :each | each label text asString ] as: Array)
		equals: #( '2' '4' )
]
