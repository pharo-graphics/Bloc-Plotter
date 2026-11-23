"
I test `BpDensityPlot`: its curves and areas, their styles, the legend and the interaction.
"
Class {
	#name : 'BpDensityPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpDensityPlotTest >> areasOf: aPlot [

	^ aPlot patches select: [ :each | each isClosed ]
]

{ #category : 'tests' }
BpDensityPlotTest >> curvesOf: aPlot [

	^ aPlot patches reject: [ :each | each isClosed ]
]

{ #category : 'tests' }
BpDensityPlotTest >> newChart [

	^ BpChart new
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpDensityPlotTest >> newPlot [

	^ self newChart densityPlot: #( 0 1 2 3 10 )
]

{ #category : 'tests' }
BpDensityPlotTest >> testAlphaIsTheOneOfTheArea [

	| plot |
	plot := self newPlot.
	plot alpha: 0.7.
	self assert: (self areasOf: plot) first background paint color alpha closeTo: 0.7 precision: 0.01
]

{ #category : 'tests' }
BpDensityPlotTest >> testAnAreaAndACurvePerDataset [

	| plot |
	plot := self twoPlots.
	self assert: (self areasOf: plot) size equals: 2.
	self assert: (self curvesOf: plot) size equals: 2.
	self assert: ((self curvesOf: plot) collect: [ :each | each dataset ] as: Array) equals: #( 1 2 )
]

{ #category : 'tests' }
BpDensityPlotTest >> testAreaGoesDownToZero [

	| plot area |
	plot := self newPlot.
	area := (self areasOf: plot) first.
	self assert: area dataVertices first y equals: 0.
	self assert: area dataVertices last y equals: 0.
	self assert: area dataVertices size equals: 202
]

{ #category : 'tests' }
BpDensityPlotTest >> testAreaIsTransparentAndTheCurveOpaque [

	| plot |
	plot := self newPlot.
	self assert: (self areasOf: plot) first background paint color alpha closeTo: 0.3 precision: 0.01.
	self assert: (self curvesOf: plot) first border paint color alpha equals: 1
]

{ #category : 'tests' }
BpDensityPlotTest >> testBandwidthChangesTheEstimate [

	| plot |
	plot := self newPlot.
	plot bandwidth: 0.5.
	self assert: plot estimates first factor equals: 0.5
]

{ #category : 'tests' }
BpDensityPlotTest >> testColorPerDataset [

	| plot colors |
	colors := {
		          (BpQualitativePalette set1 colorAt: 3).
		          (BpQualitativePalette set1 colorAt: 4) }.
	plot := self twoPlots.
	plot color: colors.
	self assert: ((self curvesOf: plot) collect: [ :each | each border paint color ] as: Array) equals: colors
]

{ #category : 'tests' }
BpDensityPlotTest >> testCurveGoesThreeBandwidthsBeyondTheValues [

	| plot bandwidth vertices |
	plot := self newPlot.
	bandwidth := plot estimates first bandwidth.
	vertices := (self curvesOf: plot) first dataVertices.
	self assert: vertices first x closeTo: 0 - (3 * bandwidth) precision: 1.0e-9.
	self assert: vertices last x closeTo: 10 + (3 * bandwidth) precision: 1.0e-9
]

{ #category : 'tests' }
BpDensityPlotTest >> testCurveHasTwoHundredPointsByDefault [

	self assert: (self curvesOf: self newPlot) first dataVertices size equals: 200
]

{ #category : 'tests' }
BpDensityPlotTest >> testCurveIsTheKernelDensity [

	| plot density |
	plot := self newPlot.
	density := BpKernelDensity of: #( 0 1 2 3 10 ) bandwidth: #scott.
	(self curvesOf: plot) first dataVertices do: [ :each |
		self assert: each y closeTo: (density densityAt: each x) precision: 1.0e-9 ]
]

{ #category : 'tests' }
BpDensityPlotTest >> testCurvesAreDrawnAboveTheAreas [

	self assert: (self twoPlots patches collect: [ :each | each isClosed ] as: Array) equals: #( true true false false )
]

{ #category : 'tests' }
BpDensityPlotTest >> testCutZeroStopsAtTheValues [

	| plot vertices |
	plot := self newPlot.
	plot cut: 0.
	vertices := (self curvesOf: plot) first dataVertices.
	self assert: vertices first x equals: 0.
	self assert: vertices last x equals: 10
]

{ #category : 'tests' }
BpDensityPlotTest >> testDatasetsTakeTheColorsOfThePalette [

	| plot |
	plot := self twoPlots.
	self assert: ((self curvesOf: plot) collect: [ :each | each border paint color ] as: Array) equals: {
		(BpPalette default colorAt: 1).
		(BpPalette default colorAt: 2) }
]

{ #category : 'tests' }
BpDensityPlotTest >> testDensityPlotAddsADensityPlot [

	| chart plot |
	chart := self newChart.
	plot := chart densityPlot: #( 1 2 3 ).
	self assert: plot class equals: BpDensityPlot.
	self assert: chart artists asArray equals: { plot }
]

{ #category : 'tests - errors' }
BpDensityPlotTest >> testEqualValuesRaiseError [

	self
		should: [ self newChart densityPlot: #( 2 2 ) ]
		raise: Error
		whoseDescriptionIncludes: 'two different values'
		description: 'equal values have no deviation'
]

{ #category : 'tests' }
BpDensityPlotTest >> testFillFalseDrawsTheCurvesOnly [

	| plot |
	plot := self twoPlots.
	plot fill: false.
	self assert: (self areasOf: plot) isEmpty.
	self assert: (self curvesOf: plot) size equals: 2
]

{ #category : 'tests' }
BpDensityPlotTest >> testHorizontalSwapsTheAxes [

	| plot vertical |
	plot := self newPlot.
	vertical := (self curvesOf: plot) first dataVertices.
	plot orientation: #horizontal.
	self assert: (self curvesOf: plot) first dataVertices equals: (vertical collect: [ :each | each y @ each x ])
]

{ #category : 'tests' }
BpDensityPlotTest >> testLegendHasTheLabelOfEachDataset [

	| plot |
	plot := self twoPlots.
	plot label: #( 'a' 'b' ).
	self assert: (plot legendEntries collect: [ :each | each key ] as: Array) equals: #( 'a' 'b' )
]

{ #category : 'tests' }
BpDensityPlotTest >> testLimitsStickToZero [

	self assert: self newPlot chart yLimits first equals: 0
]

{ #category : 'tests' }
BpDensityPlotTest >> testLineWidthAndStyle [

	| plot border |
	plot := self newPlot.
	plot
		lineWidth: 3;
		lineStyle: '--'.
	border := (self curvesOf: plot) first border.
	self assert: border width equals: 3 * BpArtist pixelsPerPoint.
	self deny: border style dashArray isEmpty
]

{ #category : 'tests' }
BpDensityPlotTest >> testMoreDatasetsThanColors [

	| plot |
	plot := self newChart densityPlot: ((1 to: 12) collect: [ :each |
		         {
			         each.
			         (each + 1) } ]).
	self assert: (self curvesOf: plot) last border paint color equals: (BpPalette default colorAt: 12)
]

{ #category : 'tests' }
BpDensityPlotTest >> testNoLegendWithoutLabel [

	self assert: self twoPlots legendEntries isEmpty
]

{ #category : 'tests' }
BpDensityPlotTest >> testOneLabelIsTheOneOfTheFirstDataset [

	| plot |
	plot := self twoPlots.
	plot label: 'a'.
	self assert: (plot legendEntries collect: [ :each | each key ] as: Array) equals: #( 'a' )
]

{ #category : 'tests' }
BpDensityPlotTest >> testPoints [

	| plot |
	plot := self newPlot.
	plot points: 50.
	self assert: (self curvesOf: plot) first dataVertices size equals: 50
]

{ #category : 'tests - errors' }
BpDensityPlotTest >> testUnknownLineStyleRaisesError [

	| plot |
	plot := self newPlot.
	self
		should: [ plot lineStyle: 'wavy' ]
		raise: Error
		whoseDescriptionIncludes: 'Unknown line style'
		description: 'the line style is unknown'
]

{ #category : 'tests - errors' }
BpDensityPlotTest >> testUnknownOrientationRaisesError [

	| plot |
	plot := self newPlot.
	self
		should: [ plot orientation: #diagonal ]
		raise: Error
		whoseDescriptionIncludes: 'Unknown orientation'
		description: 'the orientation is unknown'
]

{ #category : 'tests' }
BpDensityPlotTest >> testWhenPatchDoReceivesTheClickedArea [

	| plot chart clicked |
	clicked := nil.
	plot := self newPlot.
	plot whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	chart := plot chart.
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		chart eventSimulator clickAt: chart plotBounds origin + (chart dataTransform pointFor: 2 @ 0.02) ].
	self assert: clicked identicalTo: (self areasOf: plot) first
]

{ #category : 'tests' }
BpDensityPlotTest >> twoPlots [

	^ self newChart densityPlot: #( #( 0 1 2 ) #( 5 6 9 ) )
]
