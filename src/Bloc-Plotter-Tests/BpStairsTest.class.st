"
I check `BpStairs`, as `BpChart>>stairs:` and `BpChart>>stairs:edges:` create it: the vertices of the outline for each kind of baseline and for horizontal steps, the default edges, filled and unfilled styles, colors, line widths and styles, sticky baselines, the legend entry and handlers.

## Implementation Notes

- My fixture draws the steps 1, 3 and 2 between the edges 0, 1, 2 and 3. Fractions keep the expected vertices exact.
- The stairs are not in a figure: the polygon is checked in data coordinates and styles, not in pixels.
"
Class {
	#name : 'BpStairsTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpStairsTest >> stairs [
	"Three steps of heights 1, 3 and 2 between the edges 0, 1, 2 and 3."

	^ BpStairs new
		  values: #( 1 3 2 );
		  yourself
]

{ #category : 'tests' }
BpStairsTest >> stairsWith: aBlock [

	^ self stairs
		  in: aBlock;
		  yourself
]

{ #category : 'tests' }
BpStairsTest >> testAddArtistAddsStairsWithTheirEdges [

	| chart stairs |
	chart := BpChart new.
	stairs := chart addArtist: (BpStairs values: #( 1 3 2 ) edges: #( 0 1 3 6 )).
	self assert: chart artists last identicalTo: stairs.
	self assert: stairs edges asArray equals: #( 0 1 3 6 )
]

{ #category : 'tests' }
BpStairsTest >> testAlphaMakesTheOutlineTransparent [

	self assert:
		((self stairsWith: [ :stairs | stairs alpha: 0.3 ]) patches first border paint color alpha closeTo: 0.3 precision: 0.01)
]

{ #category : 'tests' }
BpStairsTest >> testBaselineCollectionIsFollowedUnderTheSteps [

	self
		assert: (self verticesOf: (self stairsWith: [ :stairs |
			  stairs baseline: {
				  0.
				  1.
				  (1 / 2) } ]))
		equals: {
			(0 @ 0).
			(0 @ 1).
			(1 @ 1).
			(1 @ 3).
			(2 @ 3).
			(2 @ 2).
			(3 @ 2).
			(3 @ (1 / 2)).
			(3 @ (1 / 2)).
			(3 @ (1 / 2)).
			(2 @ (1 / 2)).
			(2 @ 1).
			(1 @ 1).
			(1 @ 0).
			(0 @ 0).
			(0 @ 0) }
]

{ #category : 'tests' }
BpStairsTest >> testBaselineIsStickyOnTheValueAxis [

	self assert: ((self stairsWith: [ :stairs | stairs baseline: #( 2 1 3 ) ]) stickyValuesOn: #y) equals: #( 1 ).
	self assert: (self stairs stickyValuesOn: #x) isEmpty
]

{ #category : 'tests' }
BpStairsTest >> testBaselineNumberShiftsTheEnds [

	| vertices |
	vertices := self verticesOf: (self stairsWith: [ :stairs | stairs baseline: 1 / 2 ]).
	self assert: vertices first equals: 0 @ (1 / 2).
	self assert: vertices last equals: 3 @ (1 / 2)
]

{ #category : 'tests - errors' }
BpStairsTest >> testBaselineOfAnotherSizeRaisesError [

	self should: [ self stairs baseline: #( 0 1 ) ] raise: Error
]

{ #category : 'tests' }
BpStairsTest >> testColorSetsTheFillWhenFilled [

	| patch |
	patch := (self stairsWith: [ :stairs |
		          stairs
			          fill: true;
			          color: Color red ]) patches first.
	self assert: patch background paint color equals: Color red.
	self assert: patch border width isZero
]

{ #category : 'tests' }
BpStairsTest >> testColorSetsTheOutlineWhenUnfilled [

	self assert: (self stairsWith: [ :stairs | stairs color: Color red ]) patches first border paint color equals: Color red
]

{ #category : 'tests - instances' }
BpStairsTest >> testCurveInstancesAreNamedByTheirLegendEntry [

	self
		assert: ({
			 BpStairs instanceSineSteps.
			 BpStairs instanceCosineSteps.
			 BpStairs instanceHalfSineSteps } collect: [ :each | each legendEntries first key ])
		equals: #( 'sin' 'cos' 'half sin' )
]

{ #category : 'tests' }
BpStairsTest >> testDefaultEdgesAreTheIndices [

	self assert: self stairs edges asArray equals: #( 0 1 2 3 )
]

{ #category : 'tests - errors' }
BpStairsTest >> testEdgesOfAnotherSizeRaiseError [

	self should: [ self stairs edges: #( 0 1 2 ) ] raise: Error
]

{ #category : 'tests' }
BpStairsTest >> testEdgesPlaceTheSteps [

	self assert: (self verticesOf: (self stairsWith: [ :stairs | stairs edges: #( 0 1 3 6 ) ])) asArray equals: {
		(0 @ 0).
		(0 @ 1).
		(1 @ 1).
		(1 @ 3).
		(3 @ 3).
		(3 @ 2).
		(6 @ 2).
		(6 @ 0) }
]

{ #category : 'tests' }
BpStairsTest >> testFillFillsWithTheCycleColorWithoutOutline [

	| patch |
	patch := (self stairsWith: [ :stairs | stairs fill: true ]) patches first.
	self assert: patch isClosed.
	self assert: patch background paint color equals: (BpPalette default colorAt: 1).
	self assert: patch border width isZero
]

{ #category : 'tests' }
BpStairsTest >> testHandlersAreKeptWhenTheStairsAreRebuilt [

	| stairs clicked |
	stairs := self stairs.
	clicked := nil.
	stairs whenPatch: BlClickEvent do: [ :event :polygon | clicked := polygon ].
	stairs fill: true.
	BlEvent fireEvent: BlClickEvent new target: stairs patches first.
	self assert: clicked identicalTo: stairs patches first
]

{ #category : 'tests' }
BpStairsTest >> testHorizontalBaselineIsStickyOnX [

	self assert: ((self stairsWith: [ :stairs | stairs orientation: #horizontal ]) stickyValuesOn: #x) equals: #( 0 )
]

{ #category : 'tests' }
BpStairsTest >> testHorizontalSwapsTheCoordinates [

	| vertices |
	vertices := self verticesOf: (self stairsWith: [ :stairs | stairs orientation: #horizontal ]).
	self assert: (vertices first: 3) equals: {
		(0 @ 0).
		(1 @ 0).
		(1 @ 1) }
]

{ #category : 'tests - instances' }
BpStairsTest >> testInstanceEightStepsHasNineEdges [

	self assert: BpStairs instanceEightSteps edges size equals: 9
]

{ #category : 'tests' }
BpStairsTest >> testLabelGivesALegendEntry [

	self
		assert: ((self stairsWith: [ :stairs | stairs label: 'steps' ]) legendEntries collect: [ :each | each key ] as: Array)
		equals: #( 'steps' )
]

{ #category : 'tests' }
BpStairsTest >> testLineStyleDashesTheOutline [

	self deny: (self stairsWith: [ :stairs | stairs lineStyle: '--' ]) patches first border style dashArray isEmpty
]

{ #category : 'tests' }
BpStairsTest >> testLineWidthOutlinesTheFill [

	| patch |
	patch := (self stairsWith: [ :stairs |
		          stairs
			          fill: true;
			          faceColor: Color yellow;
			          edgeColor: Color black;
			          lineWidth: 2 ]) patches first.
	self assert: patch background paint color equals: Color yellow.
	self assert: patch border paint color equals: Color black.
	self assert: (patch border width closeTo: 2 * BpArtist pixelsPerPoint)
]

{ #category : 'tests' }
BpStairsTest >> testNoBaselineIsNotSticky [

	self assert: ((self stairsWith: [ :stairs | stairs baseline: nil ]) stickyValuesOn: #y) isEmpty
]

{ #category : 'tests' }
BpStairsTest >> testNoBaselineLeavesTheEndsOpen [

	self assert: (self verticesOf: (self stairsWith: [ :stairs | stairs baseline: nil ])) equals: {
		(0 @ 1).
		(0 @ 1).
		(1 @ 1).
		(1 @ 3).
		(2 @ 3).
		(2 @ 2).
		(3 @ 2).
		(3 @ 2) }
]

{ #category : 'tests' }
BpStairsTest >> testNoLabelGivesNoLegendEntry [

	self assert: self stairs legendEntries isEmpty
]

{ #category : 'tests' }
BpStairsTest >> testOutlineGoesUpAndDownTheStepsFromTheBaseline [

	self assert: (self verticesOf: self stairs) equals: {
		(0 @ 0).
		(0 @ 1).
		(1 @ 1).
		(1 @ 3).
		(2 @ 3).
		(2 @ 2).
		(3 @ 2).
		(3 @ 0) }
]

{ #category : 'tests' }
BpStairsTest >> testStairsAreBelowTheGrid [

	self deny: self stairs isAboveGrid
]

{ #category : 'tests' }
BpStairsTest >> testStairsTakeTheNextColorOfTheCycle [

	| chart |
	chart := BpChart new.
	chart addArtist: (BpLine x: #( 0 1 ) y: #( 0 1 )).
	self assert: (chart addArtist: (BpStairs values: #( 1 2 ))) patches first border paint color equals: (BpPalette default colorAt: 2)
]

{ #category : 'tests - instances' }
BpStairsTest >> testStepHistogramOnABaselineIsShiftedByFive [

	| simple shifted |
	simple := BpStairs instanceStepHistogram.
	shifted := BpStairs instanceStepHistogramOnABaseline.
	self assert: shifted edges size equals: simple edges size.
	self assert: shifted edges first equals: simple edges first + 5
]

{ #category : 'tests' }
BpStairsTest >> testUnfilledIsAnOpenOutlineInTheCycleColor [

	| patch |
	patch := self stairs patches first.
	self deny: patch isClosed.
	self assert: patch background paint color equals: Color transparent.
	self assert: patch border paint color equals: (BpPalette default colorAt: 1).
	self assert: (patch border width closeTo: BpArtist pixelsPerPoint)
]

{ #category : 'tests - errors' }
BpStairsTest >> testUnknownOrientationRaisesError [

	self should: [ self stairs orientation: #diagonal ] raise: Error
]

{ #category : 'tests - instances' }
BpStairsTest >> testValuesCreatesStepsOnTheDefaultEdges [

	self assert: (BpStairs values: #( 1 3 2 )) edges asArray equals: #( 0 1 2 3 )
]

{ #category : 'tests' }
BpStairsTest >> verticesOf: aStairs [

	^ aStairs patches first dataVertices asArray
]
