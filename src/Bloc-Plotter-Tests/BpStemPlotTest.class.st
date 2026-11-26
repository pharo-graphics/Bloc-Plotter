"
I check `BpStemPlot`: the stems from the bottom to the heads, the markers on the heads, the baseline across the locations, the default colors and widths, the three format strings, horizontal stems, the legend entry and the colors of the palette.

## Implementation Notes

- My fixture has three stems at 1, 2 and 3, with heads 4, -1 and 2.
- The stem plot is not in a figure: the parts are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpStemPlotTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpStemPlotTest >> ppp [

	^ BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpStemPlotTest >> stems [
	"Three stems at 1, 2 and 3, with heads 4, -1 and 2."

	^ BpStemPlot new
		  locations: #( 1 2 3 ) heads: #( 4 -1 2 );
		  yourself
]

{ #category : 'tests' }
BpStemPlotTest >> testBaseFormatAndColorStyleTheBaseline [

	| baseline |
	baseline := (self stems
		             baseFormat: ':';
		             baseColor: Color black;
		             yourself) baseLine.
	self assert: baseline border paint color equals: Color black.
	self deny: baseline border style dashArray isEmpty
]

{ #category : 'tests' }
BpStemPlotTest >> testBaselineJoinsTheFirstAndTheLastLocations [

	self assert: self stems baseLine dataVertices equals: {
		(1 @ 0).
		(3 @ 0) }
]

{ #category : 'tests' }
BpStemPlotTest >> testBlankBaseFormatHidesTheBaseline [

	| stems |
	stems := self stems
		         baseFormat: ' ';
		         yourself.
	self assert: stems baseLine isNil.
	self assert: stems patches size equals: 6
]

{ #category : 'tests' }
BpStemPlotTest >> testBottomMovesTheStemsAndTheBaseline [

	| stems |
	stems := self stems
		         bottom: 1;
		         yourself.
	self assert: stems stemLines first dataVertices equals: {
		(1 @ 1).
		(1 @ 4) }.
	self assert: stems baseLine dataVertices equals: {
		(1 @ 1).
		(3 @ 1) }
]

{ #category : 'tests - instances' }
BpStemPlotTest >> testChartStemAddsAStemPlotToTheChart [

	| chart stems |
	chart := BpChart new.
	stems := chart stem: #( 4 -1 2 ).
	self assert: chart artists asArray equals: { stems }
]

{ #category : 'tests' }
BpStemPlotTest >> testChartStemLocationsHeadsAddsAStemPlot [

	| chart stems |
	chart := BpChart new.
	stems := chart stemLocations: #( 1 2 ) heads: #( 3 4 ).
	self assert: stems chart identicalTo: chart.
	self assert: (chart artists includes: stems).
	self assert: stems markerLine size equals: 2
]

{ #category : 'tests - palette' }
BpStemPlotTest >> testDefaultBaselineIsTheFourthColorOfThePalette [

	self assert: self stems baseLine border paint color equals: (BpQualitativePalette tab10 colorAt: 4)
]

{ #category : 'tests' }
BpStemPlotTest >> testDefaultSizes [

	| stems |
	stems := self stems.
	self assert: (stems stemLines first border width closeTo: 1.5 * self ppp).
	self assert: (stems baseLine border width closeTo: 1.5 * self ppp).
	self assert: stems markerLine first area equals: 36
]

{ #category : 'tests' }
BpStemPlotTest >> testDefaultStemsAndMarkersAreCirclesOfTheFirstColor [

	| stems marker |
	stems := self stems.
	marker := stems markerLine first.
	self assert: stems stemLines first border paint color equals: (BpPalette default colorAt: 1).
	self assert: marker background paint color equals: (BpPalette default colorAt: 1).
	self assert: marker marker isCircle
]

{ #category : 'tests - palette' }
BpStemPlotTest >> testDefaultStyleTakesTheColorsOfThePalette [

	| chart palette stems |
	palette := BpQualitativePalette set1.
	chart := BpChart new.
	chart palette: palette.
	stems := chart stem: #( 1 2 ).
	self assert: stems stemLines first border paint color equals: (palette colorAt: 1).
	self assert: stems baseLine border paint color equals: (palette colorAt: 4)
]

{ #category : 'tests' }
BpStemPlotTest >> testHandlersAreKeptWhenTheStemsAreRebuilt [

	| stems clicked |
	stems := self stems.
	clicked := nil.
	stems whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	stems lineFormat: '--'.
	BlEvent fireEvent: BlClickEvent new target: stems markerLine second.
	self assert: clicked identicalTo: stems markerLine second
]

{ #category : 'tests' }
BpStemPlotTest >> testHeadsAloneAreLocatedFromZero [

	self
		assert: ((BpStemPlot new
			  heads: #( 5 6 );
			  yourself) markerLine collect: [ :each | each dataPoint ] as: Array)
		equals: {
			(0 @ 5).
			(1 @ 6) }
]

{ #category : 'tests' }
BpStemPlotTest >> testHorizontalSwapsTheCoordinates [

	| stems |
	stems := self stems
		         orientation: #horizontal;
		         yourself.
	self assert: stems stemLines first dataVertices equals: {
		(0 @ 1).
		(4 @ 1) }.
	self assert: stems baseLine dataVertices equals: {
		(0 @ 1).
		(0 @ 3) }
]

{ #category : 'tests - instances' }
BpStemPlotTest >> testInstanceExpSineHas41Stems [

	self assert: BpStemPlot instanceExpSine stemLines size equals: 41
]

{ #category : 'tests - instances' }
BpStemPlotTest >> testInstanceExpSineStyledStandsOnABaselineAt1Point1 [

	self assert: (BpStemPlot instanceExpSineStyled stemLines first dataVertices first y closeTo: 1.1)
]

{ #category : 'tests - instances' }
BpStemPlotTest >> testInstancePlotTypeHasEightStems [

	self assert: BpStemPlot instancePlotType stemLines size equals: 8
]

{ #category : 'tests - instances' }
BpStemPlotTest >> testInstanceStemsHasFiveStems [

	self assert: BpStemPlot instanceStems stemLines size equals: 5
]

{ #category : 'tests' }
BpStemPlotTest >> testLabelGivesALegendEntry [

	self
		assert: ((self stems
			  label: 'data';
			  yourself) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'data' )
]

{ #category : 'tests' }
BpStemPlotTest >> testLineColorColorsTheStemsAndTheMarkers [

	| stems |
	stems := self stems
		         lineColor: Color red;
		         yourself.
	self assert: stems stemLines first border paint color equals: Color red.
	self assert: stems markerLine first background paint color equals: Color red
]

{ #category : 'tests' }
BpStemPlotTest >> testLineFormatStylesTheStems [

	self deny: (self stems
		 lineFormat: '--';
		 yourself) stemLines first border style dashArray isEmpty
]

{ #category : 'tests - errors' }
BpStemPlotTest >> testLocationsAndHeadsOfDifferentSizesRaiseError [

	self should: [ BpStemPlot new locations: #( 1 2 3 ) heads: #( 1 2 ) ] raise: Error
]

{ #category : 'tests' }
BpStemPlotTest >> testMarkerColorColorsOnlyTheMarkers [

	| stems |
	stems := self stems
		         markerColor: Color red;
		         yourself.
	self assert: stems markerLine first background paint color equals: Color red.
	self assert: stems stemLines first border paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests' }
BpStemPlotTest >> testMarkerFaceColorTransparentMakesHollowMarkers [

	| marker |
	marker := (self stems
		           markerFaceColor: Color transparent;
		           yourself) markerLine first.
	self assert: marker background paint color equals: Color transparent.
	self assert: marker border paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests' }
BpStemPlotTest >> testMarkerFormatGivesTheMarker [

	self
		assert: (self stems
			 markerFormat: 'D';
			 yourself) markerLine first marker vertices size
		equals: 4
]

{ #category : 'tests' }
BpStemPlotTest >> testMarkersAreOnTheHeads [

	self assert: (self stems markerLine collect: [ :each | each dataPoint ] as: Array) equals: {
		(1 @ 4).
		(2 @ -1).
		(3 @ 2) }
]

{ #category : 'tests' }
BpStemPlotTest >> testNoLabelGivesNoLegendEntry [

	self assert: self stems legendEntries isEmpty
]

{ #category : 'tests' }
BpStemPlotTest >> testOneStemAndOneMarkerPerHead [

	| stems |
	stems := self stems.
	self assert: stems stemLines size equals: 3.
	self assert: stems markerLine size equals: 3
]

{ #category : 'tests' }
BpStemPlotTest >> testPartsAreDrawnStemsMarkersThenBaseline [

	| stems |
	stems := self stems.
	self assert: stems patches asArray equals: stems stemLines asArray , stems markerLine asArray , { stems baseLine }
]

{ #category : 'tests' }
BpStemPlotTest >> testStemGoesFromTheBottomToItsHead [

	self assert: self stems stemLines second dataVertices equals: {
		(2 @ 0).
		(2 @ -1) }
]

{ #category : 'tests - instances' }
BpStemPlotTest >> testStemLocatesTheHeadsFromZero [

	self assert: (BpStemPlot stem: #( 4 -1 2 )) locations asArray equals: #( 0 1 2 )
]

{ #category : 'tests - instances' }
BpStemPlotTest >> testStemLocationsHeadsAnswersAStemPlotWithoutChart [

	| stems |
	stems := BpStemPlot stemLocations: #( 1 2 3 ) heads: #( 4 -1 2 ).
	self assert: stems heads equals: #( 4 -1 2 ).
	self assert: stems markerLine size equals: 3
]

{ #category : 'tests' }
BpStemPlotTest >> testStemsAreAboveTheGrid [

	self assert: self stems isAboveGrid
]

{ #category : 'tests' }
BpStemPlotTest >> testStemsTakeNoColorOfTheCycle [

	| chart |
	chart := BpChart new.
	chart stem: #( 1 2 ).
	self assert: (chart plotX: #( 1 2 ) y: #( 1 2 )) linePatch border paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests - errors' }
BpStemPlotTest >> testUnknownFormatCharacterRaisesError [

	self should: [ self stems lineFormat: 'q' ] raise: Error
]

{ #category : 'tests - errors' }
BpStemPlotTest >> testUnknownOrientationRaisesError [

	self should: [ self stems orientation: #diagonal ] raise: Error
]
