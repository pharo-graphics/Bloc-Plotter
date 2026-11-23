"
I test `BpKiviat`, its rows and its axes: the scales shared by the axes or their own, the labels, the rings and frame, the legend, the rendering and the interaction of the rows, and the errors for rows that do not match the axes.
"
Class {
	#name : 'BpKiviatTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpKiviatTest >> assertRadiiOf: aRow are: aCollection [

	(self radiiOf: aRow) with: aCollection do: [ :found :expected | self assert: found closeTo: expected ].
	self assert: aRow polygonPatch dataVertices size equals: aCollection size
]

{ #category : 'tests' }
BpKiviatTest >> namesOf: aKiviat [

	^ (aKiviat ticks select: [ :each | each axis = #x ] thenCollect: [ :each | each label text asString ]) asArray
]

{ #category : 'tests' }
BpKiviatTest >> newKiviat [
	"Answer a kiviat of four axes: up, left, down and right."

	^ BpKiviat new
		  extent: 400 @ 400;
		  axisNames: #( 'a' 'b' 'c' 'd' );
		  yourself
]

{ #category : 'tests' }
BpKiviatTest >> radiiOf: aRow [
	"Answer the fractions of the radius at which aRow shows its values."

	^ aRow polygonPatch dataVertices collect: [ :each | each y ]
]

{ #category : 'tests' }
BpKiviatTest >> ringLabelsOf: aKiviat at: anIndex [
	"Answer the labels along the axis at anIndex, from the center to the edge."

	| angle |
	angle := aKiviat angleAt: anIndex.
	^ (aKiviat ticks select: [ :each | each axis = #y and: [ each angle = angle ] ] thenCollect: [ :each | each label text asString ])
		  asArray
]

{ #category : 'tests' }
BpKiviatTest >> testAddRowAnswersARowOfTheKiviat [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( 1 2 3 4 ).
	self assert: row chart identicalTo: kiviat.
	self assert: kiviat rows asArray equals: { row }.
	self assert: row values equals: #( 1 2 3 4 )
]

{ #category : 'tests' }
BpKiviatTest >> testAddRowsAnswersTheRows [

	| kiviat |
	kiviat := self newKiviat.
	self assert: (kiviat addRows: #( #( 1 2 3 4 ) #( 4 3 2 1 ) )) asArray equals: kiviat rows asArray
]

{ #category : 'tests' }
BpKiviatTest >> testAxesAreEvenlySpaced [

	self assert: (self newKiviat angleAt: 2) closeTo: Float halfPi
]

{ #category : 'tests' }
BpKiviatTest >> testAxesAreNumberedWithoutNames [

	| kiviat |
	kiviat := BpKiviat new.
	kiviat addRow: #( 5 6 7 ).
	self assert: (self namesOf: kiviat) equals: #( '1' '2' '3' )
]

{ #category : 'tests' }
BpKiviatTest >> testAxesShareTheirScaleByDefault [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( 1 2 3 5 ).
	self assertRadiiOf: row are: #( 0.2 0.4 0.6 1 )
]

{ #category : 'tests' }
BpKiviatTest >> testAxisLimitsMoveTheRowsAlreadyAdded [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	row := kiviat addRow: #( 1 2 3 5 ).
	(kiviat axisAt: 4) limits: #( 0 5 ).
	self assertRadiiOf: row are: #( 0.1 0.2 0.3 1 )
]

{ #category : 'tests' }
BpKiviatTest >> testAxisLimitsWinOverTheOnesOfTheKiviat [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	(kiviat axisAt: 2) limits: #( 0 4 ).
	row := kiviat addRow: #( 1 2 3 5 ).
	self assertRadiiOf: row are: #( 0.1 0.5 0.3 0.5 )
]

{ #category : 'tests' }
BpKiviatTest >> testAxisNamedAnswersTheAxis [

	| kiviat |
	kiviat := self newKiviat.
	self assert: (kiviat axisNamed: 'b') identicalTo: (kiviat axisAt: 2)
]

{ #category : 'tests' }
BpKiviatTest >> testAxisNamesLabelTheAxes [

	self assert: (self namesOf: self newKiviat) equals: #( 'a' 'b' 'c' 'd' )
]

{ #category : 'tests - errors' }
BpKiviatTest >> testAxisNamesOfAnotherSizeThanTheRowsRaiseError [

	| kiviat |
	kiviat := self newKiviat.
	kiviat addRow: #( 1 2 3 4 ).
	self
		should: [ kiviat axisNames: #( 'a' 'b' ) ]
		raise: Error
		whoseDescriptionIncludes: '4 values for 2 axes'
		description: 'the sizes differ'
]

{ #category : 'tests' }
BpKiviatTest >> testAxisWithItsOwnLimitsDoesNotCountInTheSharedScale [

	| kiviat row |
	kiviat := self newKiviat.
	(kiviat axisAt: 4) limits: #( 0 1000 ).
	row := kiviat addRow: #( 1 2 5 500 ).
	self assertRadiiOf: row are: #( 0.2 0.4 1 0.5 )
]

{ #category : 'tests' }
BpKiviatTest >> testBeCircularMakesTheRingsCircles [

	| kiviat |
	kiviat := self newKiviat.
	kiviat beCircular.
	self deny: kiviat isPolygonal.
	self assert:
		((kiviat plotArea gridLines select: [ :each | each axis = #y ]) allSatisfy: [ :each | each geometry isKindOf: BlCircleGeometry ]).
	self assert: (kiviat plotArea geometry isKindOf: BlCircleGeometry)
]

{ #category : 'tests' }
BpKiviatTest >> testChangingTheValuesMovesTheRow [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	row := kiviat addRow: #( 1 2 3 5 ).
	row values: #( 5 5 5 5 ).
	self assertRadiiOf: row are: #( 0.5 0.5 0.5 0.5 )
]

{ #category : 'tests' }
BpKiviatTest >> testClickInsideTheRowReachesIt [

	| kiviat row clicked |
	clicked := nil.
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	row := kiviat addRow: #( 5 5 5 5 ).
	row whenPatch: BlClickEvent do: [ :event :patch | clicked := patch ].
	kiviat inNewHeadlessSpaceDo: [ :space |
		space settle.
		kiviat eventSimulator clickAt: kiviat plotBounds center + (10 @ 10) ].
	self assert: clicked identicalTo: row polygonPatch
]

{ #category : 'tests' }
BpKiviatTest >> testDifferentScalesAreLabeledOnEachAxis [

	| kiviat |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	(kiviat axisAt: 2) limits: #( 50 0 ).
	self assert: (self ringLabelsOf: kiviat at: 1) equals: #( '2' '4' '6' '8' '10' ).
	self assert: (self ringLabelsOf: kiviat at: 2) equals: #( '40' '30' '20' '10' '0' )
]

{ #category : 'tests' }
BpKiviatTest >> testEachAxisHasALine [

	| kiviat |
	kiviat := self newKiviat.
	self assert: (kiviat plotArea gridLines count: [ :each | each axis = #x ]) equals: 4
]

{ #category : 'tests' }
BpKiviatTest >> testEqualZeroValuesAreAtTheCenter [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( 0 0 0 0 ).
	self assertRadiiOf: row are: #( 0 0 0 0 )
]

{ #category : 'tests' }
BpKiviatTest >> testFillFalseLeavesTheOutline [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( 1 2 3 4 ).
	row fill: false.
	self assert: row polygonPatch background paint color isTransparent.
	self deny: row polygonPatch border paint color isTransparent
]

{ #category : 'tests' }
BpKiviatTest >> testFirstAxisIsAtTheTop [

	| kiviat |
	kiviat := self newKiviat.
	self assert: kiviat startAngle equals: 90.
	self assert: (kiviat angleAt: 1) equals: 0
]

{ #category : 'tests' }
BpKiviatTest >> testGridFalseRemovesTheRings [

	| kiviat |
	kiviat := self newKiviat.
	kiviat grid: false.
	self assert: kiviat plotArea gridLines isEmpty
]

{ #category : 'tests' }
BpKiviatTest >> testInvertedLimitsPutTheLowValuesOutside [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	(kiviat axisAt: 1) limits: #( 10 0 ).
	row := kiviat addRow: #( 2 2 2 2 ).
	self assertRadiiOf: row are: #( 0.8 0.2 0.2 0.2 )
]

{ #category : 'tests' }
BpKiviatTest >> testLabelsStayInTheKiviat [

	| kiviat |
	kiviat := self newKiviat.
	kiviat
		axisNames: #( 'mechanical properties' 'chemical stability' 'thermal stability' 'device integration' 'cost' );
		title: 'A title'.
	kiviat inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: (kiviat ticks allSatisfy: [ :each |
			 ((0 @ 0 extent: kiviat extent) expandBy: 0.01) containsRect: each label bounds inParent asRectangle ]) ]
]

{ #category : 'tests' }
BpKiviatTest >> testLegendShowsTheLabelsOfTheRows [

	| kiviat |
	kiviat := self newKiviat.
	(kiviat addRow: #( 1 2 3 4 )) label: 'first'.
	kiviat addRow: #( 1 1 1 1 ).
	(kiviat addRow: #( 4 3 2 1 )) label: 'third'.
	kiviat legend.
	self assert: kiviat legendElement labels asArray equals: #( 'first' 'third' )
]

{ #category : 'tests' }
BpKiviatTest >> testLimitsAreGivenToAllAxes [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	row := kiviat addRow: #( 1 2 3 5 ).
	self assertRadiiOf: row are: #( 0.1 0.2 0.3 0.5 )
]

{ #category : 'tests' }
BpKiviatTest >> testLiveElementOfARowAloneIsAKiviat [

	| row |
	row := BpKiviatRow new
		       values: #( 1 2 3 );
		       yourself.
	self assert: row liveElement charts first class equals: BpKiviat.
	self assert: (row liveElement isKindOf: BpFigure)
]

{ #category : 'tests' }
BpKiviatTest >> testLogAxis [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	(kiviat axisAt: 1)
		scale: #log;
		limits: #( 1 10000 ).
	row := kiviat addRow: #( 100 2 2 2 ).
	self assertRadiiOf: row are: #( 0.5 0.2 0.2 0.2 )
]

{ #category : 'tests' }
BpKiviatTest >> testLogAxisCoversWholeDecades [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat shareScale: false.
	(kiviat axisAt: 1) scale: #log.
	row := kiviat addRow: #( 10 5 5 5 ).
	kiviat addRow: #( 300 5 5 5 ).
	self assert: (kiviat axisAt: 1) shownLimits equals: #( 10 1000 ).
	self assertRadiiOf: row are: #( 0 1 1 1 )
]

{ #category : 'tests' }
BpKiviatTest >> testLogAxisIgnoresLimitsIncludingZero [

	| kiviat |
	kiviat := self newKiviat.
	kiviat limits: #( 0 10 ).
	(kiviat axisAt: 1) scale: #log.
	kiviat addRow: #( 20 2 2 2 ).
	self assert: (kiviat axisAt: 1) shownLimits equals: #( 10 100 ).
	self assert: (kiviat axisAt: 2) shownLimits equals: #( 0 10 )
]

{ #category : 'tests' }
BpKiviatTest >> testLogAxisLabels [

	| kiviat |
	kiviat := self newKiviat.
	kiviat ringCount: 4.
	(kiviat axisAt: 1)
		scale: #log;
		limits: #( 1 10000 ).
	self assert: (self ringLabelsOf: kiviat at: 1) equals: #( '10' '100' '1000' '10000' )
]

{ #category : 'tests' }
BpKiviatTest >> testLogScaleOfValuesBelowTheLimitIsAtTheCenter [

	| kiviat row points |
	kiviat := self newKiviat.
	(kiviat axisAt: 1)
		scale: #log;
		limits: #( 10 1000 ).
	row := kiviat addRow: #( 1 5 5 5 ).
	kiviat plotBounds: (0 @ 0 corner: 100 @ 100).
	points := row polygonPatch dataVertices collect: [ :each | kiviat dataTransform pointFor: each ].
	self assert: points first equals: 50 @ 50
]

{ #category : 'tests' }
BpKiviatTest >> testMarkersAreOnTheValues [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( 1 2 3 5 ).
	row showMarkers: true.
	self assert: (row markerPatches collect: [ :each | each dataPoint ] as: Array) equals: row polygonPatch dataVertices
]

{ #category : 'tests' }
BpKiviatTest >> testMarkersFollowTheScale [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( 1 2 3 5 ).
	row showMarkers: true.
	kiviat limits: #( 0 10 ).
	self assert: row markerPatches last dataPoint y equals: 1 / 2
]

{ #category : 'tests' }
BpKiviatTest >> testNegativeValuesMoveTheCenter [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( -5 0 5 10 ).
	self assert: (kiviat axisAt: 1) shownLimits equals: #( -5 20 ).
	self assertRadiiOf: row are: #( 0 0.2 0.4 0.6 )
]

{ #category : 'tests' }
BpKiviatTest >> testNoMarkerByDefault [

	self assert: (self newKiviat addRow: #( 1 2 3 4 )) markerPatches isEmpty
]

{ #category : 'tests' }
BpKiviatTest >> testPolygonalFrameHasACornerPerAxis [

	| kiviat |
	kiviat := self newKiviat.
	kiviat inNewHeadlessSpaceDo: [ :space |
		| side |
		space settle.
		side := kiviat plotArea width.
		self assert: kiviat plotArea geometry vertices size equals: 4.
		self assert: (kiviat plotArea geometry vertices first x closeTo: side / 2).
		self assert: (kiviat plotArea geometry vertices first y closeTo: 0 precision: 0.001) ]
]

{ #category : 'tests' }
BpKiviatTest >> testRingCountSetsTheRings [

	| kiviat |
	kiviat := self newKiviat.
	kiviat
		limits: #( 0 8 );
		ringCount: 4.
	self
		assert: (kiviat plotArea gridLines select: [ :each | each axis = #y ] thenCollect: [ :each | each location ]) asArray
		equals: {
			(1 / 4).
			(1 / 2).
			(3 / 4) }
]

{ #category : 'tests' }
BpKiviatTest >> testRingLabelsAreRounded [

	| kiviat |
	kiviat := self newKiviat.
	kiviat
		limits: #( 0 10 );
		ringCount: 3.
	self assert: (self ringLabelsOf: kiviat at: 1) equals: #( '3.3' '6.7' '10.0' )
]

{ #category : 'tests' }
BpKiviatTest >> testRingsArePolygonsByDefault [

	| kiviat rings |
	kiviat := self newKiviat.
	rings := kiviat plotArea gridLines select: [ :each | each axis = #y ].
	self assert: rings size equals: 4.
	self assert: (rings allSatisfy: [ :each | each geometry isKindOf: BlPolygonGeometry ]).
	self assert: kiviat isPolygonal
]

{ #category : 'tests' }
BpKiviatTest >> testRowIsFilledWithItsTransparentColor [

	| kiviat row color |
	color := BpQualitativePalette set1 colorAt: 3.
	kiviat := self newKiviat.
	row := kiviat addRow: #( 1 2 3 4 ).
	row
		color: color;
		alpha: 0.5.
	self assert: row polygonPatch background paint color equals: (color alpha: 0.5).
	self assert: row polygonPatch border paint color equals: color
]

{ #category : 'tests' }
BpKiviatTest >> testRowIsPaintedOnItsValues [
	"The row is a square of half the radius."

	| kiviat color form center radius |
	color := BpQualitativePalette set1 colorAt: 1.
	kiviat := self newKiviat.
	kiviat
		limits: #( 0 10 );
		grid: false.
	(kiviat addRow: #( 5 5 5 5 ))
		color: color;
		alpha: 1.
	form := kiviat asForm.
	center := kiviat plotBounds center.
	radius := kiviat plotBounds width / 2.
	self assert: (form colorAt: (center + (0 @ (radius * 0.4))) rounded) equals: color.
	self assert: (form colorAt: (center + (0 @ (radius * 0.6))) rounded) equals: Color white.
	self assert: (form colorAt: (center + (radius * 0.4) asPoint) rounded) equals: Color white
]

{ #category : 'tests - errors' }
BpKiviatTest >> testRowOfAnotherSizeRaisesError [

	| kiviat |
	kiviat := self newKiviat.
	self
		should: [ kiviat addRow: #( 1 2 3 ) ]
		raise: Error
		whoseDescriptionIncludes: '3 values for 4 axes'
		description: 'the sizes differ'
]

{ #category : 'tests' }
BpKiviatTest >> testRowsTakeTheColorsOfThePalette [

	| kiviat second |
	kiviat := self newKiviat.
	kiviat palette: BpQualitativePalette set1.
	kiviat addRow: #( 1 2 3 4 ).
	second := kiviat addRow: #( 4 3 2 1 ).
	self assert: second polygonPatch border paint color equals: (BpQualitativePalette set1 colorAt: 2)
]

{ #category : 'tests' }
BpKiviatTest >> testShareScaleFalseScalesEachAxisOnItsValues [

	| kiviat row |
	kiviat := self newKiviat.
	kiviat shareScale: false.
	row := kiviat addRow: #( 1 20 50 100 ).
	kiviat addRow: #( 5 100 25 1000 ).
	self assertRadiiOf: row are: #( 0.2 0.2 1 0.1 )
]

{ #category : 'tests' }
BpKiviatTest >> testSharedScaleCoversAllRows [

	| kiviat row |
	kiviat := self newKiviat.
	row := kiviat addRow: #( 1 2 3 5 ).
	kiviat addRow: #( 10 10 10 10 ).
	self assertRadiiOf: row are: #( 0.1 0.2 0.3 0.5 )
]

{ #category : 'tests' }
BpKiviatTest >> testSharedScaleIsLabeledOnTheFirstAxisOnly [

	| kiviat |
	kiviat := self newKiviat.
	kiviat addRow: #( 1 2 3 5 ).
	self assert: (self ringLabelsOf: kiviat at: 1) equals: #( '1' '2' '3' '4' '5' ).
	self assert: (self ringLabelsOf: kiviat at: 2) isEmpty
]

{ #category : 'tests' }
BpKiviatTest >> testTickFormatterLabelsTheAxis [

	| kiviat |
	kiviat := self newKiviat.
	kiviat limits: #( 0 100 ).
	(kiviat axisAt: 1) tickFormatter: [ :each | each printString , ' %' ].
	self assert: (self ringLabelsOf: kiviat at: 1) first equals: '20 %'
]

{ #category : 'tests' }
BpKiviatTest >> testTwoAxesHaveACircularFrame [

	| kiviat |
	kiviat := BpKiviat new.
	kiviat addRow: #( 1 2 ).
	self deny: kiviat isPolygonal
]

{ #category : 'tests - errors' }
BpKiviatTest >> testUnknownAxisRaisesError [

	self should: [ self newKiviat axisNamed: 'z' ] raise: NotFound
]

{ #category : 'tests - errors' }
BpKiviatTest >> testUnknownScaleRaisesError [

	| axis |
	axis := self newKiviat axisAt: 1.
	self
		should: [ axis scale: #cubic ]
		raise: Error
		whoseDescriptionIncludes: 'Unknown scale'
		description: 'the scale is unknown'
]

{ #category : 'tests' }
BpKiviatTest >> testValueLabelsStayInsideTheFrame [
	"The label of the edge would overlap the name of the axis."

	| kiviat bounds |
	kiviat := self newKiviat.
	(kiviat axisAt: 2) limits: #( 0 100000 ).
	kiviat inNewHeadlessSpaceDo: [ :space |
		space settle.
		bounds := kiviat ticks select: [ :each | each axis = #y ] thenCollect: [ :each | each label bounds inParent asRectangle ].
		self assert: (bounds allSatisfy: [ :each | (kiviat plotBounds expandBy: 0.01) containsRect: each ]) ]
]

{ #category : 'tests - errors' }
BpKiviatTest >> testValuesOfAnotherSizeRaiseError [

	| row |
	row := self newKiviat addRow: #( 1 2 3 4 ).
	self
		should: [ row values: #( 1 2 ) ]
		raise: Error
		whoseDescriptionIncludes: '2 values for 4 axes'
		description: 'the sizes differ'
]
