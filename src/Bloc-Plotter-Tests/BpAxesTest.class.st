"
I test `BpAxes`: autoscaling with margins and sticky values, log scales, ticks, the grid, title, legend, the rendering of the patches of histograms and scatters, and the interaction handlers on their patches.
"
Class {
	#name : 'BpAxesTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests - interaction' }
BpAxesTest >> click: anAxes atData: aDataPoint [
	"Click anAxes, shown in a headless space, at a point given in data coordinates, once it is laid out."

	anAxes inNewHeadlessSpaceDo: [ :space |
		space settle.
		anAxes eventSimulator clickAt: anAxes plotBounds origin + (anAxes dataTransform pointFor: aDataPoint) ]
]

{ #category : 'tests' }
BpAxesTest >> newAxes [

	^ BpAxes new
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpAxesTest >> testBarIsPaintedWhereItsDataIs [
	"Sample the middle of the bar of the bin [0, 2), which holds 3 values."

	| axes form point |
	axes := self newAxes.
	(axes hist: #( 1 1 1 3 ))
		bins: #( 0 2 4 );
		color: Color red.
	form := axes asForm.
	point := axes plotBounds origin + (axes dataTransform pointFor: 1 @ 1.5).
	self assert: (form colorAt: point rounded) equals: Color red.
	point := axes plotBounds origin + (axes dataTransform pointFor: 3 @ 1.5).
	self assert: (form colorAt: point rounded) equals: Color white
]

{ #category : 'tests' }
BpAxesTest >> testChangingTheHistogramUpdatesThePlotArea [

	| axes histogram |
	axes := self newAxes.
	histogram := axes hist: #( 1 2 3 ).
	histogram bins: 3.
	self assert: axes plotArea patches size equals: 3
]

{ #category : 'tests' }
BpAxesTest >> testExplicitLimitsReplaceAutoScaling [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 ).
	axes xLimits: #( 0 100 ).
	self assert: axes xLimits equals: #( 0 100 )
]

{ #category : 'tests - grid' }
BpAxesTest >> testGridFalseRemovesTheLines [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 ).
	axes
		grid: true;
		grid: false.
	self assert: axes plotArea gridLines isEmpty
]

{ #category : 'tests - grid' }
BpAxesTest >> testGridHasOneLinePerTick [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 ).
	axes grid: true.
	self
		assert: (axes plotArea gridLines collect: [ :each | each location ] as: Array)
		equals: (axes ticks collect: [ :each | each location ] as: Array)
]

{ #category : 'tests - plot' }
BpAxesTest >> testGridIsDrawnAboveScatterPoints [

	| axes scatter children |
	axes := BpAxes new.
	scatter := axes scatterX: #( 0 1 ) y: #( 0 1 ).
	axes grid: true.
	children := axes plotArea children asArray.
	self assert: (children indexOf: scatter patches first) < (children findFirst: [ :each | each isKindOf: BpGridLine ])
]

{ #category : 'tests - plot' }
BpAxesTest >> testGridIsDrawnBelowLines [

	| axes line children |
	axes := BpAxes new.
	line := axes plotX: #( 0 1 ) y: #( 0 1 ).
	axes grid: true.
	children := axes plotArea children asArray.
	self assert: (children indexOf: line linePatch) > (children findLast: [ :each | each isKindOf: BpGridLine ])
]

{ #category : 'tests - grid' }
BpAxesTest >> testGridLinesCrossThePlotArea [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 ).
	axes grid: true.
	axes inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: (axes plotArea gridLines detect: [ :each | each axis = #x ]) height equals: axes plotArea height ]
]

{ #category : 'tests' }
BpAxesTest >> testHistAnswersAHistogramOfTheAxes [

	| axes histogram |
	axes := self newAxes.
	histogram := axes hist: #( 1 2 3 ).
	self assert: histogram axes identicalTo: axes.
	self assert: (axes artists includes: histogram)
]

{ #category : 'tests' }
BpAxesTest >> testHistogramsTakeTheNextCycleColors [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 ).
	self assert: (axes hist: #( 1 2 3 )) patches first background paint color equals: BpColors tab10 second
]

{ #category : 'tests' }
BpAxesTest >> testHorizontalHistogramsStickToZeroOnX [

	| axes |
	axes := self newAxes.
	(axes hist: #( 1 1 ))
		bins: #( 0 10 );
		orientation: #horizontal.
	self assert: axes xLimits first equals: 0
]

{ #category : 'tests' }
BpAxesTest >> testLegendShowsTheLabels [

	| axes |
	axes := self newAxes.
	(axes hist: #( #( 1 ) #( 2 ) #( 3 ) )) label: #( 'red' 'tan' 'lime' ).
	axes legend.
	self assert: axes legendElement labels asArray equals: #( 'red' 'tan' 'lime' )
]

{ #category : 'tests' }
BpAxesTest >> testLegendSkipsDatasetsWithoutLabel [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 ).
	(axes hist: #( 1 2 3 )) label: 'second'.
	axes legend.
	self assert: axes legendElement labels asArray equals: #( 'second' )
]

{ #category : 'tests' }
BpAxesTest >> testLogHistogramPutsTheValueAxisOnALogScale [

	| axes |
	axes := self newAxes.
	(axes hist: #( 1 2 2 3 3 3 )) log: true.
	self assert: axes yScale equals: #log.
	self assert: axes yLimits first > 0
]

{ #category : 'tests' }
BpAxesTest >> testLogTicksArePowersOfTen [
	"All bars are 100 high: the limits go one decade below and above."

	| axes |
	axes := self newAxes.
	(axes hist: ((1 to: 1000) collect: [ :each | each \\ 10 ])) log: true.
	self
		assert: ((axes ticks select: [ :each | each axis = #y ] thenCollect: [ :each | each location ]) as: Array)
		equals: #( 10 100 1000 )
]

{ #category : 'tests - grid' }
BpAxesTest >> testNoGridByDefault [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 ).
	self assert: axes plotArea gridLines isEmpty
]

{ #category : 'tests' }
BpAxesTest >> testNoLegendByDefault [

	| axes |
	axes := self newAxes.
	(axes hist: #( 1 2 3 )) label: 'a'.
	self assert: axes legendElement isNil
]

{ #category : 'tests' }
BpAxesTest >> testPatchesAreShownInThePlotArea [

	| axes histogram |
	axes := self newAxes.
	histogram := axes hist: #( 1 2 3 ).
	self assert: (histogram patches allSatisfy: [ :each | each parent == axes plotArea ])
]

{ #category : 'tests - plot' }
BpAxesTest >> testPlotAddsALine [

	| axes line |
	axes := BpAxes new.
	line := axes plotX: #( 0 1 2 ) y: #( 3 4 5 ).
	self assert: axes artists asArray equals: { line }.
	self assert: line points equals: {
		(0 @ 3).
		(1 @ 4).
		(2 @ 5) }
]

{ #category : 'tests - plot' }
BpAxesTest >> testPlotAutoScalesOnItsPoints [

	| axes |
	axes := BpAxes new.
	axes plotX: #( 0 10 ) y: #( 0 1 ).
	self assert: axes dataTransform xLimits equals: #( -0.5 10.5 )
]

{ #category : 'tests - plot' }
BpAxesTest >> testPlotFormatSetsTheStyle [

	| line |
	line := BpAxes new plotX: #( 0 1 ) y: #( 0 1 ) format: 'ro'.
	self assert: line linePatch isNil.
	self assert: line markerPatches size equals: 2
]

{ #category : 'tests - plot' }
BpAxesTest >> testPlotsTakeTheNextColorsOfTheCycle [

	| axes |
	axes := BpAxes new.
	axes plotX: #( 0 1 ) y: #( 0 1 ).
	self assert: (axes plotX: #( 0 1 ) y: #( 1 2 )) linePatch border paint color equals: BpColors tab10 second
]

{ #category : 'tests - scatter' }
BpAxesTest >> testScatterAnswersAScatterOfTheAxes [

	| axes scatter |
	axes := self newAxes.
	scatter := axes scatterX: #( 1 2 ) y: #( 3 4 ).
	self assert: scatter axes identicalTo: axes.
	self assert: axes artists asArray equals: { scatter }
]

{ #category : 'tests - scatter' }
BpAxesTest >> testScatterLimitsHaveFivePercentMarginsOnBothAxes [

	| axes |
	axes := self newAxes.
	axes scatterX: #( 0 10 ) y: #( 0 20 ).
	self assert: axes xLimits equals: #( -0.5 10.5 ).
	self assert: axes yLimits equals: #( -1 21 )
]

{ #category : 'tests - scatter' }
BpAxesTest >> testScatterMarkersArePlacedOnTheirPoints [

	| axes scatter |
	axes := self newAxes.
	scatter := axes scatterX: #( 0 10 ) y: #( 0 20 ).
	axes inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: scatter patches first bounds center equals: (axes dataTransform pointFor: 0 @ 0) ]
]

{ #category : 'tests - scatter' }
BpAxesTest >> testScatterTakesTheNextCycleColor [

	| axes scatter |
	axes := self newAxes.
	axes hist: #( 1 2 ).
	scatter := axes scatterX: #( 1 ) y: #( 1 ).
	self assert: scatter patches first background paint color equals: BpColors tab10 second
]

{ #category : 'tests' }
BpAxesTest >> testStepIsDrawnAsAnOutline [
	"The outline of an unfilled step goes up at the left edge; inside, the plot stays white."

	| axes form |
	axes := self newAxes.
	(axes hist: #( 1 1 1 3 ))
		bins: #( 0 2 4 );
		histType: #step;
		color: Color red.
	form := axes asForm.
	self assert: (form colorAt: (axes plotBounds origin + (axes dataTransform pointFor: 1 @ 1.5)) rounded) equals: Color white.
	self assert: (form colorAt: (axes plotBounds origin + (axes dataTransform pointFor: 0 @ 1.5)) rounded) red > 0.8
]

{ #category : 'tests' }
BpAxesTest >> testTickCountsAreSettingsNotDerivedFromTheSize [

	| axes |
	axes := self newAxes.
	self assert: axes xTickCount equals: 6.
	self assert: axes yTickCount equals: 8
]

{ #category : 'tests' }
BpAxesTest >> testTickFormatterGivesTheLabels [

	| axes |
	axes := self newAxes.
	(axes hist: #( 1 2 3 )) density: true.
	axes yTickFormatter: [ :value | (value * 100) rounded printString , '%' ].
	self assert: (axes ticks detect: [ :each | each axis = #y ]) label text asString equals: '0%'
]

{ #category : 'tests' }
BpAxesTest >> testTicksAreInsideTheLimits [

	| axes |
	axes := self newAxes.
	axes hist: #( 1 2 3 7 ).
	self assert: (axes ticks allSatisfy: [ :each |
		 | limits |
		 limits := each axis = #x
			           ifTrue: [ axes xLimits ]
			           ifFalse: [ axes yLimits ].
		 each location between: limits first and: limits last ])
]

{ #category : 'tests' }
BpAxesTest >> testTitle [

	| axes |
	axes := self newAxes.
	axes title: 'stepfilled'.
	self assert: axes title equals: 'stepfilled'
]

{ #category : 'tests - interaction' }
BpAxesTest >> testWhenPatchDoReceivesTheClickedBar [

	| axes histogram clicked |
	clicked := nil.
	axes := self newAxes.
	histogram := axes hist: #( 1 1 1 3 ).
	histogram
		bins: #( 0 2 4 );
		whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	self click: axes atData: 3 @ 0.5.
	self assert: clicked identicalTo: histogram patches second
]

{ #category : 'tests - scatter' }
BpAxesTest >> testWhenPatchDoReceivesTheClickedMarker [

	| axes scatter clicked |
	clicked := nil.
	axes := self newAxes.
	scatter := axes scatterX: #( 0 5 10 ) y: #( 0 5 10 ).
	scatter
		s: 400;
		whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	self click: axes atData: 5 @ 5.
	self assert: clicked index equals: 2
]

{ #category : 'tests - interaction' }
BpAxesTest >> testWhenPatchDoSurvivesARebuild [

	| axes histogram clicked |
	clicked := nil.
	axes := self newAxes.
	histogram := axes hist: #( 1 1 1 3 ).
	histogram whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	histogram bins: #( 0 2 4 ).
	self click: axes atData: 1 @ 0.5.
	self assert: clicked identicalTo: histogram patches first
]

{ #category : 'tests' }
BpAxesTest >> testXLimitsHaveFivePercentMargins [

	| axes |
	axes := self newAxes.
	(axes hist: #( 1 )) bins: #( 0 10 ).
	self assert: axes xLimits equals: #( -0.5 10.5 )
]

{ #category : 'tests - plot' }
BpAxesTest >> testXTicksAreTheGivenLocations [

	| axes |
	axes := BpAxes new.
	axes plotX: #( 0 10 ) y: #( 0 10 ).
	axes xTicks: (1 to: 7).
	self
		assert: ((axes ticks select: [ :each | each axis = #x ]) collect: [ :each | each location ] as: Array)
		equals: #( 1 2 3 4 5 6 7 )
]

{ #category : 'tests' }
BpAxesTest >> testYLimitsStickToZero [

	| axes |
	axes := self newAxes.
	(axes hist: #( 1 1 )) bins: #( 0 10 ).
	self assert: axes yLimits first equals: 0.
	self assert: axes yLimits last closeTo: 2.1
]

{ #category : 'tests - plot' }
BpAxesTest >> testYTicksAreTheGivenLocations [

	| axes |
	axes := BpAxes new.
	axes plotX: #( 0 10 ) y: #( 0 10 ).
	axes yTicks: #( 2 4 ).
	self
		assert: ((axes ticks select: [ :each | each axis = #y ]) collect: [ :each | each label text asString ] as: Array)
		equals: #( '2' '4' )
]
