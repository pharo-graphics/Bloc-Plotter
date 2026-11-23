"
I share a rectangle between numbers: I answer a rectangle per number, whose areas are proportional to the numbers and which are as square as possible, so that they can be compared.

## Examples

```
BpSquarifier instanceSevenAmounts
```

## Design Rationale

- I implement the squarified layout of Bruls, Huizing and van Wijk (Squarified Treemaps, 2000). From the largest number to the smallest one, an area joins the current line as long as this does not elongate its most elongated area.
- I know nothing of trees and elements: `BpTreeMap` uses me once per level.

## Usage

`BpTreeMap>>place:in:` sends `rectanglesFor:in:` to my class. The instance it creates is used once.

## Invariants and Assumptions

- The numbers are positive, and the rectangle is not empty: `BpTreeMap` leaves the other ones out.
"
Class {
	#name : 'BpSquarifier',
	#superclass : 'Object',
	#instVars : [
		'areas',
		'remaining',
		'rectangles'
	],
	#category : 'Bloc-Plotter-TreeMap',
	#package : 'Bloc-Plotter',
	#tag : 'TreeMap'
}

{ #category : 'instances' }
BpSquarifier class >> instanceSevenAmounts [
	"Answer a squarifier that shared a rectangle between seven amounts."

	<sampleInstance>
	^ self new
		  setAmounts: #( 6 6 4 3 2 2 1 ) rectangle: (0 @ 0 corner: 6 @ 4);
		  squarify;
		  yourself
]

{ #category : 'squarifying' }
BpSquarifier class >> rectanglesFor: aCollectionOfNumbers in: aRectangle [
	"Answer a rectangle per number of aCollectionOfNumbers (positive, in any order), in the same order: they cover aRectangle, their areas are proportional to the numbers, and they are as square as possible."

	aCollectionOfNumbers ifEmpty: [ ^ #(  ) ].
	^ self new
		  setAmounts: aCollectionOfNumbers rectangle: aRectangle;
		  squarify;
		  rectangles
]

{ #category : 'private' }
BpSquarifier >> areaOf: aCollectionOfIndexes [

	^ aCollectionOfIndexes inject: 0 into: [ :sum :each | sum + (areas at: each) ]
]

{ #category : 'private' }
BpSquarifier >> layoutColumn: aCollectionOfIndexes [

	| width top |
	width := (self areaOf: aCollectionOfIndexes) / remaining height.
	top := remaining top.
	aCollectionOfIndexes do: [ :each |
		| height |
		height := (areas at: each) / width.
		rectangles at: each put: (remaining left @ top extent: width @ height).
		top := top + height ].
	remaining := remaining left + width @ remaining top corner: remaining corner
]

{ #category : 'private' }
BpSquarifier >> layoutLine: aCollectionOfIndexes [
	"Put the areas on a line: a column at the left of the remaining rectangle when it is wide, a row at its top when it is high."

	remaining width >= remaining height
		ifTrue: [ self layoutColumn: aCollectionOfIndexes ]
		ifFalse: [ self layoutRow: aCollectionOfIndexes ]
]

{ #category : 'private' }
BpSquarifier >> layoutRow: aCollectionOfIndexes [

	| height left |
	height := (self areaOf: aCollectionOfIndexes) / remaining width.
	left := remaining left.
	aCollectionOfIndexes do: [ :each |
		| width |
		width := (areas at: each) / height.
		rectangles at: each put: (left @ remaining top extent: width @ height).
		left := left + width ].
	remaining := remaining left @ (remaining top + height) corner: remaining corner
]

{ #category : 'accessing' }
BpSquarifier >> rectangles [
	"Answer the rectangles, in the order of the amounts."

	^ rectangles
]

{ #category : 'initialization' }
BpSquarifier >> setAmounts: aCollectionOfNumbers rectangle: aRectangle [

	| scale |
	scale := aRectangle width * aRectangle height / aCollectionOfNumbers sum.
	areas := aCollectionOfNumbers collect: [ :each | (each * scale) asFloat ] as: Array.
	remaining := aRectangle.
	rectangles := Array new: areas size
]

{ #category : 'private' }
BpSquarifier >> sortedIndexes [

	^ (1 to: areas size) asArray sort: [ :a :b | (areas at: a) >= (areas at: b) ]
]

{ #category : 'squarifying' }
BpSquarifier >> squarify [
	"Lay out the areas from the largest to the smallest, in lines along the shortest side of the remaining rectangle: an area joins the current line as long as the areas of the line do not get more elongated."

	| line |
	line := OrderedCollection new.
	self sortedIndexes do: [ :each |
		(line isEmpty or: [ (self worstRatioOf: line , { each }) <= (self worstRatioOf: line) ]) ifFalse: [
			self layoutLine: line.
			line := OrderedCollection new ].
		line add: each ].
	self layoutLine: line
]

{ #category : 'private' }
BpSquarifier >> worstRatioOf: aCollectionOfIndexes [
	"Answer the ratio of the long side to the short side of the most elongated area, when aCollectionOfIndexes make a line along the shortest side of the remaining rectangle. The indexes go from the largest area to the smallest one."

	| side total |
	side := remaining width min: remaining height.
	total := self areaOf: aCollectionOfIndexes.
	^ side squared * (areas at: aCollectionOfIndexes first) / total squared max:
		  total squared / (side squared * (areas at: aCollectionOfIndexes last))
]
