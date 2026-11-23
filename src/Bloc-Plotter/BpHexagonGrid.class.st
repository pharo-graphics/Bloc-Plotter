"
I am a grid of hexagons covering a rectangle. I answer the hexagon a point falls in (`indexOf:`), and the center and the corners of each hexagon.

## Examples

```
BpHexagonGrid instanceFourByTwo
```

## Design Rationale

- The region is cut in columns and rows of cells. The centers of the hexagons make two lattices: the corners of the cells, then their middles. A point is in the hexagon of the closest center of both lattices, the distance being the one that makes the hexagons regular when a cell is as high as the square root of 3 times its width; otherwise they are stretched as the cells are.
- Hexagons are numbered from 1, column by column, the first lattice before the second one, so that a collection holds one thing per hexagon. The index 0 means out of the grid.

## Usage

1. `BpHexbin>>newGrid` creates me each time its points must be counted.
2. I do not change once created.

## Invariants and Assumptions

- The centers on the sides of the region are exactly on them at the first side, and up to the rounding of its width at the last one.
"
Class {
	#name : 'BpHexagonGrid',
	#superclass : 'Object',
	#instVars : [
		'region',
		'columns',
		'rows'
	],
	#category : 'Bloc-Plotter-Hexbin',
	#package : 'Bloc-Plotter',
	#tag : 'Hexbin'
}

{ #category : 'instances' }
BpHexagonGrid class >> instanceFourByTwo [

	<sampleInstance>
	^ self region: (0 @ 0 corner: 4 @ 2) columns: 4 rows: 2
]

{ #category : 'instance creation' }
BpHexagonGrid class >> region: aRectangle columns: anInteger rows: anotherInteger [

	^ self new
		  setRegion: aRectangle columns: anInteger rows: anotherInteger;
		  yourself
]

{ #category : 'accessing' }
BpHexagonGrid >> cellExtent [
	"Answer the size of a cell, which is the distance between neighboring centers of a lattice."

	^ region width / columns @ (region height / rows)
]

{ #category : 'hexagons' }
BpHexagonGrid >> centerAt: anIndex [
	"Answer the center of the hexagon at anIndex. The fractions of the region are exact, so the centers on its sides are too."

	| position |
	position := self positionAt: anIndex.
	^ region left + (region width * (position x / columns)) @ (region top + (region height * (position y / rows)))
]

{ #category : 'accessing' }
BpHexagonGrid >> columns [

	^ columns
]

{ #category : 'hexagons' }
BpHexagonGrid >> cornersAt: anIndex [
	"Answer the six corners of the hexagon at anIndex."

	| center width height |
	center := self centerAt: anIndex.
	width := self cellExtent x / 2.
	height := self cellExtent y / 6.
	^ {
		  (center + (width @ height negated)).
		  (center + (width @ height)).
		  (center + (0 @ (height * 2))).
		  (center + (width negated @ height)).
		  (center + (width negated @ height negated)).
		  (center - (0 @ (height * 2))) }
]

{ #category : 'private' }
BpHexagonGrid >> distanceFrom: aPosition to: anotherPosition [
	"Answer a number growing with the distance between two positions in cells: the height of a cell counts for the square root of 3 widths, as in a regular hexagon."

	| delta |
	delta := aPosition - anotherPosition.
	^ delta x squared + (3 * delta y squared)
]

{ #category : 'private' }
BpHexagonGrid >> firstLatticeSize [

	^ columns + 1 * (rows + 1)
]

{ #category : 'private' }
BpHexagonGrid >> indexInFirstLatticeOf: aPosition [

	^ ((aPosition x between: 0 and: columns) and: [ aPosition y between: 0 and: rows ])
		  ifTrue: [ aPosition x * (rows + 1) + aPosition y + 1 ]
		  ifFalse: [ 0 ]
]

{ #category : 'private' }
BpHexagonGrid >> indexInSecondLatticeOf: aPosition [

	^ ((aPosition x between: 0 and: columns - 1) and: [ aPosition y between: 0 and: rows - 1 ])
		  ifTrue: [ self firstLatticeSize + (aPosition x * rows) + aPosition y + 1 ]
		  ifFalse: [ 0 ]
]

{ #category : 'hexagons' }
BpHexagonGrid >> indexOf: aPoint [
	"Answer the index of the hexagon aPoint falls in, or 0 when it is out of all of them."

	| position rounded floor |
	position := aPoint - region origin / self cellExtent.
	rounded := position rounded.
	floor := position floor.
	^ (self distanceFrom: position to: rounded) < (self distanceFrom: position to: floor + 0.5)
		  ifTrue: [ self indexInFirstLatticeOf: rounded ]
		  ifFalse: [ self indexInSecondLatticeOf: floor ]
]

{ #category : 'accessing' }
BpHexagonGrid >> lastIndexOfRegion [
	"Answer the index of the hexagon whose center is the corner of my region."

	^ self firstLatticeSize
]

{ #category : 'private' }
BpHexagonGrid >> positionAt: anIndex [
	"Answer the center of the hexagon at anIndex, counted in cells."

	| index |
	index := anIndex - 1.
	index < self firstLatticeSize ifTrue: [ ^ index // (rows + 1) @ (index \\ (rows + 1)) ].
	index := index - self firstLatticeSize.
	^ index // rows @ (index \\ rows) + (1 / 2)
]

{ #category : 'accessing' }
BpHexagonGrid >> region [

	^ region
]

{ #category : 'accessing' }
BpHexagonGrid >> rows [

	^ rows
]

{ #category : 'initialization' }
BpHexagonGrid >> setRegion: aRectangle columns: anInteger rows: anotherInteger [

	region := aRectangle.
	columns := anInteger.
	rows := anotherInteger
]

{ #category : 'accessing' }
BpHexagonGrid >> size [
	"Answer the number of hexagons."

	^ self firstLatticeSize + (columns * rows)
]
