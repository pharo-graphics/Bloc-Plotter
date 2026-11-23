"
I am a tree map: a Bloc element showing numbers by the areas of boxes (`BpTreeMapBox`), and the tree they belong to by boxes in boxes. `roots:children:weight:` creates me on a tree of objects, `amounts:` and `amounts:labels:` on numbers.

## Examples

```
BpTreeMap exampleAmounts.
BpTreeMap exampleClassesOfPackage.
BpTreeMap exampleColorBar.
BpTreeMap exampleInteraction
```

## Design Rationale

- I am an element of my own, as `BpPie`, and not an artist of a `BpChart`: I have no axes.
- The weight is asked to the objects that hold no other one; the amount of the others is the sum of what they hold. An object of amount 0 has no box.
- The leaves take the color of their branch, a root or what a single root holds, and the boxes around them a lighter one. `colorBlock:` gives a color per leaf instead, and `colorBy:` a number per leaf, mapped to a color by a `BpColorScale`: the boxes around them are then grey.
- A label that does not fit in its box is not shown. The boxes in a box are below its label.
- My boxes are all my own children, not nested: the box under the mouse receives its events alone.

## Usage

1. Each setter rebuilds my boxes (`rebuild`).
2. `whenBox:do:` keeps its handlers and gives them to the new boxes of each rebuild. The boxes answer their `object`, `amount` and `depth`.
3. When I am shown, `BpTreeMapLayout` asks me to place my boxes in my extent (`placeBoxesIn:`).
4. After `colorBy:`, `BpColorBar class>>on:` gives a color bar of my numbers. It must be sent `refresh` after I change.

- I am mutable: keep me, not my boxes, which are replaced at each change.

## Implementation Notes

- The space around the boxes in a box is named `cellPadding`: `padding` is the one of any Bloc element.
- I have one slot per option, hence many slots.
- Not supported yet: the own weight of an object that holds other ones, and zooming in a box.

## Invariants and Assumptions

- The weights are not negative: an error is raised otherwise. The objects make a tree: a cycle never ends.
"
Class {
	#name : 'BpTreeMap',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'objects',
		'childrenBlock',
		'weightBlock',
		'labelBlock',
		'colorBlock',
		'numberBlock',
		'showLabels',
		'palette',
		'colorScale',
		'edgeColor',
		'lineWidth',
		'boxHandlers',
		'rootBoxes',
		'boxes',
		'cellPadding'
	],
	#category : 'Bloc-Plotter-TreeMap',
	#package : 'Bloc-Plotter',
	#tag : 'TreeMap'
}

{ #category : 'instance creation' }
BpTreeMap class >> amounts: aCollectionOfNumbers [
	"Answer a tree map with one box per number."

	^ self roots: aCollectionOfNumbers children: [ :each | #(  ) ] weight: [ :each | each ]
]

{ #category : 'instance creation' }
BpTreeMap class >> amounts: aCollectionOfNumbers labels: aCollectionOfStrings [
	"Answer a tree map with one box per number, labeled by the string at the same index."

	aCollectionOfNumbers size = aCollectionOfStrings size ifFalse: [ ^ self error: 'One label per amount is needed' ].
	^ (self
		   roots: (aCollectionOfStrings asArray with: aCollectionOfNumbers asArray collect: [ :string :amount | string -> amount ])
		   children: [ :each | #(  ) ]
		   weight: [ :each | each value ])
		  labelBlock: [ :each | each key ];
		  yourself
]

{ #category : 'private - demo' }
BpTreeMap class >> demoChildrenOf: aPackageOrTagOrClass [

	aPackageOrTagOrClass isBehavior ifTrue: [ ^ #(  ) ].
	^ aPackageOrTagOrClass = self package
		  ifTrue: [ aPackageOrTagOrClass tags ]
		  ifFalse: [ aPackageOrTagOrClass classes ]
]

{ #category : 'private - demo' }
BpTreeMap class >> demoOpen: aCollectionOfElements title: aString extent: anExtent [
	"Open a space showing aCollectionOfElements side by side."

	| space |
	space := BlSpace new.
	space
		title: aString;
		extent: anExtent.
	space root
		background: ((BpSequentialPalette greys: 9) colorAt: 1);
		layout: (BlLinearLayout horizontal cellSpacing: 10);
		padding: (BlInsets all: 10);
		addChildren: aCollectionOfElements.
	space show.
	^ space
]

{ #category : 'examples' }
BpTreeMap class >> exampleAmounts [
	"Show seven labeled amounts, each one by the area of a box."

	<example>
	^ self demoOpen: { self instanceAmounts } title: 'Tree map' extent: 660 @ 500
]

{ #category : 'examples' }
BpTreeMap class >> exampleClassesOfPackage [
	"Show the classes of a package by number of lines of code, in the boxes and the colors of their tags."

	<example>
	^ self demoOpen: { self instanceClassesOfPackage } title: 'Classes by tag' extent: 920 @ 670
]

{ #category : 'examples' }
BpTreeMap class >> exampleColorBar [
	"Show the classes of a package: their areas are their lines of code, their colors their numbers of methods, told by a color bar."

	<example>
	| map bar |
	map := self instanceMethodsByColor.
	bar := BpColorBar on: map.
	bar
		label: 'methods';
		height: 650.
	^ self
		  demoOpen: {
			  map.
			  bar }
		  title: 'Lines of code and methods'
		  extent: 1000 @ 670
]

{ #category : 'examples' }
BpTreeMap class >> exampleInteraction [
	"Interaction handlers on the boxes: hover a class to outline it, click it to see its number of lines of code."

	<example>
	| greys map info container |
	greys := BpSequentialPalette greys: 9.
	info := BlTextElement new text: ('Click a class' asRopedText fontSize: 16).
	map := self instanceClassesOfPackage.
	map
		whenBox: BlMouseEnterEvent do: [ :event :box | box border: (BlBorder paint: (greys colorAt: 9) width: 2) ];
		whenBox: BlMouseLeaveEvent do: [ :event :box | box border: (BlBorder paint: (greys colorAt: 1) width: 0.7) ];
		whenBox: BlClickEvent do: [ :event :box |
			info text: (('{1}: {2} lines of code' format: {
				  box label text asString.
				  box amount }) asRopedText fontSize: 16) ].
	container := BlElement new
		             layout: (BlLinearLayout vertical cellSpacing: 8);
		             constraintsDo: [ :c |
			             c horizontal fitContent.
			             c vertical fitContent ];
		             addChildren: {
			             info.
			             map };
		             yourself.
	^ self demoOpen: { container } title: 'Tree map interaction' extent: 920 @ 710
]

{ #category : 'instances' }
BpTreeMap class >> instanceAmounts [
	"Answer a tree map of seven labeled amounts."

	<sampleInstance>
	^ self amounts: #( 6 6 4 3 2 2 1 ) labels: #( 'Bloc' 'Toplo' 'Spec' 'Roassal' 'Iceberg' 'Calypso' 'Ombu' )
]

{ #category : 'instances' }
BpTreeMap class >> instanceClassesOfPackage [
	"Answer a tree map of the classes of a package, in the colors of their tags."

	<sampleInstance>
	^ self ownPackage
		  extent: 900 @ 650;
		  yourself
]

{ #category : 'instances' }
BpTreeMap class >> instanceMethodsByColor [
	"Answer a tree map of the classes of a package: their areas are their lines of code, their colors their numbers of methods."

	<sampleInstance>
	^ self ownPackage
		  colorBy: [ :class | class methods size ];
		  extent: 900 @ 650;
		  yourself
]

{ #category : 'private - demo' }
BpTreeMap class >> ownPackage [
	"Answer a tree map of my package: its tags, then their classes by number of lines of code."

	^ (self roots: { self package } children: [ :each | self demoChildrenOf: each ] weight: [ :class | class linesOfCode ])
		  labelBlock: [ :each | each name ];
		  yourself
]

{ #category : 'instance creation' }
BpTreeMap class >> roots: aCollection children: aBlock weight: anotherBlock [
	"Answer a tree map of the objects aCollection and those in them: aBlock answers the objects in an object, and anotherBlock the weight of an object without any. Symbols can be given as blocks."

	^ self new
		  setRoots: aCollection children: aBlock weight: anotherBlock;
		  yourself
]

{ #category : 'interaction' }
BpTreeMap >> addHandler: anAssociation to: aBox [

	aBox addEventHandler: (BlEventHandler
		 on: anAssociation key
		 do: [ :event | anAssociation value cull: event cull: aBox ])
]

{ #category : 'accessing' }
BpTreeMap >> boxes [
	"Answer all my boxes, each one followed by the boxes in it."

	^ boxes
]

{ #category : 'accessing' }
BpTreeMap >> cellPadding [

	^ cellPadding
]

{ #category : 'accessing - options' }
BpTreeMap >> cellPadding: aNumber [
	"Set the space in pixels between a box and the boxes in it (3 by default)."

	cellPadding := aNumber.
	self rebuild
]

{ #category : 'accessing - options' }
BpTreeMap >> colorBlock: aBlockOrNil [
	"Set the block answering the color of an object that holds no other object; nil takes the colors of my palette."

	colorBlock := aBlockOrNil.
	self rebuild
]

{ #category : 'accessing - options' }
BpTreeMap >> colorBy: aBlockOrNil [
	"Set the block answering the number that gives its color, through my color map, to an object that holds no other object; nil takes the colors of my palette."

	numberBlock := aBlockOrNil.
	self rebuild
]

{ #category : 'accessing - options' }
BpTreeMap >> colorMap: aPaletteOrBlock [
	"Set what maps the numbers of colorBy: to colors: a `BpInterpolatedPalette` (viridis by default), or a block from a fraction between 0 and 1 to a color."

	colorScale colorMap: aPaletteOrBlock.
	self rebuild
]

{ #category : 'color bar' }
BpTreeMap >> colorOf: aColor [
	"Answer how aColor is shown: my boxes are opaque."

	^ aColor
]

{ #category : 'private - building' }
BpTreeMap >> colorOfBox: aBox [
	"Answer the color of aBox: for a leaf, the one of my blocks or of its branch; for the box of other boxes, a lighter one, or a grey when the colors are not the ones of the branches."

	aBox isLeaf ifTrue: [ ^ self colorOfLeaf: aBox ].
	^ (aBox branch isZero or: [ self hasBranchColors not ])
		  ifTrue: [ (BpSequentialPalette greys: 9) colorAt: (aBox depth + 2 min: 5) ]
		  ifFalse: [ (palette colorAt: aBox branch) mixed: 0.4 with: Color white ]
]

{ #category : 'private - building' }
BpTreeMap >> colorOfLeaf: aBox [

	colorBlock ifNotNil: [ ^ colorBlock value: aBox object ].
	numberBlock ifNotNil: [ ^ colorScale colorFor: (numberBlock value: aBox object) ].
	^ palette colorAt: aBox branch
]

{ #category : 'color bar' }
BpTreeMap >> colorScale [
	"Answer what maps the numbers of colorBy: to colors."

	^ colorScale
]

{ #category : 'accessing - options' }
BpTreeMap >> edgeColor: aColor [
	"Set the color of the edges of the boxes (white by default)."

	edgeColor := aColor.
	self rebuild
]

{ #category : 'private - building' }
BpTreeMap >> hasBranchColors [

	^ colorBlock isNil and: [ numberBlock isNil ]
]

{ #category : 'initialization' }
BpTreeMap >> initialize [

	super initialize.
	objects := #(  ).
	labelBlock := [ :each | each asString ].
	showLabels := true.
	cellPadding := 3.
	palette := BpPalette default.
	colorScale := BpColorScale new.
	edgeColor := Color white.
	lineWidth := 0.5.
	boxHandlers := OrderedCollection new.
	rootBoxes := #(  ).
	boxes := #(  ).
	self
		layout: BpTreeMapLayout new;
		extent: 640 @ 480
]

{ #category : 'accessing - options' }
BpTreeMap >> labelBlock: aBlock [
	"Set the block answering the label of an object (its asString by default)."

	labelBlock := aBlock.
	self rebuild
]

{ #category : 'private - building' }
BpTreeMap >> labelBox: aBox [
	"Write the label of aBox at its center, or at its top left above the boxes in it."

	| string |
	string := labelBlock value: aBox object.
	aBox isLeaf
		ifTrue: [ aBox showCenteredLabel: string ]
		ifFalse: [ aBox showLabel: string placedBy: [ :c | c margin: (BlInsets left: cellPadding) ] ]
]

{ #category : 'accessing' }
BpTreeMap >> leaves [
	"Answer the boxes that hold no other box."

	^ boxes select: [ :each | each isLeaf ]
]

{ #category : 'accessing - options' }
BpTreeMap >> lineWidth: aNumber [
	"Set the width of the edges in points (0.5 by default)."

	lineWidth := aNumber.
	self rebuild
]

{ #category : 'private - building' }
BpTreeMap >> newBoxOn: anObject depth: anInteger [

	| held inner |
	held := childrenBlock value: anObject.
	inner := self newBoxesOn: held depth: anInteger + 1.
	^ BpTreeMapBox new
		  object: anObject;
		  depth: anInteger;
		  innerBoxes: inner;
		  amount: (held ifEmpty: [ self weightOf: anObject ] ifNotEmpty: [ inner inject: 0 into: [ :sum :each | sum + each amount ] ]);
		  yourself
]

{ #category : 'private - building' }
BpTreeMap >> newBoxesOn: aCollection depth: anInteger [
	"Answer a box per object of aCollection, but for those whose amount is 0."

	^ (aCollection asArray collect: [ :each | self newBoxOn: each depth: anInteger ]) select: [ :each | each amount > 0 ]
]

{ #category : 'private - building' }
BpTreeMap >> numberBranches [
	"Number the branches of the tree: my root boxes, or the boxes in a single one."

	| branches |
	branches := (rootBoxes size = 1 and: [ rootBoxes first isLeaf not ])
		            ifTrue: [ rootBoxes first innerBoxes ]
		            ifFalse: [ rootBoxes ].
	branches withIndexDo: [ :each :index | each branch: index ]
]

{ #category : 'accessing - options' }
BpTreeMap >> palette: anEnumeratedPalette [
	"Take the colors of my branches from anEnumeratedPalette."

	palette := anEnumeratedPalette.
	self rebuild
]

{ #category : 'layout' }
BpTreeMap >> place: aCollectionOfBoxes in: aRectangle [
	"Share aRectangle between aCollectionOfBoxes and what they hold."

	| rectangles |
	rectangles := aRectangle hasPositiveExtent
		              ifTrue: [ BpSquarifier rectanglesFor: (aCollectionOfBoxes collect: [ :each | each amount ]) in: aRectangle ]
		              ifFalse: [ aCollectionOfBoxes collect: [ :each | aRectangle ] ].
	aCollectionOfBoxes with: rectangles do: [ :each :rectangle | each placeIn: rectangle of: self ]
]

{ #category : 'layout' }
BpTreeMap >> placeBoxesIn: anExtent [

	self place: rootBoxes in: (0 @ 0 extent: anExtent)
]

{ #category : 'private - building' }
BpTreeMap >> rebuild [
	"Recreate my boxes from my objects and settings."

	self removeChildren.
	rootBoxes := self newBoxesOn: objects depth: 0.
	self numberBranches.
	boxes := rootBoxes flatCollect: [ :each | each withInnerBoxes ].
	numberBlock ifNotNil: [ colorScale fitTo: (self leaves collect: [ :each | numberBlock value: each object ]) ].
	boxes do: [ :each | self style: each ].
	self addChildren: boxes
]

{ #category : 'initialization' }
BpTreeMap >> setRoots: aCollection children: aBlock weight: anotherBlock [

	objects := aCollection asArray.
	childrenBlock := aBlock.
	weightBlock := anotherBlock.
	self rebuild
]

{ #category : 'accessing - options' }
BpTreeMap >> showLabels: aBoolean [
	"Show or not the labels (true by default). A label that does not fit in its box is not shown."

	showLabels := aBoolean.
	self requestLayout
]

{ #category : 'accessing' }
BpTreeMap >> showsLabels [

	^ showLabels
]

{ #category : 'color bar' }
BpTreeMap >> showsNumbersByColors [
	"Answer whether colorBy: gives my colors: I can then have a color bar."

	^ numberBlock isNotNil
]

{ #category : 'private - building' }
BpTreeMap >> style: aBox [

	aBox
		background: (self colorOfBox: aBox);
		border: (BlBorder paint: edgeColor width: lineWidth * BpArtist pixelsPerPoint).
	self labelBox: aBox.
	boxHandlers do: [ :each | self addHandler: each to: aBox ]
]

{ #category : 'accessing - options' }
BpTreeMap >> vMax: aNumberOrNil [
	"Set the number mapped to the end of the color map (the largest one by default)."

	colorScale vMax: aNumberOrNil.
	self rebuild
]

{ #category : 'accessing - options' }
BpTreeMap >> vMin: aNumberOrNil [
	"Set the number mapped to the start of the color map (the smallest one by default)."

	colorScale vMin: aNumberOrNil.
	self rebuild
]

{ #category : 'private - building' }
BpTreeMap >> weightOf: anObject [

	| weight |
	weight := weightBlock value: anObject.
	weight < 0 ifTrue: [ ^ self error: ('The weight of {1} cannot be negative' format: { anObject }) ].
	^ weight
]

{ #category : 'interaction' }
BpTreeMap >> whenBox: anEventClass do: aBlock [
	"Evaluate aBlock with the event and the box each time one of my boxes receives an event of anEventClass. The handler is kept when my boxes are rebuilt."

	boxHandlers add: anEventClass -> aBlock.
	boxes do: [ :each | self addHandler: anEventClass -> aBlock to: each ]
]
