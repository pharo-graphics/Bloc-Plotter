"
I test `BpSquarifier`: the areas, order and places of its rectangles.
"
Class {
	#name : 'BpSquarifierTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpSquarifierTest >> rectanglesOf: someAmounts [

	^ BpSquarifier rectanglesFor: someAmounts in: (0 @ 0 corner: 6 @ 4)
]

{ #category : 'tests' }
BpSquarifierTest >> testAreasAreProportionalToTheAmounts [

	| amounts |
	amounts := #( 6 6 4 3 2 2 1 ).
	(self rectanglesOf: amounts)
		with: amounts
		do: [ :each :amount | self assert: each width * each height closeTo: amount precision: 1.0e-9 ]
]

{ #category : 'tests' }
BpSquarifierTest >> testLargestAmountsShareTheFirstColumn [
	"The example of Bruls, Huizing and van Wijk, Squarified Treemaps: 6 and 6 make a column 3 wide."

	| rectangles |
	rectangles := self rectanglesOf: #( 6 6 4 3 2 2 1 ).
	self assert: rectangles first equals: (0 @ 0 corner: 3 @ 2).
	self assert: rectangles second equals: (0 @ 2 corner: 3 @ 4)
]

{ #category : 'tests' }
BpSquarifierTest >> testNextAmountsShareARowOfTheRest [

	| rectangles |
	rectangles := self rectanglesOf: #( 6 6 4 3 2 2 1 ).
	self assert: rectangles third origin equals: 3 @ 0.
	self assert: rectangles third height closeTo: 7 / 3 precision: 1.0e-9.
	self assert: rectangles fourth top equals: 0.
	self assert: rectangles fourth height closeTo: 7 / 3 precision: 1.0e-9
]

{ #category : 'tests' }
BpSquarifierTest >> testNoAmountHasNoRectangle [

	self assert: (self rectanglesOf: #(  )) isEmpty
]

{ #category : 'tests' }
BpSquarifierTest >> testOneAmountFillsTheRectangle [

	self assert: (self rectanglesOf: #( 5 )) first equals: (0 @ 0 corner: 6 @ 4)
]

{ #category : 'tests' }
BpSquarifierTest >> testRectanglesAreInTheOrderOfTheAmounts [

	| rectangles |
	rectangles := self rectanglesOf: #( 1 6 2 3 2 4 6 ).
	#( 1 6 2 3 2 4 6 )
		with: rectangles
		do: [ :amount :each | self assert: each width * each height closeTo: amount precision: 1.0e-9 ]
]

{ #category : 'tests' }
BpSquarifierTest >> testRectanglesAreInside [

	self assert:
		((self rectanglesOf: #( 1 6 2 3 2 4 6 )) allSatisfy: [ :each | (0 @ 0 - 1.0e-9 corner: 6 @ 4 + 1.0e-9) containsRect: each ])
]

{ #category : 'tests' }
BpSquarifierTest >> testRectanglesDoNotOverlap [

	| rectangles |
	rectangles := (self rectanglesOf: #( 1 6 2 3 2 4 6 )) collect: [ :each | each insetBy: 1.0e-6 ].
	rectangles combinations: 2 atATimeDo: [ :pair | self deny: (pair first intersects: pair second) ]
]
