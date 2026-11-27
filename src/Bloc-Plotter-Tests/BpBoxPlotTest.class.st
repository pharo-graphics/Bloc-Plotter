"
I check `BpBoxPlot`: the parts built for each dataset and their geometry (box between the quartiles, median, whiskers, caps, notch, fliers, means), their default and given styles, horizontal boxes, positions and widths, and the legend entry.

## Implementation Notes

- My fixture `#(1 2 3 4 5 6 7 8 9 100)` has one flier, 100, so every part exists.
- The box plot is not in a figure: the patches are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpBoxPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpBoxPlotTest >> boxPlot [
	"One box half a unit wide of 1 to 9 and the flier 100: quartiles 13/4, 11/2 and 31/4, whiskers 1 and 9, mean 14.5."

	^ BpBoxPlot new
		  x: #( 1 2 3 4 5 6 7 8 9 100 );
		  widths: 0.5;
		  yourself
]

{ #category : 'tests' }
BpBoxPlotTest >> ppp [

	^ BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpBoxPlotTest >> testASingleCollectionOfNumbersIsOneDataset [

	self assert: self boxPlot statistics size equals: 1
]

{ #category : 'tests' }
BpBoxPlotTest >> testBoxGoesFromTheFirstToTheThirdQuartileAtItsPosition [

	self assert: (self boxPlot parts at: #boxes) first dataBounds equals: (0.75 @ (13 / 4) corner: 1.25 @ (31 / 4))
]

{ #category : 'tests' }
BpBoxPlotTest >> testBoxIsABlackOutlineByDefault [

	| box |
	box := (self boxPlot parts at: #boxes) first.
	self assert: box border paint color equals: Color black.
	self assert: (box border width closeTo: self ppp).
	self assert: box background paint color equals: Color transparent
]

{ #category : 'tests' }
BpBoxPlotTest >> testBoxPropertiesStyleTheBox [

	| box |
	box := ((self boxPlot
		         patchArtist: true;
		         boxProperties: {
			         (#faceColor -> (BpPalette default colorAt: 2)).
			         (#edgeColor -> Color white).
			         (#lineWidth -> 0.5) } asDictionary;
		         yourself) parts at: #boxes) first.
	self assert: box background paint color equals: (BpPalette default colorAt: 2).
	self assert: box border paint color equals: Color white.
	self assert: (box border width closeTo: 0.5 * self ppp)
]

{ #category : 'tests' }
BpBoxPlotTest >> testCapsAreHalfAsWideAsTheBox [

	self assert: (self boxPlot parts at: #caps) first dataVertices equals: {
		(0.875 @ 1).
		(1.125 @ 1) }
]

{ #category : 'tests' }
BpBoxPlotTest >> testDefaultFliersAreUnfilledBlackCircles [

	| flier |
	flier := (self boxPlot parts at: #fliers) first.
	self assert: flier marker isCircle.
	self assert: flier background paint color equals: Color transparent.
	self assert: flier border paint color equals: Color black.
	self assert: flier area equals: 36
]

{ #category : 'tests' }
BpBoxPlotTest >> testDefaultPositionsCountFromOne [

	self
		assert: (BpBoxPlot new
			 x: #( #( 1 2 ) #( 3 4 ) #( 5 6 ) );
			 yourself) positions asArray
		equals: #( 1 2 3 )
]

{ #category : 'tests - palette' }
BpBoxPlotTest >> testDefaultStyleTakesTheColorsOfThePalette [

	| chart palette boxPlot |
	palette := BpQualitativePalette set1.
	chart := BpChart new.
	chart palette: palette.
	boxPlot := (chart addArtist: (BpBoxPlot new
	  x: #( #( 1 2 3 4 5 ) );
	  yourself))
		           patchArtist: true;
		           showMeans: true;
		           yourself.
	self assert: (boxPlot parts at: #boxes) first background paint color equals: (palette colorAt: 1).
	self assert: (boxPlot parts at: #medians) first border paint color equals: (palette colorAt: 2).
	self assert: (boxPlot parts at: #means) first background paint color equals: (palette colorAt: 3)
]

{ #category : 'tests' }
BpBoxPlotTest >> testDefaultWidthIsHalfAUnit [

	self
		assert: (BpBoxPlot new
			 x: #( #( 1 2 ) #( 3 4 ) #( 5 6 ) #( 7 8 ) #( 9 10 ) );
			 yourself) widths
		equals: #( 0.5 0.5 0.5 0.5 0.5 )
]

{ #category : 'tests' }
BpBoxPlotTest >> testDefaultWidthOfASingleBoxIsNarrow [

	self assert: ((BpBoxPlot new
		  x: #( 1 2 3 );
		  yourself) widths first closeTo: 0.15)
]

{ #category : 'tests' }
BpBoxPlotTest >> testDefaultWidthShrinksWithCloserPositions [

	self assert: ((BpBoxPlot new
		  x: #( #( 1 2 ) #( 3 4 ) );
		  positions: #( 1 2 );
		  yourself) widths first closeTo: 0.15).
	self assert: ((BpBoxPlot new
		  x: #( #( 1 2 ) #( 3 4 ) );
		  positions: #( 0 2 );
		  yourself) widths first closeTo: 0.3)
]

{ #category : 'tests - instances' }
BpBoxPlotTest >> testDemoInstancesShareTheirData [

	self assert: BpBoxPlot instanceNotched statistics first median equals: BpBoxPlot instanceBasic statistics first median
]

{ #category : 'tests' }
BpBoxPlotTest >> testEmptyFlierSymbolHidesThem [

	self assert: ((self boxPlot
		  flierSymbol: '';
		  yourself) parts at: #fliers) isEmpty
]

{ #category : 'tests' }
BpBoxPlotTest >> testFlierSymbolGivesTheMarker [

	self
		assert: ((self boxPlot
			  flierSymbol: 'D';
			  yourself) parts at: #fliers) first marker vertices size
		equals: 4
]

{ #category : 'tests' }
BpBoxPlotTest >> testFlierSymbolKeepsTheColorsOfTheFlierProperties [

	self
		assert: ((self boxPlot
			  flierProperties: { (#markerFaceColor -> Color green) } asDictionary;
			  flierSymbol: 'D';
			  yourself) parts at: #fliers) first background paint color
		equals: Color green
]

{ #category : 'tests' }
BpBoxPlotTest >> testFliersAreMarkersAtTheirValues [

	self assert: (self boxPlot parts at: #fliers) first dataPoint equals: 1 @ 100
]

{ #category : 'tests' }
BpBoxPlotTest >> testHorizontalSwapsTheCoordinates [

	self
		assert: ((self boxPlot
			  orientation: #horizontal;
			  yourself) parts at: #boxes) first dataBounds
		equals: (13 / 4 @ 0.75 corner: 31 / 4 @ 1.25)
]

{ #category : 'tests - instances' }
BpBoxPlotTest >> testInstanceBasicHasFliers [

	self assert: (BpBoxPlot instanceBasic parts at: #fliers) isNotEmpty
]

{ #category : 'tests - instances' }
BpBoxPlotTest >> testInstanceFilledBoxesIsAtTwoFourAndSix [

	self assert: (BpBoxPlot instanceFilledBoxes managedTicksOn: #x) equals: {
		(2 -> '2').
		(4 -> '4').
		(6 -> '6') }
]

{ #category : 'tests - instances' }
BpBoxPlotTest >> testInstanceLabeledBoxesHasThreeBoxesWithTheirMeans [

	| boxPlot |
	boxPlot := BpBoxPlot instanceLabeledBoxes.
	self assert: boxPlot statistics size equals: 3.
	self assert: (boxPlot parts at: #means) size equals: 3
]

{ #category : 'tests - instances' }
BpBoxPlotTest >> testInstanceShortWhiskersMakesMoreFliers [

	self assert: (BpBoxPlot instanceShortWhiskers parts at: #fliers) size > (BpBoxPlot instanceHorizontal parts at: #fliers) size
]

{ #category : 'tests - instances' }
BpBoxPlotTest >> testInstanceWithoutFliersShowsNoFlier [

	self assert: (BpBoxPlot instanceWithoutFliers parts at: #fliers) isEmpty
]

{ #category : 'tests' }
BpBoxPlotTest >> testLabelGivesALegendEntry [

	self
		assert: ((self boxPlot
			  label: 'data';
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'data' )
]

{ #category : 'tests' }
BpBoxPlotTest >> testMeanLineCrossesTheBoxDashed [

	| mean |
	mean := ((self boxPlot
		          showMeans: true;
		          meanLine: true;
		          yourself) parts at: #means) first.
	self assert: mean dataVertices equals: {
		(0.75 @ (145 / 10)).
		(1.25 @ (145 / 10)) }.
	self deny: mean border style dashArray isEmpty
]

{ #category : 'tests' }
BpBoxPlotTest >> testMedianCrossesTheBox [

	self assert: (self boxPlot parts at: #medians) first dataVertices equals: {
		(0.75 @ (11 / 2)).
		(1.25 @ (11 / 2)) }
]

{ #category : 'tests' }
BpBoxPlotTest >> testMedianIsOrangeByDefault [

	self assert: (self boxPlot parts at: #medians) first border paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests' }
BpBoxPlotTest >> testMedianPropertiesStyleTheMedian [

	| median |
	median := ((self boxPlot
		            medianProperties: {
			            (#color -> Color white).
			            (#lineWidth -> 0.5) } asDictionary;
		            yourself) parts at: #medians) first.
	self assert: median border paint color equals: Color white.
	self assert: (median border width closeTo: 0.5 * self ppp)
]

{ #category : 'tests' }
BpBoxPlotTest >> testNotchNarrowsTheBoxAtTheMedian [

	| boxPlot box |
	boxPlot := self boxPlot
		           notch: true;
		           yourself.
	box := (boxPlot parts at: #boxes) first.
	self assert: box dataVertices size equals: 10.
	self assert: (box dataVertices includes: 1.125 @ (11 / 2)).
	self assert: (boxPlot parts at: #medians) first dataVertices equals: {
		(0.875 @ (11 / 2)).
		(1.125 @ (11 / 2)) }
]

{ #category : 'tests' }
BpBoxPlotTest >> testOneBoxHasABoxAMedianTwoWhiskersTwoCapsAndItsFliers [

	| parts |
	parts := self boxPlot parts.
	self assert: (parts at: #boxes) size equals: 1.
	self assert: (parts at: #medians) size equals: 1.
	self assert: (parts at: #whiskers) size equals: 2.
	self assert: (parts at: #caps) size equals: 2.
	self assert: (parts at: #fliers) size equals: 1.
	self assert: (parts at: #means) isEmpty
]

{ #category : 'tests' }
BpBoxPlotTest >> testPatchArtistFillsTheBoxWithTheFirstColorOfTheCycle [

	| box |
	box := ((self boxPlot
		         patchArtist: true;
		         yourself) parts at: #boxes) first.
	self assert: box background paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests' }
BpBoxPlotTest >> testPatchesAreAboveTheGrid [

	self assert: self boxPlot isAboveGrid
]

{ #category : 'tests' }
BpBoxPlotTest >> testPositionsAndWidths [

	self
		assert: ((self boxPlot
			  positions: #( 4 );
			  widths: 2;
			  yourself) parts at: #boxes) first dataBounds
		equals: (3 @ (13 / 4) corner: 5 @ (31 / 4))
]

{ #category : 'tests - errors' }
BpBoxPlotTest >> testPositionsOfAnotherSizeRaiseError [

	self should: [ self boxPlot positions: #( 1 2 ) ] raise: Error
]

{ #category : 'tests' }
BpBoxPlotTest >> testShowCapsAndShowBoxFalse [

	| parts |
	parts := (self boxPlot
		          showCaps: false;
		          showBox: false;
		          yourself) parts.
	self assert: (parts at: #caps) isEmpty.
	self assert: (parts at: #boxes) isEmpty
]

{ #category : 'tests' }
BpBoxPlotTest >> testShowFliersFalseHidesThem [

	self assert: ((self boxPlot
		  showFliers: false;
		  yourself) parts at: #fliers) isEmpty
]

{ #category : 'tests' }
BpBoxPlotTest >> testShowMeansAddsAGreenTriangle [

	| mean |
	mean := ((self boxPlot
		          showMeans: true;
		          yourself) parts at: #means) first.
	self assert: mean dataPoint equals: 1 @ (145 / 10).
	self assert: mean background paint color equals: (BpPalette default colorAt: 3)
]

{ #category : 'tests' }
BpBoxPlotTest >> testStatisticsOfEachDataset [

	| boxPlot |
	boxPlot := BpBoxPlot new
		           x: #( #( 1 2 3 ) #( 10 20 30 ) );
		           yourself.
	self assert: (boxPlot statistics collect: [ :each | each median ] as: Array) equals: #( 2 20 )
]

{ #category : 'tests - errors' }
BpBoxPlotTest >> testUnknownOrientationRaisesError [

	self should: [ self boxPlot orientation: #diagonal ] raise: Error
]

{ #category : 'tests' }
BpBoxPlotTest >> testWhiskerAndCapPropertiesStyleThem [

	| parts |
	parts := (self boxPlot
		          whiskerProperties: { (#color -> (BpPalette default colorAt: 1)) } asDictionary;
		          capProperties: { (#lineWidth -> 2) } asDictionary;
		          yourself) parts.
	self assert: (parts at: #whiskers) first border paint color equals: (BpPalette default colorAt: 1).
	self assert: ((parts at: #caps) first border width closeTo: 2 * self ppp)
]

{ #category : 'tests' }
BpBoxPlotTest >> testWhiskersGoFromTheBoxToTheExtremeData [

	| whiskers |
	whiskers := self boxPlot parts at: #whiskers.
	self assert: whiskers first dataVertices equals: {
		(1 @ (13 / 4)).
		(1 @ 1) }.
	self assert: whiskers second dataVertices equals: {
		(1 @ (31 / 4)).
		(1 @ 9) }
]

{ #category : 'tests' }
BpBoxPlotTest >> testWhiskersSetting [

	self assert: ((self boxPlot
		  whiskers: #( 0 100 );
		  yourself) parts at: #fliers) isEmpty
]
