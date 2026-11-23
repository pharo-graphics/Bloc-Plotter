"
I test `BpTreeMap` and its boxes: the tree, the places, the labels, the colors and the interaction.
"
Class {
	#name : 'BpTreeMapTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpTreeMapTest >> boxLabeled: aString in: aMap [

	^ aMap boxes detect: [ :each | each label text asString = aString ]
]

{ #category : 'tests' }
BpTreeMapTest >> childrenOf: anObject [

	^ anObject isNumber
		  ifTrue: [ #(  ) ]
		  ifFalse: [ anObject allButFirst ]
]

{ #category : 'tests' }
BpTreeMapTest >> is: aColor within: anInteger of: anotherColor [
	"Answer whether the levels of both colors, between 0 and 255, differ by anInteger at most."

	^ (#( #red #green #blue ) collect: [ :each | ((aColor perform: each) - (anotherColor perform: each)) abs * 255 ]) max
	  < (anInteger + 0.5)
]

{ #category : 'tests' }
BpTreeMapTest >> nameOf: anObject [

	^ anObject isNumber
		  ifTrue: [ anObject printString ]
		  ifFalse: [ anObject first ]
]

{ #category : 'tests' }
BpTreeMapTest >> newMap [

	^ (BpTreeMap amounts: #( 6 3 1 ) labels: #( 'six' 'three' 'one' ))
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpTreeMapTest >> newTree [
	"Answer a map of the tree a(b(1 2) 3)."

	^ (BpTreeMap roots: #( #( 'a' #( 'b' 1 2 ) 3 ) ) children: [ :each | self childrenOf: each ] weight: [ :each | each ])
		  labelBlock: [ :each | self nameOf: each ];
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpTreeMapTest >> testAmountOfANodeIsTheSumOfItsLeaves [

	| map |
	map := self newTree.
	self assert: (self boxLabeled: 'a' in: map) amount equals: 6.
	self assert: (self boxLabeled: 'b' in: map) amount equals: 3
]

{ #category : 'tests' }
BpTreeMapTest >> testAmountZeroHasNoBox [

	self assert: (BpTreeMap amounts: #( 6 0 1 )) boxes size equals: 2
]

{ #category : 'tests' }
BpTreeMapTest >> testAmountsAreTheLabelsByDefault [

	self assert: ((BpTreeMap amounts: #( 6 3 )) boxes collect: [ :each | each label text asString ] as: Array) equals: #( '6' '3' )
]

{ #category : 'tests' }
BpTreeMapTest >> testAreasAreProportionalToTheAmounts [

	| map |
	map := self newMap.
	map asForm.
	map boxes do: [ :each | self assert: each extent x * each extent y closeTo: 400 * 300 * each amount / 10 precision: 1 ]
]

{ #category : 'tests' }
BpTreeMapTest >> testBoxIsPaintedAtItsPlace [

	| map form |
	map := self newMap.
	form := map asForm.
	map boxes do: [ :each |
		self assert: (self is: (form colorAt: (each placement origin + 6) rounded) within: 3 of: each background paint color) ]
]

{ #category : 'tests' }
BpTreeMapTest >> testBoxesFollowTheSizeOfTheMap [

	| map |
	map := self newMap.
	map asForm.
	map extent: 200 @ 100.
	map asForm.
	self assert: (Rectangle merging: (map boxes collect: [ :each | each placement ])) extent equals: 200 @ 100
]

{ #category : 'tests' }
BpTreeMapTest >> testBoxesWithoutRoomAreHidden [

	| map |
	map := self newTree.
	map cellPadding: 200.
	map asForm.
	self assert: map boxes first isVisible.
	self assert: (map boxes allButFirst noneSatisfy: [ :each | each isVisible ])
]

{ #category : 'tests' }
BpTreeMapTest >> testChildrenAreBelowTheLabelOfTheirParent [

	| map parent |
	map := self newTree.
	map asForm.
	parent := self boxLabeled: 'a' in: map.
	self assert: (self boxLabeled: 'b' in: map) placement top >= (parent placement top + parent label measuredExtent y)
]

{ #category : 'tests' }
BpTreeMapTest >> testChildrenAreInsideTheirParent [

	| map parent |
	map := self newTree.
	map asForm.
	parent := (self boxLabeled: 'b' in: map) placement.
	self assert: (parent containsRect: (self boxLabeled: '1' in: map) placement).
	self assert: (parent containsRect: (self boxLabeled: '2' in: map) placement)
]

{ #category : 'tests' }
BpTreeMapTest >> testChildrenUseThePlaceOfAHiddenLabel [

	| map |
	map := self newTree.
	map
		showLabels: false;
		cellPadding: 5.
	map asForm.
	self assert: map boxes second placement top equals: 5
]

{ #category : 'tests' }
BpTreeMapTest >> testColorBarOfAMapColoredByNumbers [

	| map |
	map := self newTree.
	map colorBy: [ :each | each ].
	self assert: (BpColorBar on: map) ticks last location equals: 3
]

{ #category : 'tests - errors' }
BpTreeMapTest >> testColorBarOfAMapWithoutNumbersRaisesError [

	self
		should: [ BpColorBar on: self newMap ]
		raise: Error
		whoseDescriptionIncludes: 'shows no numbers by colors'
		description: 'the colors are the ones of the palette'
]

{ #category : 'tests' }
BpTreeMapTest >> testColorBlockGivesTheColors [

	| map |
	map := self newMap.
	map colorBlock: [ :each | BpQualitativePalette set1 colorAt: each value ].
	self assert: map boxes last background paint color equals: (BpQualitativePalette set1 colorAt: 1)
]

{ #category : 'tests' }
BpTreeMapTest >> testColorByMapsNumbersToColors [

	| map |
	map := self newTree.
	map
		colorMap: [ :fraction | Color gray: fraction ];
		colorBy: [ :each | each ].
	self assert: (map leaves collect: [ :each | each background paint color ] as: Array) equals: {
		(Color gray: 0).
		(Color gray: 1 / 2).
		(Color gray: 1) }
]

{ #category : 'tests' }
BpTreeMapTest >> testDepth [

	self assert: (self newTree boxes collect: [ :each | each depth ] as: Array) equals: #( 0 1 2 2 1 )
]

{ #category : 'tests' }
BpTreeMapTest >> testEdgeColorAndLineWidth [

	| map border |
	map := self newMap.
	map
		edgeColor: (BpQualitativePalette set1 colorAt: 1);
		lineWidth: 3.
	border := map boxes first border.
	self assert: border paint color equals: (BpQualitativePalette set1 colorAt: 1).
	self assert: border width equals: 3 * BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpTreeMapTest >> testInnerBoxesAreLighterThanTheirLeaves [

	| map |
	map := self newTree.
	self assert: (self boxLabeled: 'b' in: map) background paint color luminance > (BpPalette default colorAt: 1) luminance
]

{ #category : 'tests' }
BpTreeMapTest >> testLabelContrastsWithItsBox [

	| map attribute |
	map := self newMap.
	map colorBlock: [ :each | Color black ].
	attribute := (map boxes first label text attributesAt: 1) detect: [ :each | each isKindOf: BlTextForegroundAttribute ].
	self assert: attribute paint equals: Color white
]

{ #category : 'tests' }
BpTreeMapTest >> testLabelLargerThanItsBoxIsHidden [

	| map |
	map := BpTreeMap amounts: #( 100 1 ) labels: #( 'large' 'a label much too long' ).
	map extent: 200 @ 200.
	map asForm.
	self assert: map boxes first label isVisible.
	self deny: map boxes second label isVisible
]

{ #category : 'tests' }
BpTreeMapTest >> testLabelsOfTheAmounts [

	self assert: (self newMap boxes collect: [ :each | each label text asString ] as: Array) equals: #( 'six' 'three' 'one' )
]

{ #category : 'tests' }
BpTreeMapTest >> testLeavesAreTheBoxesWithoutChildren [

	self assert: (self newTree leaves collect: [ :each | each object ] as: Array) equals: #( 1 2 3 )
]

{ #category : 'tests' }
BpTreeMapTest >> testLeavesOfABranchHaveItsColor [

	| map |
	map := self newTree.
	self assert: (map leaves collect: [ :each | each background paint color ] as: Array) equals: {
		(BpPalette default colorAt: 1).
		(BpPalette default colorAt: 1).
		(BpPalette default colorAt: 2) }
]

{ #category : 'tests - errors' }
BpTreeMapTest >> testNegativeAmountRaisesError [

	self
		should: [ BpTreeMap amounts: #( 2 -1 ) ]
		raise: Error
		whoseDescriptionIncludes: 'cannot be negative'
		description: 'an area cannot be negative'
]

{ #category : 'tests' }
BpTreeMapTest >> testOneBoxPerAmount [

	self assert: (self newMap boxes collect: [ :each | each amount ] as: Array) equals: #( 6 3 1 )
]

{ #category : 'tests' }
BpTreeMapTest >> testPaddingIsAroundTheChildren [

	| map parent child |
	map := self newTree.
	map cellPadding: 10.
	map asForm.
	parent := (self boxLabeled: 'a' in: map) placement.
	child := (self boxLabeled: 'b' in: map) placement.
	self assert: child left - parent left equals: 10.
	self assert: parent bottom - child bottom equals: 10
]

{ #category : 'tests' }
BpTreeMapTest >> testPaletteReplacesTheDefaultOne [

	| map |
	map := self newMap.
	map palette: BpQualitativePalette set1.
	self assert: map boxes first background paint color equals: (BpQualitativePalette set1 colorAt: 1)
]

{ #category : 'tests' }
BpTreeMapTest >> testParentsComeBeforeTheirChildren [

	self assert: (self newTree boxes collect: [ :each | each label text asString ] as: Array) equals: #( 'a' 'b' '1' '2' '3' )
]

{ #category : 'tests' }
BpTreeMapTest >> testRootsTakeTheColorsOfThePalette [

	self assert: (self newMap boxes collect: [ :each | each background paint color ] as: Array) equals: {
		(BpPalette default colorAt: 1).
		(BpPalette default colorAt: 2).
		(BpPalette default colorAt: 3) }
]

{ #category : 'tests' }
BpTreeMapTest >> testShowLabelsFalseHidesTheLabels [

	| map |
	map := self newTree.
	map showLabels: false.
	map asForm.
	self assert: (map boxes noneSatisfy: [ :each | each label isVisible ])
]

{ #category : 'tests' }
BpTreeMapTest >> testVMinAndVMax [

	| map |
	map := self newTree.
	map
		colorMap: [ :fraction | Color gray: fraction ];
		colorBy: [ :each | each ];
		vMin: 0;
		vMax: 4.
	self assert: map leaves second background paint color equals: (Color gray: 1 / 2)
]

{ #category : 'tests' }
BpTreeMapTest >> testWhenBoxDoReceivesTheClickedLeaf [

	| map clicked |
	clicked := OrderedCollection new.
	map := self newTree.
	map whenBox: BlClickEvent do: [ :event :box | clicked add: box object ].
	map inNewHeadlessSpaceDo: [ :space |
		space settle.
		map eventSimulator clickAt: (self boxLabeled: '2' in: map) placement center ].
	self assert: clicked asArray equals: #( 2 )
]

{ #category : 'tests' }
BpTreeMapTest >> testWhenBoxDoSurvivesARebuild [

	| map clicked |
	clicked := nil.
	map := self newMap.
	map whenBox: BlClickEvent do: [ :event :box | clicked := box label text asString ].
	map cellPadding: 4.
	map inNewHeadlessSpaceDo: [ :space |
		space settle.
		map eventSimulator clickAt: map boxes first placement center ].
	self assert: clicked equals: 'six'
]

{ #category : 'tests - errors' }
BpTreeMapTest >> testWrongNumberOfLabelsRaisesError [

	self
		should: [ BpTreeMap amounts: #( 2 1 ) labels: #( 'a' ) ]
		raise: Error
		whoseDescriptionIncludes: 'One label per amount'
		description: 'there are two amounts'
]
