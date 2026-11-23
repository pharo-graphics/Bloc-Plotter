"
I check `BpBarPlot`, as `BpChart>>barX:height:` and `BpChart>>barhY:width:` create it: the rectangle of each bar (position, width, bottom, alignment, orientation), the broadcasting of settings given once, categories and tick labels, styles, legend entries, sticky bottoms and log scale.

## Implementation Notes

- My fixture has three bars at 1, 2 and 3, 4, 5 and 6 high, with the default width 0.8.
- The bar plot is not in a figure: the bars are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpBarPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpBarPlotTest >> bars [
	"Three bars at 1, 2 and 3, 4, 5 and 6 high."

	^ BpBarPlot new
		  x: #( 1 2 3 ) height: #( 4 5 6 );
		  yourself
]

{ #category : 'tests' }
BpBarPlotTest >> ppp [

	^ BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpBarPlotTest >> testAlphaMakesTheBarsTransparent [

	self assert: ((self bars
		  alpha: 0.5;
		  yourself) patches first background paint color alpha closeTo: 0.5 precision: 0.01)
]

{ #category : 'tests' }
BpBarPlotTest >> testBarsAreBelowTheGrid [

	self deny: self bars isAboveGrid
]

{ #category : 'tests' }
BpBarPlotTest >> testBarsAreCenteredOnTheirPositionsAndEightTenthsWide [

	self assert: self bars patches first dataBounds equals: (0.6 @ 0 corner: 1.4 @ 4)
]

{ #category : 'tests' }
BpBarPlotTest >> testBarsHaveNoOutlineByDefault [

	self assert: self bars patches first border width equals: 0
]

{ #category : 'tests' }
BpBarPlotTest >> testBarsKnowTheirIndexAndHeight [

	| bar |
	bar := self bars patches second.
	self assert: bar bin equals: 2.
	self assert: bar amount equals: 5
]

{ #category : 'tests' }
BpBarPlotTest >> testBarsTakeTheFirstColorOfTheCycle [

	self assert: self bars patches first background paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests' }
BpBarPlotTest >> testBottomsAreStickyOnTheValueAxis [

	| bars |
	bars := self bars
		        bottom: 1;
		        yourself.
	self assert: (bars stickyValuesOn: #y) equals: #( 1 ).
	self assert: (bars stickyValuesOn: #x) isEmpty
]

{ #category : 'tests' }
BpBarPlotTest >> testCategoriesArePositionedFromZero [

	| bars |
	bars := BpBarPlot new
		        x: #( 'apple' 'cherry' 'apple' ) height: #( 1 2 3 );
		        yourself.
	self assert: bars positions equals: #( 0 1 0 ).
	self assert: bars patches first dataBounds equals: (-0.4 @ 0 corner: 0.4 @ 1)
]

{ #category : 'tests' }
BpBarPlotTest >> testCategoriesAreTheTicksOfThePositionAxis [

	| bars |
	bars := BpBarPlot new
		        x: #( 'apple' 'cherry' 'apple' ) height: #( 1 2 3 );
		        yourself.
	self assert: (bars managedTicksOn: #x) equals: {
		(0 -> 'apple').
		(1 -> 'cherry') }.
	self assert: (bars managedTicksOn: #y) isNil
]

{ #category : 'tests' }
BpBarPlotTest >> testChartBarAddsABarPlot [

	| chart bars |
	chart := BpChart new.
	bars := chart barX: #( 1 2 ) height: #( 3 4 ).
	self assert: bars chart identicalTo: chart.
	self assert: (chart artists includes: bars).
	self assert: bars patches size equals: 2
]

{ #category : 'tests' }
BpBarPlotTest >> testChartBarhAddsHorizontalBars [

	| bars |
	bars := (BpChart new barhY: #( 1 2 ) width: #( 3 4 ))
		        width: 1 / 2;
		        yourself.
	self assert: bars orientation equals: #horizontal.
	self assert: bars patches second dataBounds equals: (0 @ (7 / 4) corner: 4 @ (9 / 4))
]

{ #category : 'tests' }
BpBarPlotTest >> testColorPerBar [

	self
		assert: ((self bars
			  color: {
	Color red.
	Color blue.
	Color red };
			  yourself) patches collect: [ :each | each background paint color ] as: Array)
		equals: {
			Color red.
			Color blue.
			Color red }
]

{ #category : 'tests' }
BpBarPlotTest >> testEdgeAlignStartsTheBarsAtTheirPositions [

	self
		assert: (self bars
			 align: #edge;
			 yourself) patches first dataBounds
		equals: (1 @ 0 corner: 1.8 @ 4)
]

{ #category : 'tests' }
BpBarPlotTest >> testEdgeColorAndLineWidthOutlineTheBars [

	| bar |
	bar := (self bars edgeColor: Color white;
		        lineWidth: 0.7;
		        yourself) patches first.
	self assert: bar border paint color equals: Color white.
	self assert: (bar border width closeTo: 0.7 * self ppp)
]

{ #category : 'tests' }
BpBarPlotTest >> testHandlersAreKeptWhenTheBarsAreRebuilt [

	| bars clicked |
	bars := self bars.
	clicked := nil.
	bars whenPatch: BlClickEvent do: [ :event :bar | clicked := bar ].
	bars color: Color red.
	BlEvent fireEvent: BlClickEvent new target: bars patches second.
	self assert: clicked identicalTo: bars patches second
]

{ #category : 'tests - errors' }
BpBarPlotTest >> testHeightsOfAnotherSizeRaiseError [

	self should: [ BpBarPlot new x: #( 1 2 3 ) height: #( 1 2 ) ] raise: Error
]

{ #category : 'tests' }
BpBarPlotTest >> testHorizontalBottomsAreStickyOnTheXAxis [

	self
		assert: ((self bars
			  orientation: #horizontal;
			  yourself) stickyValuesOn: #x)
		equals: #( 0 )
]

{ #category : 'tests' }
BpBarPlotTest >> testHorizontalSwapsTheCoordinates [

	self
		assert: (self bars
			 orientation: #horizontal;
			 yourself) patches first dataBounds
		equals: (0 @ 0.6 corner: 4 @ 1.4)
]

{ #category : 'tests' }
BpBarPlotTest >> testHorizontalTicksAreOnTheYAxis [

	| bars |
	bars := self bars
		        orientation: #horizontal;
		        tickLabel: #( 'a' 'b' 'c' );
		        yourself.
	self assert: (bars managedTicksOn: #x) isNil.
	self assert: (bars managedTicksOn: #y) size equals: 3
]

{ #category : 'tests' }
BpBarPlotTest >> testLabelGivesOneLegendEntry [

	self
		assert: ((self bars
			  label: 'data';
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'data' )
]

{ #category : 'tests' }
BpBarPlotTest >> testLabelPerBarGivesAnEntryPerBarButHidesUnderscoreLabels [

	self
		assert: ((self bars
			  label: #( 'red' 'blue' '_red' );
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'red' 'blue' )
]

{ #category : 'tests' }
BpBarPlotTest >> testLegendSwatchHasTheColorOfItsBar [

	self
		assert: (self bars
			 color: {
	Color red.
	Color blue.
	Color green };
			 label: #( 'red' 'blue' 'green' );
			 yourself) legendEntries second value background paint color
		equals: Color blue
]

{ #category : 'tests' }
BpBarPlotTest >> testLogPutsTheValueAxisOnALogScale [

	self assert: self bars logAxes isEmpty.
	self
		assert: (self bars
			 log: true;
			 yourself) logAxes
		equals: #( #y ).
	self
		assert: (self bars
			 log: true;
			 orientation: #horizontal;
			 yourself) logAxes
		equals: #( #x )
]

{ #category : 'tests - errors' }
BpBarPlotTest >> testMixedNumbersAndCategoriesRaiseError [

	self should: [ BpBarPlot new x: #( 1 'apple' ) height: #( 1 2 ) ] raise: Error
]

{ #category : 'tests' }
BpBarPlotTest >> testNegativeWidthWithEdgeAlignEndsTheBarsAtTheirPositions [

	self
		assert: (self bars
			 align: #edge;
			 width: -4 / 5;
			 yourself) patches first dataBounds
		equals: (1 / 5 @ 0 corner: 1 @ 4)
]

{ #category : 'tests' }
BpBarPlotTest >> testNoLabelGivesNoLegendEntry [

	self assert: self bars legendEntries isEmpty
]

{ #category : 'tests' }
BpBarPlotTest >> testNumericPositionsLetTheChartChooseTheTicks [

	self assert: (self bars managedTicksOn: #x) isNil
]

{ #category : 'tests' }
BpBarPlotTest >> testOneBarPerValue [

	self assert: self bars patches size equals: 3
]

{ #category : 'tests' }
BpBarPlotTest >> testOneHeightIsSharedByAllBars [

	self
		assert: ((BpBarPlot new
			  x: #( 1 2 3 ) height: 2;
			  yourself) patches collect: [ :each | each amount ] as: Array)
		equals: #( 2 2 2 )
]

{ #category : 'tests' }
BpBarPlotTest >> testResults [

	| bars |
	bars := self bars.
	self assert: bars positions equals: #( 1 2 3 ).
	self assert: bars dataValues equals: #( 4 5 6 )
]

{ #category : 'tests' }
BpBarPlotTest >> testTickLabelLabelsTheBarsAtTheirPositions [

	self
		assert: ((self bars
			  tickLabel: #( 'a' 'b' 'c' );
			  yourself) managedTicksOn: #x)
		equals: {
			(1 -> 'a').
			(2 -> 'b').
			(3 -> 'c') }
]

{ #category : 'tests - errors' }
BpBarPlotTest >> testUnknownAlignRaisesError [

	self should: [ self bars align: #middle ] raise: Error
]

{ #category : 'tests - errors' }
BpBarPlotTest >> testUnknownOrientationRaisesError [

	self should: [ self bars orientation: #diagonal ] raise: Error
]

{ #category : 'tests' }
BpBarPlotTest >> testWidthAndBottom [

	self
		assert: (self bars
			 width: 0.5;
			 bottom: 1;
			 yourself) patches first dataBounds
		equals: (0.75 @ 1 corner: 1.25 @ 5)
]

{ #category : 'tests' }
BpBarPlotTest >> testWidthAndBottomPerBar [

	self
		assert: (self bars
			 width: #( 0.5 1 2 );
			 bottom: #( 0 1 2 );
			 yourself) patches last dataBounds
		equals: (2 @ 2 corner: 4 @ 8)
]
