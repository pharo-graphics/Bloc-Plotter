"
I test `BpPolarChart`: its limits, ticks, grid, round plot area, legend and title, and the rendering and interaction of its bars.
"
Class {
	#name : 'BpPolarChartTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpPolarChartTest >> clickedPatchOf: aChart at: aDataPoint [
	"Answer the bar of aChart a click at aDataPoint (an angle @ a radius) reaches, nil when it reaches none."

	| clicked |
	clicked := nil.
	aChart artists first whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	aChart inNewHeadlessSpaceDo: [ :space |
		space settle.
		aChart eventSimulator clickAt: aChart plotBounds origin + (aChart dataTransform pointFor: aDataPoint) ].
	^ clicked
]

{ #category : 'tests' }
BpPolarChartTest >> labelsOn: anAxis of: aChart [

	^ (aChart ticks select: [ :each | each axis = anAxis ] thenCollect: [ :each | each label text asString ]) asArray
]

{ #category : 'tests' }
BpPolarChartTest >> newChart [

	^ BpPolarChart new
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpPolarChartTest >> newChartOfTwoBars [
	"Answer a chart with a bar on the right and one on the left, each a quarter turn wide."

	| chart |
	chart := self newChart.
	(chart
		 barXValues: {
			 0.
			 Float pi }
		 heightValues: #( 10 10 )) width: Float halfPi.
	^ chart
]

{ #category : 'tests' }
BpPolarChartTest >> testAnglesAreLabeledInDegrees [

	self
		assert: (self labelsOn: #x of: self newChart)
		equals: (#( 0 45 90 135 180 225 270 315 ) collect: [ :each | each printString , '°' ])
]

{ #category : 'tests' }
BpPolarChartTest >> testBarIsPaintedInItsSector [
	"A bar centered on the top, one eighth of a turn wide on each side."

	| chart color form center radius |
	color := BpQualitativePalette set1 colorAt: 1.
	chart := self newChart.
	chart grid: false.
	(chart barXValues: { Float halfPi } heightValues: #( 10 ))
		width: Float halfPi;
		color: color.
	chart yLimits: #( 0 10 ).
	chart yTicks: #(  ).
	form := chart asForm.
	center := chart plotBounds center.
	radius := chart plotBounds width / 2.
	self assert: (form colorAt: (center - (0 @ (radius * 0.9))) rounded) equals: color.
	self assert: (form colorAt: (center + (0 @ (radius * 0.9))) rounded) equals: Color white.
	self assert: (form colorAt: (center + (radius * 0.9 @ 0)) rounded) equals: Color white
]

{ #category : 'tests' }
BpPolarChartTest >> testBarsStandOnTheirBottom [

	| chart color form center radius |
	color := BpQualitativePalette set1 colorAt: 1.
	chart := self newChart.
	chart grid: false.
	(chart barXValues: { Float halfPi } heightValues: #( 5 ))
		width: Float halfPi;
		bottom: 5;
		color: color.
	chart yLimits: #( 0 10 ).
	chart yTicks: #(  ).
	form := chart asForm.
	center := chart plotBounds center.
	radius := chart plotBounds width / 2.
	self assert: (form colorAt: (center - (0 @ (radius * 0.75))) rounded) equals: color.
	self assert: (form colorAt: (center - (0 @ (radius * 0.25))) rounded) equals: Color white
]

{ #category : 'tests' }
BpPolarChartTest >> testCirclesOfTheGridAreCentered [

	| chart circle |
	chart := self newChart.
	chart yLimits: #( 0 10 ).
	chart yTicks: #( 5 ).
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		circle := chart plotArea gridLines detect: [ :each | each axis = #y ].
		self assert: circle bounds inParent center equals: chart plotArea extent / 2.
		self assert: circle width closeTo: chart plotArea width / 2 ]
]

{ #category : 'tests' }
BpPolarChartTest >> testClickBetweenTheSectorsReachesNoBar [

	self assert: (self clickedPatchOf: self newChartOfTwoBars at: Float halfPi @ 5) isNil
]

{ #category : 'tests' }
BpPolarChartTest >> testClickInTheSectorReachesTheBar [

	| chart |
	chart := self newChartOfTwoBars.
	self assert: (self clickedPatchOf: chart at: Float pi @ 5) identicalTo: chart patches second
]

{ #category : 'tests' }
BpPolarChartTest >> testCounterClockFalseTurnsClockwise [

	| chart |
	chart := self newChart.
	chart counterClock: false.
	self deny: chart dataTransform counterClock
]

{ #category : 'tests' }
BpPolarChartTest >> testEmptyChartHasRadiiFromZeroToOne [

	self assert: self newChart yLimits equals: #( 0 1 )
]

{ #category : 'tests' }
BpPolarChartTest >> testGridFalseRemovesTheLines [

	| chart |
	chart := self newChart.
	chart grid: false.
	self assert: chart plotArea gridLines isEmpty
]

{ #category : 'tests' }
BpPolarChartTest >> testGridIsShownByDefault [

	| chart |
	chart := self newChart.
	chart barXValues: #( 0 1 ) heightValues: #( 5 8.5 ).
	self assert: (chart plotArea gridLines count: [ :each | each axis = #x ]) equals: 8.
	self assert: (chart plotArea gridLines count: [ :each | each axis = #y ]) equals: 4
]

{ #category : 'tests' }
BpPolarChartTest >> testHistogramsAreRoses [

	| chart histogram |
	chart := self newChart.
	histogram := (chart addArtist: (BpHistogram xValues: #( 1 1 2 )))
		             bins: #( 0 1.5 3 );
		             yourself.
	self assert: (histogram patches allSatisfy: [ :each | each geometry isKindOf: BlAnnulusSectorGeometry ])
]

{ #category : 'tests' }
BpPolarChartTest >> testLabelsStayInTheChart [

	| chart |
	chart := self newChart.
	chart
		title: 'A title';
		xTickFormatter: [ :each | 'a rather long label' ].
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: (chart ticks allSatisfy: [ :each |
			 ((0 @ 0 extent: chart extent) expandBy: 0.01) containsRect: each label bounds inParent asRectangle ]) ]
]

{ #category : 'tests' }
BpPolarChartTest >> testLegendIsInTheUpperRightCorner [

	| chart |
	chart := self newChart.
	(chart barXValues: #( 0 1 ) heightValues: #( 5 10 )) label: 'bars'.
	chart legend.
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: chart legendElement bounds inParent right closeTo: chart width - 6.
		self assert: chart legendElement position y closeTo: 6 ]
]

{ #category : 'tests' }
BpPolarChartTest >> testLegendIsOutsideThePlotArea [

	| chart |
	chart := self newChart.
	(chart barXValues: #( 0 1 ) heightValues: #( 5 10 )) label: 'bars'.
	chart legend.
	self assert: chart legendElement labels asArray equals: #( 'bars' ).
	self assert: chart legendElement parent identicalTo: chart
]

{ #category : 'tests' }
BpPolarChartTest >> testLegendIsReplacedAtEachRebuild [

	| chart bars |
	chart := self newChart.
	bars := chart barXValues: #( 0 1 ) heightValues: #( 5 10 ).
	bars label: 'bars'.
	chart legend.
	bars label: 'others'.
	self assert: (chart children asArray count: [ :each | each isKindOf: BpLegend ]) equals: 1.
	self assert: chart legendElement labels asArray equals: #( 'others' )
]

{ #category : 'tests' }
BpPolarChartTest >> testNegativeRadiiMoveTheCenter [

	| chart |
	chart := self newChart.
	chart addArtist: (BpLine x: #( 0 1 ) y: #( -5 10 )).
	self assert: chart yLimits first equals: -5
]

{ #category : 'tests' }
BpPolarChartTest >> testNoLegendByDefault [

	| chart |
	chart := self newChart.
	(chart barXValues: #( 0 1 ) heightValues: #( 5 10 )) label: 'bars'.
	self assert: chart legendElement isNil
]

{ #category : 'tests' }
BpPolarChartTest >> testPlotAreaIsSquare [

	| chart |
	chart := self newChart.
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: chart plotArea width equals: chart plotArea height.
		self assert: chart plotArea width > 200 ]
]

{ #category : 'tests' }
BpPolarChartTest >> testRadiiHaveAMarginAtTheEdge [

	| chart |
	chart := self newChart.
	chart barXValues: #( 0 1 ) heightValues: #( 5 10 ).
	self assert: chart yLimits last closeTo: 10.5
]

{ #category : 'tests' }
BpPolarChartTest >> testRadiiStartAtZero [

	| chart |
	chart := self newChart.
	chart addArtist: (BpLine x: #( 0 1 ) y: #( 5 10 )).
	self assert: chart yLimits first equals: 0
]

{ #category : 'tests' }
BpPolarChartTest >> testStartAngleTurnsTheChart [

	| chart |
	chart := self newChart.
	chart startAngle: 90.
	self assert: chart dataTransform startAngle equals: 90.
	self assert: chart startAngle equals: 90
]

{ #category : 'tests' }
BpPolarChartTest >> testTheCenterHasNoTick [

	| chart |
	chart := self newChart.
	chart barXValues: #( 0 1 ) heightValues: #( 5 8.5 ).
	self assert: (self labelsOn: #y of: chart) equals: #( '2' '4' '6' '8' )
]

{ #category : 'tests' }
BpPolarChartTest >> testTitleIsAboveTheLabels [

	| chart top |
	chart := self newChart.
	chart title: 'A title'.
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		top := (chart ticks collect: [ :each | each label position y ]) min.
		self assert: chart titleElement bounds inParent bottom <= top.
		self assert: chart titleElement position y >= 0 ]
]

{ #category : 'tests' }
BpPolarChartTest >> testXTickFormatterLabelsTheAngles [

	| chart |
	chart := self newChart.
	chart
		xTicks: #( 0 1 );
		xTickFormatter: [ :each | 'a' , each printString ].
	self assert: (self labelsOn: #x of: chart) equals: #( 'a0' 'a1' )
]

{ #category : 'tests' }
BpPolarChartTest >> testXTicksAreAngles [

	| chart |
	chart := self newChart.
	chart xTicks: {
		0.
		Float pi }.
	self assert: (self labelsOn: #x of: chart) equals: #( '0°' '180°' )
]

{ #category : 'tests' }
BpPolarChartTest >> testYLimitsReplaceTheRadii [

	| chart |
	chart := self newChart.
	chart barXValues: #( 0 1 ) heightValues: #( 5 10 ).
	chart yLimits: #( 0 20 ).
	self assert: chart yLimits equals: #( 0 20 )
]
