"
I test `BpHexbin`: the counts and reduced values of the hexagons, their colors, the limits and scales of the chart, the rendering, the interaction, and the errors.
"
Class {
	#name : 'BpHexbinTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpHexbinTest >> greysOf: aHexbin [

	^ aHexbin patches collect: [ :each | each background paint color ]
]

{ #category : 'tests' }
BpHexbinTest >> hexbinOf: aCollectionOfPoints [
	"Answer a hexbin of aCollectionOfPoints in a chart, over a region of four by two cells of 1 by 1."

	^ (BpChart new
		   extent: 400 @ 400;
		   addArtist:
			   (BpHexbin x: (aCollectionOfPoints collect: [ :each | each x ]) y: (aCollectionOfPoints collect: [ :each | each y ])))
		  region: (0 @ 0 corner: 4 @ 2);
		  gridSize: 4 @ 2;
		  yourself
]

{ #category : 'tests' }
BpHexbinTest >> is: aColor within: anInteger of: anotherColor [
	"Answer whether the levels of both colors, between 0 and 255, differ by anInteger at most."

	^ (#( #red #green #blue ) collect: [ :each | ((aColor perform: each) - (anotherColor perform: each)) abs * 255 ]) max
	  < (anInteger + 0.5)
]

{ #category : 'tests' }
BpHexbinTest >> patchOf: aHexbin at: aPoint [

	^ aHexbin patches detect: [ :each | each center = aPoint ]
]

{ #category : 'tests' }
BpHexbinTest >> testAllPointsAreCountedByDefault [

	| random hexbin |
	random := Random seed: 42.
	hexbin := BpHexbin x: ((1 to: 200) collect: [ :each | random next ]) y: ((1 to: 200) collect: [ :each | random next ]).
	self assert: (hexbin patches inject: 0 into: [ :sum :each | sum + each count ]) equals: 200
]

{ #category : 'tests' }
BpHexbinTest >> testAlphaMakesTheHexagonsTransparent [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin alpha: 0.5.
	self assert: hexbin patches first background paint color alpha closeTo: 0.5 precision: 0.01
]

{ #category : 'tests' }
BpHexbinTest >> testBinsCanBeTheEdges [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin
		colorMap: [ :fraction | Color gray: fraction ];
		bins: #( 1.5 ).
	self assert: (self patchOf: hexbin at: 0 @ 0) background paint color equals: Color black.
	self assert: (self patchOf: hexbin at: 5 / 2 @ (3 / 2)) background paint color equals: Color black.
	self assert: (self patchOf: hexbin at: 1 @ 1) background paint color equals: Color white
]

{ #category : 'tests' }
BpHexbinTest >> testBinsIsTheNumberOfColors [
	"The edges of the bins of the counts 0, 1 and 2 are 0 and 1."

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin
		colorMap: [ :fraction | Color gray: fraction ];
		bins: 3.
	self assert: (self greysOf: hexbin) asSet size equals: 3.
	hexbin bins: 2.
	self assert: (self greysOf: hexbin) asSet size equals: 2
]

{ #category : 'tests - errors' }
BpHexbinTest >> testCOfAnotherSizeRaisesError [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	self
		should: [ hexbin c: #( 1 ) ]
		raise: Error
		whoseDescriptionIncludes: 'same size'
		description: 'the sizes differ'
]

{ #category : 'tests' }
BpHexbinTest >> testCReducesTheValuesOfEachHexagonToTheirMean [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin c: #( 10 20 7 ).
	self assert: (self patchOf: hexbin at: 1 @ 1) amount equals: 15.
	self assert: (self patchOf: hexbin at: 1 @ 1) count equals: 2.
	self assert: hexbin patches size equals: 2
]

{ #category : 'tests' }
BpHexbinTest >> testClassSideAnswersAHexbin [

	self assert: (BpHexbin x: #( 1 2 ) y: #( 3 4 )) class equals: BpHexbin
]

{ #category : 'tests' }
BpHexbinTest >> testClickOnAHexagonReachesIt [

	| hexbin chart clicked |
	clicked := nil.
	hexbin := self hexbinOf: self threePoints.
	hexbin whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	chart := hexbin chart.
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		chart eventSimulator clickAt: chart plotBounds origin + (chart dataTransform pointFor: 1 @ 1) ].
	self assert: clicked center equals: 1 @ 1
]

{ #category : 'tests' }
BpHexbinTest >> testColorMapIsViridisByDefault [

	self
		assert: (self patchOf: (self hexbinOf: self threePoints) at: 1 @ 1) background paint color
		equals: (BpInterpolatedPalette viridis colorAt: 1)
]

{ #category : 'tests' }
BpHexbinTest >> testColorsGoThroughTheColorMap [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin colorMap: [ :fraction | Color gray: fraction ].
	self assert: (self patchOf: hexbin at: 1 @ 1) background paint color equals: Color white.
	self assert: (self patchOf: hexbin at: 0 @ 0) background paint color equals: Color black.
	self assert: (self patchOf: hexbin at: 5 / 2 @ (3 / 2)) background paint color equals: (Color gray: 0.5)
]

{ #category : 'tests' }
BpHexbinTest >> testCountsThePointsOfEachHexagon [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	self assert: (self patchOf: hexbin at: 1 @ 1) count equals: 2.
	self assert: (self patchOf: hexbin at: 1 @ 1) amount equals: 2.
	self assert: (self patchOf: hexbin at: 5 / 2 @ (3 / 2)) count equals: 1
]

{ #category : 'tests - errors' }
BpHexbinTest >> testDifferentSizesRaiseError [

	self
		should: [ BpHexbin x: #( 1 2 ) y: #( 1 ) ]
		raise: Error
		whoseDescriptionIncludes: 'same size'
		description: 'the sizes differ'
]

{ #category : 'tests' }
BpHexbinTest >> testEdgeColorsIsGivenToAllHexagons [

	| hexbin color |
	color := BpQualitativePalette set1 colorAt: 1.
	hexbin := self hexbinOf: self threePoints.
	hexbin
		edgeColors: color;
		lineWidths: 2.
	self assert: (hexbin patches allSatisfy: [ :each | each border paint color = color ]).
	self assert: hexbin patches first border width equals: 2 * BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpHexbinTest >> testEdgesHaveTheColorOfTheirHexagon [

	| patch |
	patch := self patchOf: (self hexbinOf: self threePoints) at: 1 @ 1.
	self assert: patch border paint color equals: patch background paint color
]

{ #category : 'tests' }
BpHexbinTest >> testEmptyHexagonsAreShown [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	self assert: hexbin patches size equals: 23.
	self assert: (self patchOf: hexbin at: 0 @ 0) count equals: 0
]

{ #category : 'tests' }
BpHexbinTest >> testGridSizeOfOneHasARow [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin gridSize: 1.
	self assert: hexbin grid rows equals: 1
]

{ #category : 'tests' }
BpHexbinTest >> testGridSizeSetsTheColumnsAndMakesRegularHexagons [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin gridSize: 10.
	self assert: hexbin grid columns equals: 10.
	self assert: hexbin grid rows equals: 5
]

{ #category : 'tests' }
BpHexbinTest >> testHexagonIsPaintedAroundItsCenter [

	| hexbin color form chart center |
	color := BpQualitativePalette set1 colorAt: 2.
	hexbin := self hexbinOf: { (2 @ 1) }.
	hexbin
		colorMap: [ :fraction | color ];
		minCount: 1.
	chart := hexbin chart.
	form := chart asForm.
	center := chart plotBounds origin + (chart dataTransform pointFor: 2 @ 1).
	self assert: (form colorAt: center rounded) equals: color.
	self assert: (form colorAt: (center + (chart plotBounds width / 8 * 0.8 @ 0)) rounded) equals: color.
	self assert: (form colorAt: (center + (chart plotBounds width / 8 * 1.3 @ 0)) rounded) equals: Color white
]

{ #category : 'tests' }
BpHexbinTest >> testHexbinOfNoDataHasTheUnitRegion [

	self assert: (BpHexbin x: #(  ) y: #(  )) grid region equals: (0 @ 0 corner: 1 @ 1)
]

{ #category : 'tests' }
BpHexbinTest >> testHexbinTakesNoColorOfThePalette [

	| chart |
	chart := BpChart new.
	chart addArtist: (BpHexbin x: #( 1 2 ) y: #( 1 2 )).
	self assert: (chart addArtist: (BpLine x: #( 1 2 ) y: #( 1 2 ))) linePatch border paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests - instances' }
BpHexbinTest >> testInstanceMinCountHasFewerHexagons [

	| all |
	all := (BpHexbin ofPoints: BpHexbin optionPoints)
		       gridSize: 25;
		       yourself.
	self assert: BpHexbin instanceMinCount patches size < all patches size
]

{ #category : 'tests' }
BpHexbinTest >> testLimitsAreTheRegion [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	self assert: hexbin chart xLimits equals: #( 0 4 ).
	self assert: hexbin chart yLimits equals: #( 0 2 )
]

{ #category : 'tests' }
BpHexbinTest >> testLimitsOfRandomDataAreTheRegion [

	| random hexbin region chart |
	random := Random seed: 7.
	chart := BpChart new.
	hexbin := chart addArtist: (BpHexbin x: ((1 to: 50) collect: [ :each | random next ]) y: ((1 to: 50) collect: [ :each | random next ])).
	region := hexbin grid region.
	self assert: chart xLimits first equals: region left.
	self assert: chart xLimits last closeTo: region right.
	self assert: chart yLimits last closeTo: region bottom
]

{ #category : 'tests' }
BpHexbinTest >> testLogBinsColorTheOrdersOfMagnitude [

	| hexbin |
	hexbin := self hexbinOf: ((1 to: 100) collect: [ :each | 1 @ 1 ]) , ((1 to: 10) collect: [ :each | 2 @ 1 ]) , { (3 @ 1) }.
	hexbin
		colorMap: [ :fraction | Color gray: fraction ];
		bins: #log.
	self assert: (self patchOf: hexbin at: 2 @ 1) background paint color equals: (Color gray: 0.5)
]

{ #category : 'tests' }
BpHexbinTest >> testLogBinsHideTheEmptyHexagons [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin bins: #log.
	self assert: (self patchOf: hexbin at: 0 @ 0) background paint color isTransparent.
	self assert: (self patchOf: hexbin at: 0 @ 0) border paint color isTransparent
]

{ #category : 'tests' }
BpHexbinTest >> testLogScaleBinsTheLogarithms [

	| hexbin |
	hexbin := BpHexbin x: #( 1 10 100 ) y: #( 0 1 2 ).
	hexbin
		gridSize: 2 @ 2;
		xScale: #log.
	self
		assert: ((hexbin patches select: [ :each | each count = 1 ]) collect: [ :each | each center x rounded ] as: Array)
		equals: #( 1 10 100 )
]

{ #category : 'tests - errors' }
BpHexbinTest >> testLogScaleOfNegativeValuesRaisesError [

	| hexbin |
	hexbin := BpHexbin x: #( 0 1 ) y: #( 1 2 ).
	self
		should: [ hexbin xScale: #log ]
		raise: Error
		whoseDescriptionIncludes: 'positive'
		description: 'zero has no logarithm'
]

{ #category : 'tests' }
BpHexbinTest >> testLogScalePutsTheChartOnALogScale [

	| chart hexbin |
	chart := BpChart new.
	hexbin := chart addArtist: (BpHexbin x: #( 1 10 100 ) y: #( 1 2 3 )).
	hexbin xScale: #log.
	self assert: chart xScale equals: #log.
	self assert: chart yScale equals: #linear
]

{ #category : 'tests' }
BpHexbinTest >> testLogScaleRegionIsInDataCoordinates [

	| hexbin |
	hexbin := BpHexbin x: #( 1 10 100 ) y: #( 0 1 2 ).
	hexbin
		region: (10 @ 0 corner: 1000 @ 2);
		gridSize: 2 @ 2;
		xScale: #log.
	self assert: (hexbin patches inject: 0 into: [ :sum :each | sum + each count ]) equals: 2
]

{ #category : 'tests' }
BpHexbinTest >> testMinCountAppliesToC [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin
		c: #( 10 20 7 );
		minCount: 2.
	self assert: (hexbin patches collect: [ :each | each center ] as: Array) equals: { (1 @ 1) }
]

{ #category : 'tests' }
BpHexbinTest >> testMinCountHidesTheHexagonsWithFewerPoints [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin minCount: 1.
	self assert: hexbin patches size equals: 2.
	hexbin minCount: 2.
	self assert: (hexbin patches collect: [ :each | each center ] as: Array) equals: { (1 @ 1) }
]

{ #category : 'tests' }
BpHexbinTest >> testNoSeamBetweenHexagonsOfTheSameColor [
	"The plot area, white, would show between the antialiased edges of the hexagons, by up to 16 levels of 255. Three levels are left to rounding."

	| hexbin chart color form area |
	color := BpQualitativePalette set1 colorAt: 2.
	chart := BpChart new
		         extent: 400 @ 400;
		         yourself.
	hexbin := chart addArtist: (BpHexbin x: #( 0 4 ) y: #( 0 2 )).
	hexbin
		gridSize: 7 @ 3;
		colorMap: [ :fraction | color ].
	form := chart asForm.
	area := (chart plotBounds insetBy: 3) rounded.
	self assert: ((area left to: area right) allSatisfy: [ :eachX |
		 (area top to: area bottom) allSatisfy: [ :eachY | self is: (form colorAt: eachX @ eachY) within: 3 of: color ] ])
]

{ #category : 'tests - instances' }
BpHexbinTest >> testOfPointsCountsEveryPoint [

	self
		assert: ((BpHexbin ofPoints: {
			  (0 @ 0).
			  (0 @ 0).
			  (1 @ 1) }) patches inject: 0 into: [ :sum :each | sum + each count ])
		equals: 3
]

{ #category : 'tests' }
BpHexbinTest >> testPointsOutOfTheRegionAreNotCounted [

	| hexbin |
	hexbin := self hexbinOf: self threePoints , { (10 @ 10) }.
	self assert: (hexbin patches inject: 0 into: [ :sum :each | sum + each count ]) equals: 3
]

{ #category : 'tests' }
BpHexbinTest >> testReductionReplacesTheMean [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin
		c: #( 10 20 7 );
		reduction: [ :values | values max ].
	self assert: (self patchOf: hexbin at: 1 @ 1) amount equals: 20
]

{ #category : 'tests' }
BpHexbinTest >> testRegionIsTheOneOfTheDataByDefault [

	| hexbin |
	hexbin := BpHexbin x: #( 1 2 5 ) y: #( -1 3 2 ).
	self assert: hexbin grid region equals: (1 @ -1 corner: 5 @ 3)
]

{ #category : 'tests' }
BpHexbinTest >> testRegionOfEqualValuesIsWidened [

	| hexbin |
	hexbin := BpHexbin x: #( 10 10 ) y: #( 0 0 ).
	self assert: hexbin grid region equals: (9 @ -0.1 corner: 11 @ 0.1)
]

{ #category : 'tests - errors' }
BpHexbinTest >> testUnknownScaleRaisesError [

	| hexbin |
	hexbin := BpHexbin x: #( 0 1 ) y: #( 1 2 ).
	self
		should: [ hexbin yScale: #cubic ]
		raise: Error
		whoseDescriptionIncludes: 'Unknown scale'
		description: 'the scale is unknown'
]

{ #category : 'tests' }
BpHexbinTest >> testVMinAndVMaxAreTheEndsOfTheColorMap [

	| hexbin |
	hexbin := self hexbinOf: self threePoints.
	hexbin
		colorMap: [ :fraction | Color gray: fraction ];
		vMin: 1;
		vMax: 3.
	self assert: (self patchOf: hexbin at: 1 @ 1) background paint color equals: (Color gray: 0.5).
	self assert: (self patchOf: hexbin at: 0 @ 0) background paint color equals: Color black
]

{ #category : 'tests' }
BpHexbinTest >> threePoints [
	"Two points in the hexagon of 1 @ 1, one in the hexagon of 2.5 @ 1.5."

	^ {
		  (1 @ 1).
		  (1.1 @ 1.1).
		  (2.5 @ 1.5) }
]
