"
I test `BpMarker`: the shapes of the matplotlib marker symbols, tuples, paths and texts in the unit cell, and their drawing.
"
Class {
	#name : 'BpMarkerTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpMarkerTest >> assert: aPoint isCloseTo: anotherPoint [

	self assert: (aPoint x closeTo: anotherPoint x precision: 1e-6).
	self assert: (aPoint y closeTo: anotherPoint y precision: 1e-6)
]

{ #category : 'tests' }
BpMarkerTest >> testAsteriskTupleIsNotFilled [

	self deny: (BpMarker on: #( 5 2 0 )) isFilled
]

{ #category : 'tests' }
BpMarkerTest >> testCircleFitsTheUnitCell [

	self assert: (BpMarker on: 'o') bounds equals: (-0.5 @ -0.5 corner: 0.5 @ 0.5)
]

{ #category : 'tests' }
BpMarkerTest >> testCircleIsDrawnAsACircle [

	self assert: (BpMarker on: 'o') isCircle
]

{ #category : 'tests' }
BpMarkerTest >> testDiamondIsASquareTurnedByFortyFiveDegrees [

	self assert: ((BpMarker on: 'D') vertices collect: [ :each | each r ]) max closeTo: 0.5 sqrt precision: 1e-6
]

{ #category : 'tests' }
BpMarkerTest >> testFilledPlusIsFilled [

	self assert: (BpMarker on: 'P') isFilled
]

{ #category : 'tests' }
BpMarkerTest >> testPathMarkerFitsTheUnitCell [

	| bounds |
	bounds := (BpMarker on: '$\clubsuit$') bounds.
	self assert: bounds left >= -0.5.
	self assert: bounds right <= 0.5.
	self assert: bounds top >= -0.5.
	self assert: bounds bottom <= 0.5
]

{ #category : 'tests' }
BpMarkerTest >> testPathMarkerIsDrawnWithAnSvgPathInPixels [
	"The center of the club is filled; the form keeps the default extent of a BlSvgPath, so the center is computed from the marker."

	| marker element form |
	marker := BpMarker on: '$\clubsuit$'.
	element := BlElement new
		           geometry: (marker geometryWithSide: 40);
		           extent: (marker extentWithSide: 40);
		           background: Color black;
		           yourself.
	form := element asForm.
	self assert: (marker geometryWithSide: 40) class equals: BlSvgPath.
	self assert: (form colorAt: (marker extentWithSide: 40) // 2) equals: Color black
]

{ #category : 'tests' }
BpMarkerTest >> testPlusIsNotFilled [

	self deny: (BpMarker on: '+') isFilled
]

{ #category : 'tests' }
BpMarkerTest >> testPointIsAHalfCircle [

	self assert: (BpMarker on: '.') bounds equals: (-0.25 @ -0.25 corner: 0.25 @ 0.25)
]

{ #category : 'tests' }
BpMarkerTest >> testPolygonTupleHasOneVertexPerSideStartingAtTheTop [

	| vertices |
	vertices := (BpMarker on: #( 5 0 0 )) vertices.
	self assert: vertices size equals: 5.
	self assert: vertices first isCloseTo: 0 @ 0.5
]

{ #category : 'tests' }
BpMarkerTest >> testPolygonTupleIsRotatedByItsAngleInDegrees [

	self assert: (BpMarker on: #( 4 0 90 )) vertices first isCloseTo: -0.5 @ 0
]

{ #category : 'tests' }
BpMarkerTest >> testSquareFitsTheUnitCell [

	self assert: (BpMarker on: 's') bounds equals: (-0.5 @ -0.5 corner: 0.5 @ 0.5)
]

{ #category : 'tests' }
BpMarkerTest >> testStarSymbolHasTheInnerCircleOfMatplotlib [

	self assert: ((BpMarker on: '*') vertices second r closeTo: 0.381966 / 2 precision: 1e-6)
]

{ #category : 'tests' }
BpMarkerTest >> testStarTupleAlternatesOuterAndInnerVertices [

	| vertices |
	vertices := (BpMarker on: #( 5 1 0 )) vertices.
	self assert: vertices size equals: 10.
	self assert: (vertices first r closeTo: 0.5 precision: 1e-6).
	self assert: (vertices second r closeTo: 0.25 precision: 1e-6)
]

{ #category : 'tests' }
BpMarkerTest >> testTexCardSuitsAreDrawnAsPaths [

	#( '$\clubsuit$' '$\spadesuit$' '$\heartsuit$' '$\diamondsuit$' ) do: [ :each |
		| marker |
		marker := BpMarker on: each.
		self deny: marker isText.
		self assert: marker isFilled ]
]

{ #category : 'tests' }
BpMarkerTest >> testTextMarkerShowsTheTextBetweenDollars [

	| marker |
	marker := BpMarker on: '$f$'.
	self assert: marker isText.
	self assert: marker text equals: 'f'
]

{ #category : 'tests' }
BpMarkerTest >> testTriangleRightHasItsTipAtTheRight [

	self assert: (BpMarker on: '>') vertices first isCloseTo: 0.5 @ 0
]

{ #category : 'tests' }
BpMarkerTest >> testTriangleUpHasItsTipAtTheTop [

	| vertices |
	vertices := (BpMarker on: '^') vertices.
	self assert: vertices size equals: 3.
	self assert: vertices first isCloseTo: 0 @ 0.5
]

{ #category : 'tests - errors' }
BpMarkerTest >> testUnknownMarkerRaisesError [

	self should: [ BpMarker on: 'unknown' ] raise: Error
]

{ #category : 'tests' }
BpMarkerTest >> testVerticesAreScaledIntoTheUnitCell [

	| marker |
	marker := BpMarker on: {
		          (-2 @ -2).
		          (2 @ -2).
		          (2 @ 2) }.
	self assert: marker bounds equals: (-0.5 @ -0.5 corner: 0.5 @ 0.5)
]
