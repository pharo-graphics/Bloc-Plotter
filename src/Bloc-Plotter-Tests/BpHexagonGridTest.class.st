"
I test `BpHexagonGrid`: the centers and the corners of its hexagons, and the hexagon a point falls in.
"
Class {
	#name : 'BpHexagonGridTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpHexagonGridTest >> newGrid [
	"Answer a grid of four columns and two rows, in cells of 1 by 1."

	^ BpHexagonGrid region: (0 @ 0 corner: 4 @ 2) columns: 4 rows: 2
]

{ #category : 'tests' }
BpHexagonGridTest >> testCentersOfTheFirstLatticeAreOnTheCornersOfTheCells [

	| grid |
	grid := self newGrid.
	self assert: (grid centerAt: 1) equals: 0 @ 0.
	self assert: (grid centerAt: 2) equals: 0 @ 1.
	self assert: (grid centerAt: 4) equals: 1 @ 0.
	self assert: (grid centerAt: 15) equals: 4 @ 2
]

{ #category : 'tests' }
BpHexagonGridTest >> testCentersOfTheSecondLatticeAreInTheMiddleOfTheCells [

	| grid |
	grid := self newGrid.
	self assert: (grid centerAt: 16) equals: 1 / 2 @ (1 / 2).
	self assert: (grid centerAt: 23) equals: 7 / 2 @ (3 / 2)
]

{ #category : 'tests' }
BpHexagonGridTest >> testCornersAreAroundTheCenter [

	| corners |
	corners := self newGrid cornersAt: 16.
	self assert: (corners collect: [ :each | each x ]) max equals: 1.
	self assert: (corners collect: [ :each | each y ]) max equals: 5 / 6
]

{ #category : 'tests' }
BpHexagonGridTest >> testEachCenterIsInItsHexagon [

	| grid |
	grid := self newGrid.
	self
		assert: ((1 to: grid size) collect: [ :each | grid indexOf: (grid centerAt: each) ]) asArray
		equals: (1 to: grid size) asArray
]

{ #category : 'tests' }
BpHexagonGridTest >> testHexagonsCoverTheRegionWithoutOverlap [
	"The area of a hexagon is half of the one of a cell, which holds a hexagon of each lattice in total."

	| corners area |
	corners := self newGrid cornersAt: 16.
	self assert: corners size equals: 6.
	area := 0.
	corners withIndexDo: [ :each :index | area := area + (each crossProduct: (corners atWrap: index + 1)) ].
	self assert: (area / 2) abs equals: 1 / 2
]

{ #category : 'tests' }
BpHexagonGridTest >> testNeighborsShareAnEdge [

	| grid shared |
	grid := self newGrid.
	shared := (grid cornersAt: (grid indexOf: 1 @ 1)) asSet intersection: (grid cornersAt: 16) asSet.
	self assert: shared size equals: 2
]

{ #category : 'tests' }
BpHexagonGridTest >> testPointsAboveTheRegionAreInNoHexagon [

	self assert: (self newGrid indexOf: 1 @ 5) equals: 0
]

{ #category : 'tests' }
BpHexagonGridTest >> testPointsBesideTheRegionAreInNoHexagon [

	self assert: (self newGrid indexOf: -2 @ 1) equals: 0
]

{ #category : 'tests' }
BpHexagonGridTest >> testPointsFallInTheHexagonWithTheClosestCenter [

	| grid |
	grid := self newGrid.
	self assert: (grid centerAt: (grid indexOf: 1.1 @ 1.1)) equals: 1 @ 1.
	self assert: (grid centerAt: (grid indexOf: 1.45 @ 0.6)) equals: 3 / 2 @ (1 / 2)
]

{ #category : 'tests' }
BpHexagonGridTest >> testSizeCountsBothLattices [

	self assert: self newGrid size equals: 5 * 3 + (4 * 2)
]
