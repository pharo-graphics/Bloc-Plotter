"
I check `BpErrorBar`, as `BpChart>>errorBarX:y:yErr:` and `BpChart>>errorBarX:y:xErr:yErr:` create it: the bars for each way of giving errors, caps, limits and their arrows, `errorEvery:`, colors and widths, the drawing order, the format, the legend swatch and handlers.

## Implementation Notes

- My fixture draws three points with the y errors 1, 2 and 3. The bars are not in a figure: patches are checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpErrorBarTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpErrorBarTest >> barsOf: anErrorBar [

	^ anErrorBar barPatches collect: [ :each | each dataVertices asArray ]
]

{ #category : 'tests' }
BpErrorBarTest >> capsOf: anErrorBar [

	^ anErrorBar capPatches collect: [ :each | each dataPoint ]
]

{ #category : 'tests' }
BpErrorBarTest >> errorBar [
	"Three points (1, 10), (2, 20) and (3, 30) with the y errors 1, 2 and 3."

	^ (BpErrorBar x: #( 1 2 3 ) y: #( 10 20 30 ))
		  yErr: #( 1 2 3 );
		  yourself
]

{ #category : 'tests' }
BpErrorBarTest >> errorBarWith: aBlock [

	^ self errorBar
		  in: aBlock;
		  yourself
]

{ #category : 'tests' }
BpErrorBarTest >> testAddArtistGivesTheNextColorToAnErrorBar [

	| chart errorBar |
	chart := BpChart new.
	chart addArtist: (BpLine x: #( 0 1 ) y: #( 0 1 )).
	errorBar := chart addArtist: ((BpErrorBar x: #( 1 2 ) y: #( 3 4 ))
		             yErr: 0.5;
		             yourself).
	self assert: chart artists last identicalTo: errorBar.
	self assert: errorBar barPatches first border paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests' }
BpErrorBarTest >> testAsymmetricErrorsGiveTheLowerThenTheUpperErrors [

	self assert: (self barsOf: (self errorBarWith: [ :bars | bars yErr: #( #( 1 1 1 ) #( 4 5 6 ) ) ])) first equals: {
		(1 @ 9).
		(1 @ 14) }
]

{ #category : 'tests - errors' }
BpErrorBarTest >> testAsymmetricErrorsOfAnotherSizeRaiseError [

	self should: [ self errorBar yErr: #( #( 1 1 1 ) #( 1 1 ) ) ] raise: Error
]

{ #category : 'tests' }
BpErrorBarTest >> testBarsAboveDrawsThemAfterTheLine [

	| errorBar |
	errorBar := self errorBarWith: [ :bars | bars barsAbove: true ].
	self assert: errorBar patches first identicalTo: errorBar linePatch.
	self assert: errorBar patches last identicalTo: errorBar barPatches last
]

{ #category : 'tests' }
BpErrorBarTest >> testBarsAreBelowTheLineByDefault [

	| errorBar |
	errorBar := self errorBar.
	self assert: errorBar patches first identicalTo: errorBar barPatches first.
	self assert: errorBar patches last identicalTo: errorBar linePatch
]

{ #category : 'tests' }
BpErrorBarTest >> testBothErrorsGiveTwoBarsPerPoint [

	self assert: (self errorBarWith: [ :bars | bars xErr: 0.1 ]) barPatches size equals: 6
]

{ #category : 'tests' }
BpErrorBarTest >> testCapSizeDrawsACapAtBothEndsOfEachBar [

	| errorBar |
	errorBar := self errorBarWith: [ :bars | bars capSize: 3 ].
	self assert: (self capsOf: errorBar) asArray equals: {
		(1 @ 9).
		(2 @ 18).
		(3 @ 27).
		(1 @ 11).
		(2 @ 22).
		(3 @ 33) }.
	self assert: errorBar capPatches first area equals: 36.
	self assert: errorBar capPatches first marker vertices equals: (BpMarker on: '_') vertices
]

{ #category : 'tests' }
BpErrorBarTest >> testCapThickSetsTheWidthOfTheCaps [

	| caps |
	caps := (self errorBarWith: [ :bars | bars capSize: 3 ]) capPatches.
	self assert: (caps first border width closeTo: BpArtist pixelsPerPoint).
	caps := (self errorBarWith: [ :bars |
		         bars
			         capSize: 3;
			         capThick: 2 ]) capPatches.
	self assert: (caps first border width closeTo: 2 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpErrorBarTest >> testCaretsHaveTheirBaseOnThePoint [

	self assert: (BpErrorBar caret: #up) vertices equals: {
		(-0.5 @ 0).
		(0 @ 0.75).
		(0.5 @ 0) }
]

{ #category : 'tests' }
BpErrorBarTest >> testDataLineJoinsThePoints [

	self assert: self errorBar linePatch dataVertices asArray equals: {
		(1 @ 10).
		(2 @ 20).
		(3 @ 30) }
]

{ #category : 'tests' }
BpErrorBarTest >> testErrorColorColorsTheBarsAndCaps [

	| errorBar |
	errorBar := self errorBarWith: [ :bars |
		            bars errorColor: Color black;
			            capSize: 2 ].
	self assert: errorBar barPatches first border paint color equals: Color black.
	self assert: errorBar capPatches first border paint color equals: Color black.
	self assert: errorBar linePatch border paint color equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests' }
BpErrorBarTest >> testErrorColorIsTheLineColorByDefault [

	| errorBar |
	errorBar := self errorBarWith: [ :bars |
		            bars
			            color: Color red;
			            capSize: 2 ].
	self assert: errorBar barPatches first border paint color equals: Color red.
	self assert: errorBar capPatches first border paint color equals: Color red
]

{ #category : 'tests' }
BpErrorBarTest >> testErrorEveryDrawsEveryNthBar [

	| errorBar |
	errorBar := (BpErrorBar x: (1 to: 5) y: (1 to: 5))
		            yErr: 1;
		            errorEvery: 2;
		            yourself.
	self assert: ((self barsOf: errorBar) collect: [ :each | each first x ]) equals: #( 1 3 5 )
]

{ #category : 'tests' }
BpErrorBarTest >> testErrorEveryStartingAtShiftsTheFirstBar [

	| errorBar |
	errorBar := (BpErrorBar x: (1 to: 7) y: (1 to: 7))
		            yErr: 1;
		            errorEvery: 3 startingAt: 2;
		            yourself.
	self assert: ((self barsOf: errorBar) collect: [ :each | each first x ]) equals: #( 2 5 )
]

{ #category : 'tests' }
BpErrorBarTest >> testErrorLineWidthIsTheLineWidthByDefault [

	self assert: (self errorBar barPatches first border width closeTo: 1.5 * BpArtist pixelsPerPoint).
	self assert:
		((self errorBarWith: [ :bars | bars lineWidth: 2 ]) barPatches first border width closeTo: 2 * BpArtist pixelsPerPoint).
	self assert:
		((self errorBarWith: [ :bars | bars errorLineWidth: 3 ]) barPatches first border width closeTo: 3 * BpArtist pixelsPerPoint)
]

{ #category : 'tests - errors' }
BpErrorBarTest >> testErrorsOfAnotherSizeRaiseError [

	self should: [ self errorBar yErr: #( 1 2 ) ] raise: Error
]

{ #category : 'tests - instances' }
BpErrorBarTest >> testEverySixthInstanceHasFewerBars [

	self assert: BpErrorBar instanceFastDecayEverySixth barPatches size < BpErrorBar instanceFastDecay barPatches size
]

{ #category : 'tests' }
BpErrorBarTest >> testFormatMarkerDrawsMarkersWithoutLine [

	| errorBar |
	errorBar := self errorBarWith: [ :bars | bars format: 'o' ].
	self assert: errorBar linePatch isNil.
	self assert: errorBar markerPatches size equals: 3
]

{ #category : 'tests' }
BpErrorBarTest >> testFormatNoneDrawsOnlyTheBars [

	| errorBar |
	errorBar := self errorBarWith: [ :bars | bars format: 'none' ].
	self assert: errorBar linePatch isNil.
	self assert: errorBar markerPatches isEmpty.
	self assert: errorBar patches size equals: 3
]

{ #category : 'tests' }
BpErrorBarTest >> testHandlersAreKeptWhenTheBarsAreRebuilt [

	| errorBar clicked |
	errorBar := self errorBar.
	clicked := nil.
	errorBar whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	errorBar capSize: 4.
	BlEvent fireEvent: BlClickEvent new target: errorBar barPatches first.
	self assert: clicked identicalTo: errorBar barPatches first
]

{ #category : 'tests - instances' }
BpErrorBarTest >> testInstanceMeasuresHasOneBarPerMeasure [

	self assert: BpErrorBar instanceMeasures barPatches size equals: 5
]

{ #category : 'tests - instances' }
BpErrorBarTest >> testInstanceSameErrorsHasBarsOnBothAxes [

	self assert: BpErrorBar instanceSameErrors barPatches size equals: 2 * BpErrorBar decayX size
]

{ #category : 'tests' }
BpErrorBarTest >> testLabelGivesALegendEntry [

	self
		assert: ((self errorBarWith: [ :bars | bars label: 'measures' ]) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'measures' )
]

{ #category : 'tests' }
BpErrorBarTest >> testLegendSwatchIsCrossedByAVerticalBar [

	| bar |
	bar := (self errorBarWith: [ :bars | bars label: 'measures' ]) legendEntries first value children first.
	self assert: bar geometry from equals: BpLine swatchExtent x / 2 @ 0.
	self assert: bar geometry to equals: BpLine swatchExtent x / 2 @ BpLine swatchExtent y
]

{ #category : 'tests - instances' }
BpErrorBarTest >> testLimitInstancesAreLabeled [

	self
		assert: ({
			 BpErrorBar instanceBothLimits.
			 BpErrorBar instanceUpperLimits.
			 BpErrorBar instanceUpperAndLowerLimits.
			 BpErrorBar instanceAlternateLimits } collect: [ :each | each legendEntries first key ])
		equals:
		#( 'both limits (default)' 'upperLimits: true' 'upperLimits: true, lowerLimits: true' 'subsets of upperLimits and lowerLimits' )
]

{ #category : 'tests' }
BpErrorBarTest >> testLimitsCanBeGivenPerPoint [

	| errorBar |
	errorBar := self errorBarWith: [ :bars | bars upperLimits: #( true false true ) ].
	self assert: ((self barsOf: errorBar) collect: [ :each | each last y ]) equals: #( 10 22 30 ).
	self assert: (self capsOf: errorBar) asArray equals: {
		(1 @ 9).
		(3 @ 27) }
]

{ #category : 'tests' }
BpErrorBarTest >> testLimitsWithCapsAddACapAtThePoint [

	self
		assert: (self capsOf: (self errorBarWith: [ :bars |
			  bars
				  upperLimits: true;
				  capSize: 3 ])) asArray
		equals: {
			(1 @ 9).
			(2 @ 18).
			(3 @ 27).
			(1 @ 10).
			(2 @ 20).
			(3 @ 30) }
]

{ #category : 'tests' }
BpErrorBarTest >> testLowerLimitsDrawTheBarAboveWithAnUpArrow [

	| errorBar |
	errorBar := self errorBarWith: [ :bars | bars lowerLimits: true ].
	self assert: (self barsOf: errorBar) first equals: {
		(1 @ 10).
		(1 @ 11) }.
	self assert: (self capsOf: errorBar) first equals: 1 @ 11.
	self assert: errorBar capPatches first marker vertices equals: (BpErrorBar caret: #up) vertices
]

{ #category : 'tests - errors' }
BpErrorBarTest >> testNegativeErrorsRaiseError [

	self should: [ self errorBar xErr: #( 1 -1 1 ) ] raise: Error
]

{ #category : 'tests' }
BpErrorBarTest >> testNoCapsByDefault [

	self assert: self errorBar capPatches isEmpty
]

{ #category : 'tests' }
BpErrorBarTest >> testNumberErrorAppliesToEveryPoint [

	self
		assert: ((self barsOf: (self errorBarWith: [ :bars | bars yErr: 5 ])) collect: [ :each | each first y ])
		equals: #( 5 15 25 )
]

{ #category : 'tests' }
BpErrorBarTest >> testSymmetricErrorsGiveABarAroundEachPoint [

	self assert: (self barsOf: self errorBar) equals: {
		{
			(1 @ 9).
			(1 @ 11) }.
		{
			(2 @ 18).
			(2 @ 22) }.
		{
			(3 @ 27).
			(3 @ 33) } }
]

{ #category : 'tests - errors' }
BpErrorBarTest >> testUnknownCaretRaisesError [

	self should: [ BpErrorBar caret: #diagonal ] raise: Error
]

{ #category : 'tests' }
BpErrorBarTest >> testUpperLimitsDrawTheBarBelowWithADownArrow [

	| errorBar |
	errorBar := self errorBarWith: [ :bars | bars upperLimits: true ].
	self assert: (self barsOf: errorBar) first equals: {
		(1 @ 9).
		(1 @ 10) }.
	self assert: (self capsOf: errorBar) asArray equals: {
		(1 @ 9).
		(2 @ 18).
		(3 @ 27) }.
	self assert: errorBar capPatches first marker vertices equals: (BpErrorBar caret: #down) vertices
]

{ #category : 'tests' }
BpErrorBarTest >> testXCapsAreVertical [

	self
		assert: (self errorBarWith: [ :bars |
			 bars
				 yErr: nil;
				 xErr: 1;
				 capSize: 3 ]) capPatches first marker vertices
		equals: (BpMarker on: '|') vertices
]

{ #category : 'tests' }
BpErrorBarTest >> testXErrAloneGivesOneBarPerPoint [

	| errorBar |
	errorBar := BpChart new addArtist: ((BpErrorBar x: #( 1 2 ) y: #( 3 4 ))
		             xErr: 0.1;
		             yourself).
	self assert: errorBar barPatches size equals: 2.
	self assert: (self barsOf: errorBar) first first y equals: 3
]

{ #category : 'tests' }
BpErrorBarTest >> testXErrorsGiveHorizontalBars [

	self
		assert: (self barsOf: (self errorBarWith: [ :bars |
			  bars
				  yErr: nil;
				  xErr: 1 / 2 ])) first
		equals: {
			(1 / 2 @ 10).
			(3 / 2 @ 10) }
]

{ #category : 'tests' }
BpErrorBarTest >> testXLimitsDrawSidewaysArrows [

	| errorBar |
	errorBar := self errorBarWith: [ :bars |
		            bars
			            yErr: nil;
			            xErr: 1;
			            xLowerLimits: true ].
	self assert: (self barsOf: errorBar) first equals: {
		(1 @ 10).
		(2 @ 10) }.
	self assert: errorBar capPatches first marker vertices equals: (BpErrorBar caret: #right) vertices
]
