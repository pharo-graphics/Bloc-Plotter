"
I test `BpHeatmap` and its cells: their places, colors and labels, the ticks of the rows and columns, and the interaction.
"
Class {
	#name : 'BpHeatmapTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpHeatmapTest >> cellOf: aHeatmap row: aRow column: aColumn [

	^ aHeatmap patches detect: [ :each | each row = aRow and: [ each column = aColumn ] ]
]

{ #category : 'tests' }
BpHeatmapTest >> is: aColor within: anInteger of: anotherColor [
	"Answer whether the levels of both colors, between 0 and 255, differ by anInteger at most."

	^ (#( #red #green #blue ) collect: [ :each | ((aColor perform: each) - (anotherColor perform: each)) abs * 255 ]) max
	  < (anInteger + 0.5)
]

{ #category : 'tests' }
BpHeatmapTest >> labelsOn: anAxis of: aHeatmap [

	^ (aHeatmap chart ticks select: [ :each | each axis = anAxis ]) collect: [ :each | each label text asString ] as: Array
]

{ #category : 'tests' }
BpHeatmapTest >> newChart [

	^ BpChart new
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'tests' }
BpHeatmapTest >> newHeatmap [
	"Answer a heatmap of two rows and three columns."

	^ self newChart heatmap: #( #( 1 2 3 ) #( 4 5 6 ) )
]

{ #category : 'tests' }
BpHeatmapTest >> testAlphaMakesTheCellsTransparent [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap alpha: 0.5.
	self assert: (heatmap patches first background paint color alpha closeTo: 0.5 precision: 0.01)
]

{ #category : 'tests' }
BpHeatmapTest >> testAmountFormatterGivesTheLabels [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap
		showAmounts: true;
		amountFormatter: [ :amount | '#' , amount printString ].
	self assert: (self cellOf: heatmap row: 1 column: 1) label text asString equals: '#1'
]

{ #category : 'tests' }
BpHeatmapTest >> testAmountsHaveTheDecimalsTheyNeedUpToTwo [

	| heatmap |
	heatmap := self newChart heatmap: #( #( 0.5 2 ) ).
	heatmap showAmounts: true.
	self assert: (heatmap patches collect: [ :each | each label text asString ] as: Array) equals: #( '0.5' '2.0' ).
	heatmap := self newChart heatmap: #( #( 0.12345 2 ) ).
	heatmap showAmounts: true.
	self assert: (heatmap patches collect: [ :each | each label text asString ] as: Array) equals: #( '0.12' '2.00' )
]

{ #category : 'tests' }
BpHeatmapTest >> testCellIsCenteredOnItsColumnAndRow [

	self assert: (self cellOf: self newHeatmap row: 1 column: 2) dataBounds equals: (3 / 2 @ (1 / 2) corner: 5 / 2 @ (3 / 2))
]

{ #category : 'tests' }
BpHeatmapTest >> testCellIsPaintedAtItsColumnAndRow [

	| heatmap chart form colors at |
	colors := BpQualitativePalette set1.
	heatmap := self newHeatmap.
	heatmap colorMap: [ :fraction |
		colors colorAt: (fraction = 1
			 ifTrue: [ 1 ]
			 ifFalse: [ 2 ]) ].
	chart := heatmap chart.
	form := chart asForm.
	at := [ :point | form colorAt: (chart plotBounds origin + (chart dataTransform pointFor: point)) rounded ].
	self assert: (self is: (at value: 3 @ 2) within: 3 of: (colors colorAt: 1)).
	self assert: (self is: (at value: 3 @ 1) within: 3 of: (colors colorAt: 2)).
	self assert: (self is: (at value: 1 @ 2) within: 3 of: (colors colorAt: 2))
]

{ #category : 'tests' }
BpHeatmapTest >> testColorMapReplacesViridis [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap colorMap: BpInterpolatedPalette inferno.
	self assert: (self cellOf: heatmap row: 2 column: 3) background paint color equals: (BpInterpolatedPalette inferno colorAt: 1)
]

{ #category : 'tests' }
BpHeatmapTest >> testColorsGoFromTheSmallestToTheLargestNumber [

	| heatmap |
	heatmap := self newHeatmap.
	self assert: (self cellOf: heatmap row: 1 column: 1) background paint color equals: (BpInterpolatedPalette viridis colorAt: 0).
	self assert: (self cellOf: heatmap row: 2 column: 3) background paint color equals: (BpInterpolatedPalette viridis colorAt: 1)
]

{ #category : 'tests' }
BpHeatmapTest >> testColumnAndRowNamesAreTheTicks [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap
		columnNames: #( 'a' 'b' 'c' );
		rowNames: #( 'u' 'v' ).
	self assert: (self labelsOn: #x of: heatmap) equals: #( 'a' 'b' 'c' ).
	self assert: (self labelsOn: #y of: heatmap) equals: #( 'u' 'v' )
]

{ #category : 'tests' }
BpHeatmapTest >> testColumnNameAt [

	| heatmap |
	heatmap := self newHeatmap.
	self assert: (heatmap columnNameAt: 3) equals: '3'.
	heatmap columnNames: #( 'a' 'b' 'c' ).
	self assert: (heatmap columnNameAt: 3) equals: 'c'
]

{ #category : 'tests' }
BpHeatmapTest >> testEdgeColorsAndLineWidths [

	| heatmap border |
	heatmap := self newHeatmap.
	heatmap
		edgeColors: Color red;
		lineWidths: 3.
	border := heatmap patches first border.
	self assert: border paint color equals: Color red.
	self assert: border width equals: 3 * BpArtist pixelsPerPoint
]

{ #category : 'tests' }
BpHeatmapTest >> testEdgesHaveTheColorOfTheCell [

	self assert: self newHeatmap patches first border paint color equals: (BpInterpolatedPalette viridis colorAt: 0)
]

{ #category : 'tests - errors' }
BpHeatmapTest >> testEmptyMatrixRaisesError [

	self
		should: [ BpHeatmap matrix: #(  ) ]
		raise: Error
		whoseDescriptionIncludes: 'at least one'
		description: 'there is no cell'
]

{ #category : 'tests - errors' }
BpHeatmapTest >> testEmptyRowsRaiseError [

	self
		should: [ BpHeatmap matrix: #( #(  ) #(  ) ) ]
		raise: Error
		whoseDescriptionIncludes: 'at least one'
		description: 'there is no cell'
]

{ #category : 'tests' }
BpHeatmapTest >> testFirstRowIsAtTheTop [

	| chart |
	chart := self newHeatmap chart.
	self assert: chart yLimits equals: {
		(5 / 2).
		(1 / 2) }.
	self assert: (chart dataTransform pointFor: 1 @ 1) y < (chart dataTransform pointFor: 1 @ 2) y
]

{ #category : 'tests' }
BpHeatmapTest >> testLabelContrastsWithItsCell [

	| heatmap colorOf |
	colorOf := [ :cell | (cell label text attributesAt: 1) detect: [ :each | each isKindOf: BlTextForegroundAttribute ] ].
	heatmap := self newHeatmap.
	heatmap
		colorMap: [ :fraction | Color gray: fraction ];
		showAmounts: true.
	self assert: (colorOf value: (self cellOf: heatmap row: 1 column: 1)) paint equals: Color white.
	self assert: (colorOf value: (self cellOf: heatmap row: 2 column: 3)) paint equals: Color black
]

{ #category : 'tests' }
BpHeatmapTest >> testLabelHasTheHighestContrastWithItsCell [
	"Black stands out more than white on a light blue, whose luminance is under one half."

	| heatmap attribute |
	heatmap := self newHeatmap.
	heatmap
		colorMap: [ :fraction | (BpSequentialPalette blues: 9) colorAt: 5 ];
		showAmounts: true.
	attribute := (heatmap patches first label text attributesAt: 1) detect: [ :each | each isKindOf: BlTextForegroundAttribute ].
	self assert: attribute paint equals: Color black
]

{ #category : 'tests' }
BpHeatmapTest >> testLabelIsCenteredInItsCell [

	| heatmap cell |
	heatmap := self newHeatmap.
	heatmap showAmounts: true.
	heatmap chart asForm.
	cell := heatmap patches first.
	self assert: (cell label bounds inParent center closeTo: cell measuredExtent / 2 precision: 1)
]

{ #category : 'tests' }
BpHeatmapTest >> testLabelLargerThanItsCellIsHidden [

	| heatmap |
	heatmap := self newChart heatmap: { (1 to: 100) }.
	heatmap showAmounts: true.
	heatmap chart asForm.
	self deny: heatmap patches first label isVisible
]

{ #category : 'tests' }
BpHeatmapTest >> testLabelSmallerThanItsCellIsShown [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap showAmounts: true.
	heatmap chart asForm.
	self assert: heatmap patches first label isVisible
]

{ #category : 'tests' }
BpHeatmapTest >> testLimitsAreTheSidesOfTheCells [

	self assert: self newHeatmap chart xLimits equals: {
		(1 / 2).
		(7 / 2) }
]

{ #category : 'tests' }
BpHeatmapTest >> testLogScaleColorsTheOrdersOfMagnitude [

	| heatmap |
	heatmap := self newChart heatmap: #( #( 1 10 100 ) ).
	heatmap
		colorMap: [ :fraction | Color gray: fraction ];
		scale: #log.
	self assert: (self cellOf: heatmap row: 1 column: 2) background paint color equals: (Color gray: 0.5)
]

{ #category : 'tests' }
BpHeatmapTest >> testManyColumnsHaveTicksApart [

	| heatmap |
	heatmap := self newChart heatmap: { (1 to: 60) }.
	self assert: (self labelsOn: #x of: heatmap) equals: #( '10' '20' '30' '40' '50' '60' )
]

{ #category : 'tests' }
BpHeatmapTest >> testMissingNumberHasNoCell [

	self assert: (self newChart heatmap: #( #( 1 nil ) #( 3 4 ) )) patches size equals: 3
]

{ #category : 'tests' }
BpHeatmapTest >> testNoLabelsInTheCellsByDefault [

	self assert: (self newHeatmap patches allSatisfy: [ :each | each label isNil ])
]

{ #category : 'tests' }
BpHeatmapTest >> testNoSeamBetweenCellsOfTheSameColor [

	| chart color form area heatmap |
	color := BpQualitativePalette set1 colorAt: 2.
	chart := self newChart.
	heatmap := chart heatmap: ((1 to: 9) collect: [ :row | 1 to: 13 ]).
	heatmap colorMap: [ :fraction | color ].
	form := chart asForm.
	area := (chart plotBounds insetBy: 3) rounded.
	self assert: ((area left to: area right) allSatisfy: [ :eachX |
		 (area top to: area bottom) allSatisfy: [ :eachY | self is: (form colorAt: eachX @ eachY) within: 3 of: color ] ])
]

{ #category : 'tests' }
BpHeatmapTest >> testOneCellPerNumber [

	| heatmap |
	heatmap := self newHeatmap.
	self assert: heatmap patches size equals: 6.
	self assert: (self cellOf: heatmap row: 2 column: 3) amount equals: 6
]

{ #category : 'tests' }
BpHeatmapTest >> testRowNameAt [

	| heatmap |
	heatmap := self newHeatmap.
	self assert: (heatmap rowNameAt: 2) equals: '2'.
	heatmap rowNames: #( 'u' 'v' ).
	self assert: (heatmap rowNameAt: 2) equals: 'v'
]

{ #category : 'tests - errors' }
BpHeatmapTest >> testRowsOfDifferentSizesRaiseError [

	self
		should: [ BpHeatmap matrix: #( #( 1 2 ) #( 3 ) ) ]
		raise: Error
		whoseDescriptionIncludes: 'same size'
		description: 'the rows have not the same size'
]

{ #category : 'tests' }
BpHeatmapTest >> testShowAmountsLabelsTheCells [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap showAmounts: true.
	self assert: (heatmap patches collect: [ :each | each label text asString ] as: Array) equals: #( '1' '2' '3' '4' '5' '6' )
]

{ #category : 'tests' }
BpHeatmapTest >> testTakesNoColorOfThePalette [

	| chart |
	chart := self newHeatmap chart.
	self assert: (chart nextColors: 1) first equals: (BpPalette default colorAt: 1)
]

{ #category : 'tests' }
BpHeatmapTest >> testTicksAreTheIndexesWithoutNames [

	| heatmap |
	heatmap := self newHeatmap.
	self assert: (self labelsOn: #x of: heatmap) equals: #( '1' '2' '3' ).
	self assert: (self labelsOn: #y of: heatmap) equals: #( '1' '2' )
]

{ #category : 'tests - errors' }
BpHeatmapTest >> testUnknownScaleRaisesError [

	| heatmap |
	heatmap := BpHeatmap matrix: #( #( 1 2 ) ).
	self
		should: [ heatmap scale: #cubic ]
		raise: Error
		whoseDescriptionIncludes: 'Unknown scale'
		description: 'the scale is unknown'
]

{ #category : 'tests' }
BpHeatmapTest >> testVMinAndVMaxReplaceTheEnds [

	| heatmap |
	heatmap := self newHeatmap.
	heatmap
		colorMap: [ :fraction | Color gray: fraction ];
		vMin: 0;
		vMax: 10.
	self assert: (self cellOf: heatmap row: 2 column: 2) background paint color equals: (Color gray: 0.5)
]

{ #category : 'tests' }
BpHeatmapTest >> testWhenPatchDoReceivesTheClickedCell [

	| heatmap chart clicked |
	clicked := nil.
	heatmap := self newHeatmap.
	heatmap
		showAmounts: true;
		whenPatch: BlClickEvent do: [ :event :cell | clicked := cell ].
	chart := heatmap chart.
	chart inNewHeadlessSpaceDo: [ :space |
		space settle.
		chart eventSimulator clickAt: chart plotBounds origin + (chart dataTransform pointFor: 2 @ 1) ].
	self assert: clicked row equals: 1.
	self assert: clicked column equals: 2
]

{ #category : 'tests - errors' }
BpHeatmapTest >> testWrongNumberOfColumnNamesRaisesError [

	| heatmap |
	heatmap := BpHeatmap matrix: #( #( 1 2 ) ).
	self
		should: [ heatmap columnNames: #( 'a' ) ]
		raise: Error
		whoseDescriptionIncludes: 'One name per column'
		description: 'there are two columns'
]

{ #category : 'tests - errors' }
BpHeatmapTest >> testWrongNumberOfRowNamesRaisesError [

	| heatmap |
	heatmap := BpHeatmap matrix: #( #( 1 2 ) ).
	self
		should: [ heatmap rowNames: #( 'a' 'b' ) ]
		raise: Error
		whoseDescriptionIncludes: 'One name per row'
		description: 'there is one row'
]
