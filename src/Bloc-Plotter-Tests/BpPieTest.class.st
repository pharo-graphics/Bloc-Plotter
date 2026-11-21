"
I test `BpPie`: its wedges and their angles, its texts and their placement, its layout, its rendering and the interaction handlers added to its wedges.
"
Class {
	#name : 'BpPieTest',
	#superclass : 'TestCase',
	#instVars : [
		'pie'
	],
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'helpers' }
BpPieTest >> clickAtAngle: anAngle distance: aDistance [
	"Click the pie, shown in a headless space, at anAngle and aDistance from its center, once it is laid out."

	pie inNewHeadlessSpaceDo: [ :space |
		space settle.
		pie eventSimulator clickAt: (pie pointAtAngle: anAngle distance: aDistance) ]
]

{ #category : 'helpers' }
BpPieTest >> layOutPie [
	"Lay the pie out in a headless space, as it would be once shown."

	pie inNewHeadlessSpaceDo: [ :space | space settle ]
]

{ #category : 'running' }
BpPieTest >> setUp [

	super setUp.
	pie := BpPie new
		       values: #( 15 30 45 10 );
		       yourself
]

{ #category : 'tests - texts' }
BpPieTest >> testAddLabelsDefaultDistance [

	pie addLabels: #( 'a' 'b' 'c' 'd' ).
	self assert: (pie texts allSatisfy: [ :each | each distance closeTo: 0.6 ])
]

{ #category : 'tests - texts' }
BpPieTest >> testAddLabelsWithFormat [

	pie addLabels: '{absval:d}\n{frac:.1%}'.
	self assert: pie texts first text asString equals: (String cr join: #( '15' '15.0%' ))
]

{ #category : 'tests - texts' }
BpPieTest >> testAutopctBlockReceivesPercent [

	pie autopct: [ :percent | percent rounded printString ].
	self assert: (pie texts collect: [ :each | each text asString ] as: Array) equals: #( '15' '30' '45' '10' )
]

{ #category : 'tests - texts' }
BpPieTest >> testAutopctCreatesPercentTexts [

	pie autopct: '%1.1f%%'.
	self assert: (pie texts collect: [ :each | each text asString ] as: Array) equals: #( '15.0%' '30.0%' '45.0%' '10.0%' )
]

{ #category : 'tests - texts' }
BpPieTest >> testAutopctTextsAreAtPctDistance [

	pie
		autopct: '%1.1f%%';
		pctDistance: 1.25.
	self assert: (pie texts allSatisfy: [ :each | each distance closeTo: 1.25 ])
]

{ #category : 'tests - wedges' }
BpPieTest >> testColorsAreGivenToWedges [

	| colors |
	colors := {
		          Color red.
		          Color green }.
	pie colors: colors.
	self assert: (pie wedges collect: [ :each | each background paint color ] as: Array) equals: {
		Color red.
		Color green.
		Color red.
		Color green }
]

{ #category : 'tests - wedges' }
BpPieTest >> testDefaultColorsFollowMatplotlibCycle [

	self assert: (pie wedges collect: [ :each | each background paint color ] as: Array) equals: (BpPie defaultColors first: 4)
]

{ #category : 'tests - texts' }
BpPieTest >> testEachLabelSetAddsOneTextPerWedge [

	pie
		labels: #( 'Frogs' 'Hogs' 'Dogs' 'Logs' );
		autopct: '%1.1f%%';
		addLabels: '{absval:d}' distance: 0.4.
	self assert: pie texts size equals: 12
]

{ #category : 'tests - wedges' }
BpPieTest >> testExplodeIsGivenToWedges [

	pie explode: #( 0 0.1 0 0 ).
	self assert: (pie wedges collect: [ :each | each explode ] as: Array) equals: #( 0 0.1 0 0 )
]

{ #category : 'tests - layout' }
BpPieTest >> testExplodedWedgeMovesAlongItsMidAngle [

	| offset |
	pie
		startAngle: 9;
		explode: #( 0.1 0 0 0 ).
	self layOutPie.
	"the first wedge is now centered on 36 degrees"
	offset := pie wedges first bounds inParent center - (200 @ 200).
	self assert: (offset x / offset y) negated closeTo: 36 degreesToRadians cos / 36 degreesToRadians sin precision: 0.01.
	self assert: offset r closeTo: pie wedges first width / 2 * 0.1 precision: 0.01
]

{ #category : 'tests - layout' }
BpPieTest >> testExplodedWedgesStayInsideThePie [

	pie explode: #( 0.5 0.5 0.5 0.5 ).
	self layOutPie.
	self assert: (pie wedges allSatisfy: [ :each | (0 @ 0 extent: pie extent) containsRect: each bounds inParent asRectangle ])
]

{ #category : 'tests - texts' }
BpPieTest >> testInsideTextIsCentered [

	pie addLabels: #( 'a' 'b' 'c' 'd' ) distance: 0.6.
	self assert: pie texts first alignment equals: #center
]

{ #category : 'tests - layout' }
BpPieTest >> testInsideTextIsCenteredOnItsAnchor [

	| text |
	pie addLabels: #( 'a' 'b' 'c' 'd' ) distance: 0.5.
	self layOutPie.
	text := pie texts first.
	self assert: text bounds inParent center closeTo: (pie anchorOf: text)
]

{ #category : 'tests - texts' }
BpPieTest >> testLabelsAddedBeforeValuesAreKept [

	pie := BpPie new
		       addLabels: '{absval:d}';
		       values: #( 1 2 );
		       yourself.
	self assert: (pie texts collect: [ :each | each text asString ] as: Array) equals: #( '1' '2' )
]

{ #category : 'tests - texts' }
BpPieTest >> testLabelsAreAtLabelDistance [

	pie
		labels: #( 'Frogs' 'Hogs' 'Dogs' 'Logs' );
		labelDistance: 0.6.
	self assert: (pie texts allSatisfy: [ :each | each distance closeTo: 0.6 ])
]

{ #category : 'tests - texts' }
BpPieTest >> testLabelsCreateTexts [

	pie labels: #( 'Frogs' 'Hogs' 'Dogs' 'Logs' ).
	self assert: (pie texts collect: [ :each | each text asString ] as: Array) equals: #( 'Frogs' 'Hogs' 'Dogs' 'Logs' )
]

{ #category : 'tests - texts' }
BpPieTest >> testLineBreakGivesOneLinePerLine [

	pie addLabels: '{absval:d}\n{frac:.1%}'.
	self assert: (pie texts first children collect: [ :each | each text asString ] as: Array) equals: #( '15' '15.0%' )
]

{ #category : 'tests - wedges' }
BpPieTest >> testNoShadowByDefault [

	self assert: pie shadows isEmpty
]

{ #category : 'tests - texts' }
BpPieTest >> testNoTextByDefault [

	self assert: pie texts isEmpty
]

{ #category : 'tests - wedges' }
BpPieTest >> testOneWedgePerValue [

	self assert: pie wedges size equals: 4.
	self assert: (pie wedges collect: [ :each | each amount ] as: Array) equals: #( 15 30 45 10 )
]

{ #category : 'tests - layout' }
BpPieTest >> testOutsideLeftAlignedTextStartsAtItsAnchor [

	| text anchor |
	pie addLabels: #( 'a' 'b' 'c' 'd' ) distance: 1.1.
	self layOutPie.
	text := pie texts first.
	anchor := pie anchorOf: text.
	self assert: text bounds inParent left closeTo: anchor x.
	self assert: text bounds inParent center y closeTo: anchor y
]

{ #category : 'tests - texts' }
BpPieTest >> testOutsideTextOnTheLeftIsRightAligned [

	pie addLabels: #( 'a' 'b' 'c' 'd' ) distance: 1.1.
	"third wedge is centered on 243 degrees"
	self assert: pie texts third alignment equals: #right
]

{ #category : 'tests - texts' }
BpPieTest >> testOutsideTextOnTheRightIsLeftAligned [

	pie addLabels: #( 'a' 'b' 'c' 'd' ) distance: 1.1.
	"first wedge is centered on 27 degrees"
	self assert: pie texts first alignment equals: #left
]

{ #category : 'tests - layout' }
BpPieTest >> testOutsideTextsShrinkThePie [

	pie
		extent: 300 @ 300;
		addLabels: #( 'a long label' 'a long label' 'a long label' 'a long label' ) distance: 1.1.
	self layOutPie.
	self assert: pie wedges first width < (300 / 1.25)
]

{ #category : 'tests - layout' }
BpPieTest >> testOutsideTextsStayInsideThePie [

	pie
		extent: 300 @ 300;
		addLabels: #( 'a long label' 'a long label' 'a long label' 'a long label' ) distance: 1.1.
	self layOutPie.
	self assert: (pie texts allSatisfy: [ :each | (0 @ 0 extent: pie extent) containsRect: each bounds inParent asRectangle ])
]

{ #category : 'tests - layout' }
BpPieTest >> testPieFillsTheFrameWithoutOutsideTexts [

	self layOutPie.
	self assert: pie wedges first width closeTo: 400 / 1.25
]

{ #category : 'tests - texts' }
BpPieTest >> testRotatedTextFollowsItsWedge [

	pie
		addLabels: #( 'a' 'b' 'c' 'd' )
		distance: 0.6
		rotate: true
		textStyle: nil.
	self assert: pie texts first rotationAngle equals: 27
]

{ #category : 'tests - texts' }
BpPieTest >> testRotatedTextOnTheLeftIsNotUpsideDown [

	pie
		addLabels: #( 'a' 'b' 'c' 'd' )
		distance: 0.6
		rotate: true
		textStyle: nil.
	"second wedge is centered on 108 degrees"
	self assert: pie texts second rotationAngle equals: -72
]

{ #category : 'tests - wedges' }
BpPieTest >> testShadowAddsOneShadowBehindEachWedge [

	pie shadow: true.
	self assert: pie shadows size equals: 4.
	self assert: (pie childIndexOf: pie shadows last) < (pie childIndexOf: pie wedges first)
]

{ #category : 'tests - texts' }
BpPieTest >> testTextIsNotRotatedByDefault [

	pie addLabels: #( 'a' 'b' 'c' 'd' ).
	self assert: pie texts first rotationAngle equals: 0
]

{ #category : 'tests - texts' }
BpPieTest >> testTextStyleIsAppliedToTheTexts [

	pie
		textStyle: [ :text | text foreground: Color white ];
		labels: #( 'Frogs' 'Hogs' 'Dogs' 'Logs' ).
	self assert: ((pie texts first text attributesAt: 1) anySatisfy: [ :each |
		 (each isKindOf: BlTextForegroundAttribute) and: [ each paint = Color white ] ])
]

{ #category : 'tests - interaction' }
BpPieTest >> testTextsDoNotHideWedgesFromClicks [

	| clicked |
	clicked := nil.
	pie
		autopct: '%1.1f%%';
		whenWedge: BlClickEvent do: [ :event :wedge | clicked := wedge ].
	"the percent text of the first wedge is centered there"
	self clickAtAngle: pie wedges first midAngle distance: pie pctDistance.
	self assert: clicked identicalTo: pie wedges first
]

{ #category : 'tests - texts' }
BpPieTest >> testTwoLineTextIsTallerThanOneLineText [

	pie
		addLabels: '{absval:d}\n{frac:.1%}';
		addLabels: '{absval:d}'.
	self layOutPie.
	self assert: pie texts first height > (pie texts fifth height * 1.5)
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeAnglesGoClockwiseWhenNotCounterclock [

	| second |
	pie
		startAngle: 90;
		counterclock: false.
	second := pie wedges second.
	self assert: second theta1 equals: 36.
	self assert: second theta2 equals: -72
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeAnglesGoCounterclockwiseFromStartAngle [

	| first |
	pie startAngle: 90.
	first := pie wedges first.
	self assert: first theta1 equals: 90.
	self assert: first theta2 equals: 144
]

{ #category : 'tests - layout' }
BpPieTest >> testWedgeDiameterFollowsRadius [

	| fullRadius |
	self layOutPie.
	fullRadius := pie wedges first width.
	pie radius: 0.5.
	self layOutPie.
	self assert: pie wedges first width equals: fullRadius / 2
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeFractionsAreNormalized [

	self assert: (pie wedges collect: [ :each | each fraction ] as: Array) equals: #( 0.15 0.3 0.45 0.1 )
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeFractionsAreNotNormalizedWhenAsked [

	pie
		normalize: false;
		values: #( 0.2 0.3 ).
	self assert: (pie wedges collect: [ :each | each fraction ] as: Array) equals: #( 0.2 0.3 )
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeGeometryUsesBlocAngles [
	"Bloc measures angles clockwise, matplotlib counterclockwise: the wedge from 90 to 144 degrees is the sector from -144 to -90."

	| geometry |
	pie startAngle: 90.
	geometry := pie wedges first geometry.
	self assert: geometry startAngle equals: -144.
	self assert: geometry endAngle equals: -90
]

{ #category : 'tests - rendering' }
BpPieTest >> testWedgeIsPaintedInItsSector [
	"Sample the middle of each wedge, half way to the rim."

	| form |
	pie colors: {
		Color red.
		Color green.
		Color blue.
		Color yellow }.
	form := pie asForm.
	pie wedges
		with: {
			Color red.
			Color green.
			Color blue.
			Color yellow }
		do: [ :wedge :color | self assert: (form colorAt: (pie pointAtAngle: wedge midAngle distance: 0.5) rounded) equals: color ]
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeLabelComesFromLabels [

	pie labels: #( 'Frogs' 'Hogs' 'Dogs' 'Logs' ).
	self assert: pie wedges second label equals: 'Hogs'
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeMidAngle [
	"The second wedge goes from 54 to 162 degrees."

	self assert: pie wedges second midAngle equals: 108
]

{ #category : 'tests - wedges' }
BpPieTest >> testWedgeStyleIsAppliedToEachWedge [

	pie wedgeStyle: [ :wedge | wedge opacity: 0.5 ].
	self assert: (pie wedges allSatisfy: [ :each | each opacity closeTo: 0.5 ])
]

{ #category : 'tests - layout' }
BpPieTest >> testWedgesAreCenteredInThePie [

	self layOutPie.
	self assert: pie wedges first bounds inParent center equals: 200 @ 200
]

{ #category : 'tests - interaction' }
BpPieTest >> testWhenWedgeDoReceivesTheClickedWedge [

	| clicked |
	clicked := nil.
	pie whenWedge: BlClickEvent do: [ :event :wedge | clicked := wedge ].
	self clickAtAngle: pie wedges third midAngle distance: 0.5.
	self assert: clicked identicalTo: pie wedges third
]

{ #category : 'tests - interaction' }
BpPieTest >> testWhenWedgeDoSurvivesARebuild [

	| clicked |
	clicked := nil.
	pie whenWedge: BlClickEvent do: [ :event :wedge | clicked := wedge ].
	pie colors: { Color red }.
	self clickAtAngle: pie wedges second midAngle distance: 0.5.
	self assert: clicked identicalTo: pie wedges second
]
