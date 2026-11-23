"
I check `BpViolinPlot`, as `BpChart>>violinPlot:` and `BpChart>>violinPlot:positions:` create it: the bodies (shape, positions, widths, sides, orientation, resolution), the lines at the extrema, means, medians and quantiles, colors, line widths and alpha, the drawing order, the legend entry and handlers.

## Implementation Notes

- My fixture draws two violins of three and four values with 5 points each, so that body vertices can be listed. The violins are not in a figure: patches are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpViolinPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpViolinPlotTest >> testAlphaSetsTheOpacityOfTheBodies [

	self assert: (((self violinsWith: [ :violins | violins alpha: 0.9 ]) parts at: #bodies) first background paint color alpha
		 closeTo: 0.9
		 precision: 0.01)
]

{ #category : 'tests' }
BpViolinPlotTest >> testBandwidthIsGivenToTheStatistics [

	self assert: (self violinsWith: [ :violins | violins bandwidth: 0.5 ]) statistics first factor equals: 0.5
]

{ #category : 'tests' }
BpViolinPlotTest >> testBodiesAreTheCycleColorWithAlpha [

	| color |
	color := (self violins parts at: #bodies) first background paint color.
	self assert: (color alpha closeTo: 0.3 precision: 0.01).
	self assert: (color alpha: 1) equals: ((BpPalette default colorAt: 1) alpha: 1)
]

{ #category : 'tests' }
BpViolinPlotTest >> testBodyIsAClosedPolygonThroughBothSidesOfTheDensity [

	| body |
	body := (self violins parts at: #bodies) first.
	self assert: body isClosed.
	self assert: (self verticesOf: body) size equals: 10.
	self assert: (self ysOf: body) equals: #( 1 1.5 2 2.5 3 3 2.5 2 1.5 1 )
]

{ #category : 'tests' }
BpViolinPlotTest >> testBodyIsHalfTheWidthWideAtTheHighestDensity [

	| xs |
	xs := self xsOf: (self violins parts at: #bodies) first.
	self assert: ((xs at: 3) closeTo: 0.75).
	self assert: ((xs at: 8) closeTo: 1.25).
	self assert: xs min equals: (xs at: 3)
]

{ #category : 'tests' }
BpViolinPlotTest >> testChartViolinPlotPositionsAddsTheViolins [

	| chart violins |
	chart := BpChart new.
	violins := chart violinPlot: #( #( 1 2 3 ) #( 2 4 4 6 ) ) positions: #( 2 4 ).
	self assert: chart artists last identicalTo: violins.
	self assert: violins positions equals: #( 2 4 )
]

{ #category : 'tests' }
BpViolinPlotTest >> testExtremaAreShownByDefault [

	| parts |
	parts := self violins parts.
	self assert: (self verticesOf: (parts at: #maxima) first) equals: {
		(0.875 @ 3).
		(1.125 @ 3) }.
	self assert: (self verticesOf: (parts at: #minima) second) equals: {
		(1.875 @ 2).
		(2.125 @ 2) }.
	self assert: (self verticesOf: (parts at: #bars) first) equals: {
		(1 @ 1).
		(1 @ 3) }
]

{ #category : 'tests' }
BpViolinPlotTest >> testExtremaOfOneSideReachThePositionAndHalfTheWidth [

	self assert: (self verticesOf: ((self violinsWith: [ :violins | violins side: #low ]) parts at: #maxima) first) equals: {
		(0.75 @ 3).
		(1 @ 3) }
]

{ #category : 'tests' }
BpViolinPlotTest >> testFaceColorCanBeGivenPerViolin [

	self
		assert: (((self violinsWith: [ :violins | violins faceColor: {
	Color red.
	Color green } ]) parts at: #bodies) collect: [ :each |
			 each background paint color alpha: 1 ])
		equals: {
			Color red.
			Color green }
]

{ #category : 'tests' }
BpViolinPlotTest >> testHandlersAreKeptWhenTheViolinsAreRebuilt [

	| violins clicked |
	violins := self violins.
	clicked := nil.
	violins whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	violins showMeans: true.
	BlEvent fireEvent: BlClickEvent new target: (violins parts at: #bodies) first.
	self assert: clicked identicalTo: (violins parts at: #bodies) first
]

{ #category : 'tests' }
BpViolinPlotTest >> testHighSideKeepsTheHalfAboveThePosition [

	| xs |
	xs := self xsOf: ((self violinsWith: [ :violins | violins side: #high ]) parts at: #bodies) first.
	self assert: xs min equals: 1.
	self assert: (xs max closeTo: 1.25)
]

{ #category : 'tests' }
BpViolinPlotTest >> testHorizontalSwapsTheCoordinates [

	| body |
	body := ((self violinsWith: [ :violins | violins orientation: #horizontal ]) parts at: #bodies) first.
	self assert: (self xsOf: body) equals: #( 1 1.5 2 2.5 3 3 2.5 2 1.5 1 )
]

{ #category : 'tests' }
BpViolinPlotTest >> testLabelGivesALegendEntry [

	self
		assert: ((self violinsWith: [ :violins | violins label: 'samples' ]) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'samples' )
]

{ #category : 'tests' }
BpViolinPlotTest >> testLineColorColorsTheLines [

	self
		assert: ((self violinsWith: [ :violins | violins lineColor: Color black ]) parts at: #bars) first border paint color
		equals: Color black
]

{ #category : 'tests' }
BpViolinPlotTest >> testLineWidthSetsTheWidthOfTheLines [

	self assert:
		(((self violinsWith: [ :violins | violins lineWidth: 3 ]) parts at: #bars) first border width closeTo:
			 3 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpViolinPlotTest >> testLinesAreDrawnAboveTheBodies [

	| violins |
	violins := self violins.
	self assert: violins patches first identicalTo: (violins parts at: #bodies) first.
	self assert: violins patches last identicalTo: (violins parts at: #bars) last
]

{ #category : 'tests' }
BpViolinPlotTest >> testLinesAreTheCycleColor [

	| line |
	line := (self violins parts at: #bars) first.
	self assert: line border paint color equals: (BpPalette default colorAt: 1).
	self assert: (line border width closeTo: 1.5 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpViolinPlotTest >> testLowSideKeepsTheHalfBelowThePosition [

	| xs |
	xs := self xsOf: ((self violinsWith: [ :violins | violins side: #low ]) parts at: #bodies) first.
	self assert: xs max equals: 1.
	self assert: (xs min closeTo: 0.75)
]

{ #category : 'tests' }
BpViolinPlotTest >> testMeansAndMediansAreHiddenByDefault [

	| parts |
	parts := self violins parts.
	self assert: (parts at: #means) isEmpty.
	self assert: (parts at: #medians) isEmpty.
	self assert: (parts at: #quantiles) isEmpty
]

{ #category : 'tests' }
BpViolinPlotTest >> testNoLabelGivesNoLegendEntry [

	self assert: self violins legendEntries isEmpty
]

{ #category : 'tests' }
BpViolinPlotTest >> testOneBodyPerDataset [

	self assert: (self violins parts at: #bodies) size equals: 2
]

{ #category : 'tests' }
BpViolinPlotTest >> testOneCollectionOfNumbersIsOneViolin [

	self
		assert: ((BpViolinPlot new
			  x: #( 1 2 3 );
			  yourself) parts at: #bodies) size
		equals: 1
]

{ #category : 'tests' }
BpViolinPlotTest >> testPointsSetTheResolutionOfTheBodies [

	self assert: (self verticesOf: ((self violinsWith: [ :violins | violins points: 20 ]) parts at: #bodies) first) size equals: 40
]

{ #category : 'tests - errors' }
BpViolinPlotTest >> testPositionsOfAnotherSizeRaiseError [

	self should: [ self violins positions: #( 1 2 3 ) ] raise: Error
]

{ #category : 'tests' }
BpViolinPlotTest >> testPositionsPlaceTheViolins [

	| xs |
	xs := self xsOf: ((self violinsWith: [ :violins | violins positions: #( 10 20 ) ]) parts at: #bodies) second.
	self assert: (xs max + xs min / 2 closeTo: 20)
]

{ #category : 'tests' }
BpViolinPlotTest >> testQuantilesCanDifferPerViolin [

	| lines |
	lines := (self violinsWith: [ :violins | violins quantiles: #( #( 0.5 ) #(  ) ) ]) parts at: #quantiles.
	self assert: lines size equals: 1.
	self assert: (self verticesOf: lines first) equals: {
		(0.875 @ 2).
		(1.125 @ 2) }
]

{ #category : 'tests' }
BpViolinPlotTest >> testQuantilesDrawALineAtEachQuantile [

	self assert: ((self violinsWith: [ :violins | violins quantiles: #( 0.25 0.75 ) ]) parts at: #quantiles) size equals: 4
]

{ #category : 'tests' }
BpViolinPlotTest >> testShowExtremaFalseHidesThem [

	| parts |
	parts := (self violinsWith: [ :violins | violins showExtrema: false ]) parts.
	self assert: (#( #maxima #minima #bars ) allSatisfy: [ :each | (parts at: each) isEmpty ])
]

{ #category : 'tests' }
BpViolinPlotTest >> testShowMeansDrawsALineAtEachMean [

	self
		assert:
		(((self violinsWith: [ :violins | violins showMeans: true ]) parts at: #means) collect: [ :each | (self ysOf: each) first ])
		equals: #( 2 4 )
]

{ #category : 'tests' }
BpViolinPlotTest >> testShowMediansDrawsALineAtEachMedian [

	self
		assert:
		(((self violinsWith: [ :violins | violins showMedians: true ]) parts at: #medians) collect: [ :each | (self ysOf: each) first ])
		equals: #( 2 4 )
]

{ #category : 'tests - errors' }
BpViolinPlotTest >> testUnknownOrientationRaisesError [

	self should: [ self violins orientation: #diagonal ] raise: Error
]

{ #category : 'tests - errors' }
BpViolinPlotTest >> testUnknownSideRaisesError [

	self should: [ self violins side: #middle ] raise: Error
]

{ #category : 'tests' }
BpViolinPlotTest >> testViolinsTakeTheNextColorOfTheCycle [

	| chart |
	chart := BpChart new.
	chart plotX: #( 0 1 ) y: #( 0 1 ).
	self assert: ((chart violinPlot: #( 1 2 3 )) parts at: #bars) first border paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests - errors' }
BpViolinPlotTest >> testWidthsOfAnotherSizeRaiseError [

	self should: [ self violins widths: #( 1 2 3 ) ] raise: Error
]

{ #category : 'tests' }
BpViolinPlotTest >> testWidthsSetTheWidthOfEachViolin [

	| bodies |
	bodies := (self violinsWith: [ :violins | violins widths: #( 2 1 ) ]) parts at: #bodies.
	self assert: ((self xsOf: bodies first) max closeTo: 2).
	self assert: ((self xsOf: bodies second) max closeTo: 2.5)
]

{ #category : 'tests' }
BpViolinPlotTest >> verticesOf: aPatch [

	^ aPatch dataVertices asArray
]

{ #category : 'tests' }
BpViolinPlotTest >> violins [
	"Two violins: 1, 2, 3 (median and mean 2) and 2, 4, 4, 6 (median and mean 4), with 5 points each."

	^ BpViolinPlot new
		  points: 5;
		  x: #( #( 1 2 3 ) #( 2 4 4 6 ) );
		  yourself
]

{ #category : 'tests' }
BpViolinPlotTest >> violinsWith: aBlock [

	^ self violins
		  in: aBlock;
		  yourself
]

{ #category : 'tests' }
BpViolinPlotTest >> xsOf: aPatch [

	^ (self verticesOf: aPatch) collect: [ :each | each x ]
]

{ #category : 'tests' }
BpViolinPlotTest >> ysOf: aPatch [

	^ (self verticesOf: aPatch) collect: [ :each | each y ]
]
