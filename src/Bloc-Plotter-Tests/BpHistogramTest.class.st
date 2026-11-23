"
I test `BpHistogram`: the values of the bins (density, stacking, cumulative sums), the geometry of bars and steps, and the style of the patches.
"
Class {
	#name : 'BpHistogramTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests - bars' }
BpHistogramTest >> testAlignLeftCentersBarsOnLeftEdges [

	| bar |
	bar := (BpHistogram new
		        x: #( 1 );
		        bins: #( 0 2 );
		        align: #left;
		        yourself) patches first.
	self assert: bar dataBounds equals: (-1 @ 0 corner: 1 @ 1)
]

{ #category : 'tests - styles' }
BpHistogramTest >> testAlphaIsTheOpacity [

	self assert: ((BpHistogram new
		  x: #( 1 );
		  alpha: 0.75;
		  yourself) patches first opacity closeTo: 0.75)
]

{ #category : 'tests - bars' }
BpHistogramTest >> testBarFillsItsBin [

	| bar |
	bar := (BpHistogram new
		        x: #( 1 3 3 );
		        bins: #( 0 2 4 );
		        yourself) patches second.
	self assert: bar dataBounds equals: (2 @ 0 corner: 4 @ 2).
	self assert: bar bin equals: 2.
	self assert: bar amount equals: 2
]

{ #category : 'tests - counts' }
BpHistogramTest >> testBarStackedStacks [

	self
		assert: (BpHistogram new
			 x: #( #( 0 1 ) #( 9 10 ) );
			 bins: 2;
			 histType: #barstacked;
			 yourself) counts
		equals: #( #( 2 0 ) #( 2 2 ) )
]

{ #category : 'tests - styles' }
BpHistogramTest >> testBarsHaveNoBorderByDefault [

	self assert: (BpHistogram new
		 x: #( 1 );
		 yourself) patches first border isTransparent
]

{ #category : 'tests - styles' }
BpHistogramTest >> testBarsUseTheFirstCycleColor [

	self
		assert: (BpHistogram new
			 x: #( 1 );
			 yourself) patches first background paint color
		equals: BpColors tab10 first
]

{ #category : 'tests - bars' }
BpHistogramTest >> testBottomShiftsTheBars [

	| bar |
	bar := (BpHistogram new
		        x: #( 1 );
		        bins: #( 0 2 );
		        bottom: 5;
		        yourself) patches first.
	self assert: bar dataBounds equals: (0 @ 5 corner: 2 @ 6)
]

{ #category : 'tests - styles' }
BpHistogramTest >> testColorGivesOneColorPerDataset [

	self
		assert: (BpHistogram new
			 x: #( #( 1 ) #( 2 ) );
			 color: {
				 Color red.
				 Color blue };
			 yourself) patches second first background paint color
		equals: Color blue
]

{ #category : 'tests - counts' }
BpHistogramTest >> testCountsOfOneDataset [

	| histogram |
	histogram := BpHistogram new
		             x: #( 1 2 2 3 3 3 );
		             bins: 3;
		             yourself.
	self assert: histogram counts equals: #( 1 2 3 ).
	self assert: histogram binEdges equals: {
		1.
		(5 / 3).
		(7 / 3).
		3 }
]

{ #category : 'tests - counts' }
BpHistogramTest >> testCumulative [

	self
		assert: (BpHistogram new
			 x: #( 1 2 2 3 3 3 );
			 bins: 3;
			 cumulative: true;
			 yourself) counts
		equals: #( 1 3 6 )
]

{ #category : 'tests - counts' }
BpHistogramTest >> testCumulativeDensityEndsAtOne [

	self
		assert: (BpHistogram new
			 x: #( 1 2 2 3 3 3 );
			 bins: 3;
			 density: true;
			 cumulative: true;
			 yourself) counts last
		closeTo: 1
]

{ #category : 'tests - bars' }
BpHistogramTest >> testDatasetsArePutSideBySide [
	"Two datasets: the bars take 0.8 of the bin, 0.4 each."

	| histogram |
	histogram := BpHistogram new
		             x: #( #( 1 ) #( 1 ) );
		             bins: #( 0 5 10 );
		             yourself.
	self assert: histogram patches first first dataBounds left closeTo: 0.5.
	self assert: histogram patches first first dataBounds right closeTo: 2.5.
	self assert: histogram patches second first dataBounds left closeTo: 2.5.
	self assert: histogram patches second first dataBounds right closeTo: 4.5
]

{ #category : 'tests - counts' }
BpHistogramTest >> testDatasetsShareTheirEdges [

	| histogram |
	histogram := BpHistogram new
		             x: #( #( 0 1 ) #( 9 10 ) );
		             bins: 2;
		             yourself.
	self assert: histogram binEdges equals: #( 0 5 10 ).
	self assert: histogram counts equals: #( #( 2 0 ) #( 0 2 ) )
]

{ #category : 'tests - styles' }
BpHistogramTest >> testDatasetsUseTheNextCycleColors [

	self
		assert: (BpHistogram new
			 x: #( #( 1 ) #( 2 ) );
			 yourself) patches second first background paint color
		equals: BpColors tab10 second
]

{ #category : 'tests - counts' }
BpHistogramTest >> testDefaultBinsAreTen [

	self
		assert: (BpHistogram new
			 x: (1 to: 100);
			 yourself) counts size
		equals: 10
]

{ #category : 'tests - counts' }
BpHistogramTest >> testDensity [

	self
		assert: (BpHistogram new
			 x: #( 1 2 2 3 );
			 bins: #( 0 2 4 );
			 density: true;
			 yourself) counts
		equals: #( 0.125 0.375 )
]

{ #category : 'tests - styles' }
BpHistogramTest >> testEdgeColorAndLineWidthGiveABorder [

	| bar |
	bar := (BpHistogram new
		        x: #( 1 );
		        edgeColor: Color black;
		        lineWidth: 2;
		        yourself) patches first.
	self assert: bar border paint color equals: Color black.
	self assert: bar border width closeTo: 2 * BpHistogram pixelsPerPoint
]

{ #category : 'tests - styles' }
BpHistogramTest >> testFaceColorOverridesColorOfBars [

	self
		assert: (BpHistogram new
			 x: #( 1 );
			 color: Color red;
			 faceColor: Color blue;
			 yourself) patches first background paint color
		equals: Color blue
]

{ #category : 'tests - styles' }
BpHistogramTest >> testFillFalseLeavesBarsEmpty [

	self
		assert: (BpHistogram new
			 x: #( 1 );
			 fill: false;
			 edgeColor: Color red;
			 yourself) patches first background paint color
		equals: Color transparent
]

{ #category : 'tests - bars' }
BpHistogramTest >> testHorizontalSwapsTheAxes [

	| bar |
	bar := (BpHistogram new
		        x: #( 1 3 3 );
		        bins: #( 0 2 4 );
		        orientation: #horizontal;
		        yourself) patches second.
	self assert: bar dataBounds equals: (0 @ 2 corner: 2 @ 4)
]

{ #category : 'tests - styles' }
BpHistogramTest >> testLineStyleDashesTheBorder [

	self assert: (BpHistogram new
		 x: #( 1 );
		 edgeColor: Color red;
		 lineStyle: #dashed;
		 yourself) patches first border style dashArray isNotEmpty
]

{ #category : 'tests - bars' }
BpHistogramTest >> testOneBarPerBin [

	| histogram |
	histogram := BpHistogram new
		             x: #( 1 2 2 3 3 3 );
		             bins: 3;
		             yourself.
	self assert: histogram patches size equals: 3.
	self assert: (histogram patches allSatisfy: [ :each | each class = BpRectanglePatch ])
]

{ #category : 'tests - counts' }
BpHistogramTest >> testRange [

	self
		assert: (BpHistogram new
			 x: #( 1 3 12 );
			 range: #( 0 4 );
			 bins: 2;
			 yourself) counts
		equals: #( 1 1 )
]

{ #category : 'tests - bars' }
BpHistogramTest >> testRelativeWidthNarrowsTheBars [

	| bar |
	bar := (BpHistogram new
		        x: #( 1 );
		        bins: #( 0 10 );
		        relativeWidth: 0.8;
		        yourself) patches first.
	self assert: bar dataBounds left closeTo: 1.
	self assert: bar dataBounds right closeTo: 9
]

{ #category : 'tests - counts' }
BpHistogramTest >> testReverseCumulative [

	self
		assert: (BpHistogram new
			 x: #( 1 2 2 3 3 3 );
			 bins: 3;
			 cumulative: -1;
			 yourself) counts
		equals: #( 6 5 3 )
]

{ #category : 'tests - bars' }
BpHistogramTest >> testStackedBarsStartOnThePreviousTop [

	| histogram |
	histogram := BpHistogram new
		             x: #( #( 1 1 ) #( 1 ) );
		             bins: #( 0 2 );
		             histType: #barstacked;
		             yourself.
	self assert: histogram patches second first dataBounds equals: (0 @ 2 corner: 2 @ 3)
]

{ #category : 'tests - counts' }
BpHistogramTest >> testStackedCountsAreSummed [

	self
		assert: (BpHistogram new
			 x: #( #( 0 1 ) #( 9 10 ) );
			 bins: 2;
			 stacked: true;
			 yourself) counts
		equals: #( #( 2 0 ) #( 2 2 ) )
]

{ #category : 'tests - counts' }
BpHistogramTest >> testStackedDensityNormalizesTheSum [

	self
		assert: (BpHistogram new
			 x: #( #( 1 ) #( 3 ) );
			 bins: #( 0 2 4 );
			 stacked: true;
			 density: true;
			 yourself) counts
		equals: #( #( 0.25 0 ) #( 0.25 0.25 ) )
]

{ #category : 'tests - steps' }
BpHistogramTest >> testStackedStepStartsOnThePreviousTop [

	| patches |
	patches := (BpHistogram new
		            x: #( #( 1 ) #( 1 3 ) );
		            bins: #( 0 2 4 );
		            histType: #step;
		            stacked: true;
		            yourself) patches.
	self assert: patches second first dataVertices asArray equals: {
		(0 @ 1).
		(0 @ 2).
		(2 @ 2).
		(2 @ 1).
		(4 @ 1).
		(4 @ 0) }
]

{ #category : 'tests - steps' }
BpHistogramTest >> testStepCanBeDrawnBeforeLayout [

	self assert: (BpHistogram new
		 x: #( 1 3 3 );
		 histType: #step;
		 yourself) patches first asForm isNotNil
]

{ #category : 'tests - steps' }
BpHistogramTest >> testStepFilledFillsDownToThePreviousTop [

	| patches |
	patches := (BpHistogram new
		            x: #( #( 1 ) #( 1 3 ) );
		            bins: #( 0 2 4 );
		            histType: #stepfilled;
		            stacked: true;
		            yourself) patches.
	self assert: (patches second first dataVertices last: 4) asArray equals: {
		(4 @ 0).
		(2 @ 0).
		(2 @ 1).
		(0 @ 1) }
]

{ #category : 'tests - steps' }
BpHistogramTest >> testStepFilledIsClosed [

	self assert: (BpHistogram new
		 x: #( 1 3 3 );
		 bins: #( 0 2 4 );
		 histType: #stepfilled;
		 yourself) patches first isClosed
]

{ #category : 'tests - styles' }
BpHistogramTest >> testStepIsDrawnWithColorNotFaceColor [
	"An unfilled step ignores faceColor: and draws its outline with the dataset color."

	| step |
	step := (BpHistogram new
		         x: #( 1 );
		         histType: #step;
		         faceColor: Color green;
		         yourself) patches first.
	self assert: step border paint color equals: BpColors tab10 first.
	self assert: step background paint color equals: Color transparent
]

{ #category : 'tests - steps' }
BpHistogramTest >> testStepIsOneOpenOutline [

	| patches |
	patches := (BpHistogram new
		            x: #( 1 3 3 );
		            bins: #( 0 2 4 );
		            histType: #step;
		            yourself) patches.
	self assert: patches size equals: 1.
	self deny: patches first isClosed.
	self assert: patches first dataVertices asArray equals: {
		(0 @ 0).
		(0 @ 1).
		(2 @ 1).
		(2 @ 2).
		(4 @ 2).
		(4 @ 0) }
]

{ #category : 'tests - errors' }
BpHistogramTest >> testUnknownHistTypeRaisesError [

	self should: [ BpHistogram new histType: #pie ] raise: Error
]

{ #category : 'tests - errors' }
BpHistogramTest >> testUnknownOrientationRaisesError [

	self should: [ BpHistogram new orientation: #diagonal ] raise: Error
]

{ #category : 'tests - counts' }
BpHistogramTest >> testWeights [

	self
		assert: (BpHistogram new
			 x: #( 1 3 );
			 weights: #( 2 0.5 );
			 bins: #( 0 2 4 );
			 yourself) counts
		equals: #( 2 0.5 )
]
