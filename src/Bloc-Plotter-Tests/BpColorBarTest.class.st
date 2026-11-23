"
I test `BpColorBar`: its ticks, its colors, its label, and its place in charts and alone.
"
Class {
	#name : 'BpColorBarTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpColorBarTest >> labelsOf: aColorBar [

	^ aColorBar ticks collect: [ :each | each label text asString ] as: Array
]

{ #category : 'tests' }
BpColorBarTest >> newBar [

	| heatmap |
	heatmap := self newHeatmap.
	^ heatmap chart addColorBarFor: heatmap
]

{ #category : 'tests' }
BpColorBarTest >> newChart [

	^ BpChart new
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpColorBarTest >> newHeatmap [
	"Answer a heatmap of numbers from 0 to 50, in shades of grey."

	^ (self newChart heatmap: #( #( 0 10 ) #( 20 50 ) ))
		  colorMap: [ :fraction | Color gray: fraction ];
		  yourself
]

{ #category : 'tests' }
BpColorBarTest >> testAddColorBarForAnswersAColorBarOfTheChart [

	| heatmap bar |
	heatmap := self newHeatmap.
	bar := heatmap chart addColorBarFor: heatmap.
	self assert: bar class equals: BpColorBar.
	self assert: bar parent identicalTo: heatmap chart.
	self assert: heatmap chart colorBars asArray equals: { bar }
]

{ #category : 'tests' }
BpColorBarTest >> testAlphaOfTheArtistIsShown [

	| heatmap bar |
	heatmap := self newHeatmap.
	heatmap alpha: 0.5.
	bar := heatmap chart addColorBarFor: heatmap.
	self assert: (bar strip background paint stops first value alpha closeTo: 0.5 precision: 0.01)
]

{ #category : 'tests - errors' }
BpColorBarTest >> testArtistWithoutNumbersRaisesError [

	| chart line |
	chart := self newChart.
	line := chart plotX: #( 1 2 ) y: #( 1 2 ).
	self
		should: [ chart addColorBarFor: line ]
		raise: Error
		whoseDescriptionIncludes: 'shows no numbers by colors'
		description: 'a line has no color scale'
]

{ #category : 'tests' }
BpColorBarTest >> testBarIsBesideThePlotArea [

	| bar bounds plot |
	bar := self newBar.
	bar parent asForm.
	plot := bar parent plotBounds.
	bounds := bar bounds inParent.
	self assert: bounds left > plot right.
	self assert: bounds right <= 400.
	self assert: bounds top equals: plot top.
	self assert: bounds height equals: plot height
]

{ #category : 'tests' }
BpColorBarTest >> testBarLeavesRoomInAPolarChart [

	| chart scatter bar |
	chart := BpPolarChart new
		         extent: 300 @ 300;
		         yourself.
	scatter := chart scatterX: #( 0 1 ) y: #( 1 2 ).
	scatter c: #( 1 2 ).
	bar := chart addColorBarFor: scatter.
	chart asForm.
	self assert: bar bounds inParent left > chart plotBounds right
]

{ #category : 'tests' }
BpColorBarTest >> testFixedTicksInTheLimitsAreShown [

	| bar |
	bar := self newBar.
	bar tickLocations: #( -5 0 25 60 ).
	self assert: (self labelsOf: bar) equals: #( '0' '25' )
]

{ #category : 'tests' }
BpColorBarTest >> testFollowsTheChangesOfItsArtist [

	| heatmap bar |
	heatmap := self newHeatmap.
	bar := heatmap chart addColorBarFor: heatmap.
	heatmap vMax: 20.
	self assert: bar ticks last location equals: 20
]

{ #category : 'tests' }
BpColorBarTest >> testHexbinHasAColorBar [

	| chart hexbin |
	chart := self newChart.
	hexbin := chart hexbinX: #( 1 1 2 ) y: #( 1 1 2 ).
	hexbin gridSize: 2.
	self assert: (chart addColorBarFor: hexbin) ticks last location equals: 2
]

{ #category : 'tests' }
BpColorBarTest >> testHighestNumberIsPaintedAtTheTop [

	| bar form strip colorAt |
	bar := self newBar.
	form := bar parent asForm.
	strip := bar position + bar strip position extent: bar strip extent.
	colorAt := [ :fraction | (form colorAt: (strip center x @ (strip bottom - (strip height * fraction))) rounded) red ].
	self assert: ((colorAt value: 0.02) closeTo: 0 precision: 0.05).
	self assert: ((colorAt value: 0.5) closeTo: 0.5 precision: 0.05).
	self assert: ((colorAt value: 0.98) closeTo: 1 precision: 0.05)
]

{ #category : 'tests' }
BpColorBarTest >> testLabel [

	| bar |
	bar := self newBar.
	bar label: 'density'.
	self assert: bar label equals: 'density'
]

{ #category : 'tests' }
BpColorBarTest >> testLabelMakesTheBarWider [

	| bar width |
	bar := self newBar.
	bar parent asForm.
	width := bar measuredExtent x.
	bar label: 'density'.
	bar parent asForm.
	self assert: bar measuredExtent x > width
]

{ #category : 'tests' }
BpColorBarTest >> testLabelOfTheLowestTickIsNotCut [

	| bar form label left bottom |
	bar := self newBar.
	form := bar parent asForm.
	label := bar ticks first label.
	left := (bar position x + label position x) rounded.
	bottom := (bar position y + bar strip extent y) rounded.
	self assert: ((left to: left + label extent x rounded) anySatisfy: [ :x |
		 (bottom + 2 to: bottom + 5) anySatisfy: [ :y | (form colorAt: x @ y) luminance < 0.5 ] ])
]

{ #category : 'tests' }
BpColorBarTest >> testLogScaleHasPowersOfTen [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap vMin: 1.
	heatmap vMax: 100.
	heatmap scale: #log.
	self assert: ((heatmap chart addColorBarFor: heatmap) ticks collect: [ :each | each location ] as: Array) equals: #( 1 10 100 )
]

{ #category : 'tests' }
BpColorBarTest >> testNoColorBarByDefault [

	self assert: self newHeatmap chart colorBars isEmpty
]

{ #category : 'tests' }
BpColorBarTest >> testNoLabelByDefault [

	self assert: self newBar label equals: ''
]

{ #category : 'tests' }
BpColorBarTest >> testOneNumberHasOneTick [

	| chart heatmap |
	chart := self newChart.
	heatmap := chart heatmap: #( #( 5 5 ) ).
	self assert: (self labelsOf: (chart addColorBarFor: heatmap)) equals: #( '5' )
]

{ #category : 'tests' }
BpColorBarTest >> testScatterOfNumbersHasAColorBar [

	| chart scatter |
	chart := self newChart.
	scatter := chart scatterX: #( 1 2 ) y: #( 1 2 ).
	scatter c: #( 0 100 ).
	self assert: (chart addColorBarFor: scatter) ticks last location equals: 100
]

{ #category : 'tests - errors' }
BpColorBarTest >> testScatterOfOneColorRaisesError [

	| chart scatter |
	chart := self newChart.
	scatter := chart scatterX: #( 1 2 ) y: #( 1 2 ).
	self
		should: [ chart addColorBarFor: scatter ]
		raise: Error
		whoseDescriptionIncludes: 'shows no numbers by colors'
		description: 'the points have one color'
]

{ #category : 'tests' }
BpColorBarTest >> testStandsAlone [

	| bar |
	bar := BpColorBar on: self newHeatmap.
	bar asForm.
	self assert: bar extent y equals: 200.
	self assert: bar extent x > bar strip extent x
]

{ #category : 'tests' }
BpColorBarTest >> testThickness [

	| bar |
	bar := self newBar.
	bar thickness: 30.
	bar parent asForm.
	self assert: bar strip extent x equals: 30
]

{ #category : 'tests' }
BpColorBarTest >> testTickCount [

	| bar |
	bar := self newBar.
	bar tickCount: 3.
	self assert: (self labelsOf: bar) equals: #( '0' '20' '40' )
]

{ #category : 'tests' }
BpColorBarTest >> testTickFormatterGivesTheLabels [

	| bar |
	bar := self newBar.
	bar
		tickCount: 3;
		tickFormatter: [ :value | value printString , '%' ].
	self assert: (self labelsOf: bar) equals: #( '0%' '20%' '40%' )
]

{ #category : 'tests' }
BpColorBarTest >> testTickIsBesideItsColor [

	| bar tick |
	bar := self newBar.
	bar parent asForm.
	tick := bar ticks detect: [ :each | each location = 10 ].
	self assert: (tick mark bounds inParent center y closeTo: bar strip extent y * 0.8 precision: 1).
	self assert: tick mark bounds inParent left >= bar strip bounds inParent right
]

{ #category : 'tests' }
BpColorBarTest >> testTicksAreNiceNumbersInTheLimits [

	self assert: (self labelsOf: self newBar) equals: #( '0' '10' '20' '30' '40' '50' )
]

{ #category : 'tests' }
BpColorBarTest >> testTwoBarsAreSideBySide [

	| heatmap first second |
	heatmap := self newHeatmap.
	first := heatmap chart addColorBarFor: heatmap.
	second := heatmap chart addColorBarFor: heatmap.
	heatmap chart asForm.
	self assert: second bounds inParent left > first bounds inParent right.
	self assert: second bounds inParent right <= 400
]
