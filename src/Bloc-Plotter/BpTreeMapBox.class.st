"
I am a box of a `BpTreeMap`: my area shows the `amount` of my `object`, and I hold the boxes of the objects in it (`innerBoxes`).

## Examples

```
BpTreeMapBox instanceOfAmounts
```

## Usage

1. `BpTreeMap>>newBoxOn:depth:` creates me, and `BpTreeMap>>rebuild` numbers my `branch`, then paints and labels me (`TBpLabeled`).
2. At each layout, `BpTreeMap>>place:in:` sends me `placeIn:of:`: I take my place and give my inner boxes what remains below my label.

- I show one computation of my tree map: I am replaced when it changes.

## Implementation Notes

- My inner boxes are not my Bloc children: all the boxes are children of the tree map, the inner ones after the one that holds them, hence above it.
"
Class {
	#name : 'BpTreeMapBox',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection + TBpLabeled',
	#classTraits : 'TBpLiveInspection classTrait + TBpLabeled classTrait',
	#instVars : [
		'object',
		'amount',
		'depth',
		'branch',
		'innerBoxes',
		'placement'
	],
	#category : 'Bloc-Plotter-TreeMap',
	#package : 'Bloc-Plotter',
	#tag : 'TreeMap'
}

{ #category : 'instances' }
BpTreeMapBox class >> instanceOfAmounts [
	"Answer the first box of a tree map."

	<sampleInstance>
	^ BpTreeMap instanceAmounts boxes first
]

{ #category : 'accessing' }
BpTreeMapBox >> amount [
	"Answer the number my area shows: the weight of my object, or the sum of my inner boxes."

	^ amount
]

{ #category : 'accessing' }
BpTreeMapBox >> amount: aNumber [

	amount := aNumber
]

{ #category : 'accessing' }
BpTreeMapBox >> branch [
	"Answer the number of the branch of the tree I belong to, which gives my color; 0 for a single root, which holds all the branches."

	^ branch
]

{ #category : 'accessing' }
BpTreeMapBox >> branch: anInteger [
	"Put me and my inner boxes in a branch."

	self withInnerBoxes do: [ :each | each setBranch: anInteger ]
]

{ #category : 'accessing' }
BpTreeMapBox >> depth [
	"Answer in how many boxes I am."

	^ depth
]

{ #category : 'accessing' }
BpTreeMapBox >> depth: anInteger [

	depth := anInteger
]

{ #category : 'layout' }
BpTreeMapBox >> hasRoomForLabelPaddedBy: aNumber [
	"Answer whether my label fits in me and, when I have inner boxes, leaves them half of my height."

	^ self isLeaf
		  ifTrue: [ self labelExtent <= placement extent ]
		  ifFalse: [ self labelExtent x + (aNumber * 2) <= placement width and: [ self labelExtent y * 2 <= placement height ] ]
]

{ #category : 'initialization' }
BpTreeMapBox >> initialize [

	super initialize.
	innerBoxes := #(  ).
	depth := 0.
	branch := 0.
	placement := 0 @ 0 corner: 0 @ 0
]

{ #category : 'accessing' }
BpTreeMapBox >> innerBoxes [

	^ innerBoxes
]

{ #category : 'accessing' }
BpTreeMapBox >> innerBoxes: aCollectionOfBoxes [

	innerBoxes := aCollectionOfBoxes
]

{ #category : 'layout' }
BpTreeMapBox >> innerRectanglePaddedBy: aNumber [
	"Answer the rectangle of my inner boxes, below my label when it is shown. It is empty when the padding takes all my room."

	| top width height |
	top := label isVisible
		       ifTrue: [ label measuredExtent y max: aNumber ]
		       ifFalse: [ aNumber ].
	width := placement width - (aNumber * 2).
	height := placement height - top - aNumber.
	^ (width > 0 and: [ height > 0 ])
		  ifTrue: [ placement origin + (aNumber @ top) extent: width @ height ]
		  ifFalse: [ placement center extent: 0 @ 0 ]
]

{ #category : 'testing' }
BpTreeMapBox >> isLeaf [

	^ innerBoxes isEmpty
]

{ #category : 'accessing' }
BpTreeMapBox >> object [
	"Answer the object I show."

	^ object
]

{ #category : 'accessing' }
BpTreeMapBox >> object: anObject [

	object := anObject
]

{ #category : 'layout' }
BpTreeMapBox >> placeIn: aRectangle of: aTreeMap [
	"Take aRectangle, show my label when it fits in it, and give my inner boxes what remains. A box without room is hidden."

	placement := aRectangle.
	self visibility: (aRectangle hasPositiveExtent
		 ifTrue: [ BlVisibility visible ]
		 ifFalse: [ BlVisibility hidden ]).
	self labelVisible: (aTreeMap showsLabels and: [ self hasRoomForLabelPaddedBy: aTreeMap cellPadding ]).
	aTreeMap place: innerBoxes in: (self innerRectanglePaddedBy: aTreeMap cellPadding)
]

{ #category : 'accessing' }
BpTreeMapBox >> placement [
	"Answer my rectangle in my tree map, as computed by the last layout."

	^ placement
]

{ #category : 'accessing' }
BpTreeMapBox >> setBranch: anInteger [

	branch := anInteger
]

{ #category : 'accessing' }
BpTreeMapBox >> withInnerBoxes [
	"Answer me, then all the boxes in me."

	^ { self } , (innerBoxes flatCollect: [ :each | each withInnerBoxes ])
]
