"
I am a heatmap, added by `BpChart>>heatmap:`: I show the numbers of a matrix by the colors of cells (`BpHeatmapCell`). `rowNames:` and `columnNames:` name the rows and columns, and `showAmounts:` writes the numbers in the cells.

## Examples

```
BpHeatmap exampleAnnotated.
BpHeatmap exampleOptions.
BpHeatmap exampleInteraction
```

## Design Rationale

- The cell of a row and a column is centered on its numbers, counted from 1: other artists can be added over it with these coordinates.
- My first row is at the top, as a matrix is written: I ask my chart to turn its y axis around (`BpArtist>>invertedAxes`).
- Without names, only some rows and columns are numbered, about ten, so that the numbers of a large matrix do not overlap.
- A nil in the matrix is a missing number: it has no cell.
- The edge of a cell has its color, unless `edgeColors:` is given, so that no seam shows between two cells. With an `alpha:`, the edges of neighbors overlap and show.

## Usage

1. `BpChart>>heatmap:` creates me with `matrix:` and adds me to the chart (see `BpArtist`).
2. `BpChart>>addColorBarFor:` tells my numbers with a `BpColorBar`.
3. My patches answer their `row`, `column` and `amount`, which interaction handlers given to `whenPatch:do:` use, with `rowNameAt:` and `columnNameAt:`.

## Implementation Notes

- Not supported yet: rotated names (long column names overlap) and square cells.

## Invariants and Assumptions

- The matrix has at least one cell, its rows have the same size, and there are as many names as rows or columns: an error is raised otherwise.
"
Class {
	#name : 'BpHeatmap',
	#superclass : 'BpArtist',
	#instVars : [
		'rows',
		'rowNames',
		'columnNames',
		'showAmounts',
		'amountFormatter',
		'colorScale',
		'edgeColors',
		'lineWidths'
	],
	#category : 'Bloc-Plotter-Heatmap',
	#package : 'Bloc-Plotter',
	#tag : 'Heatmap'
}

{ #category : 'private - demo' }
BpHeatmap class >> divergingMap [
	"Answer a color map from red to blue through white."

	^ BpInterpolatedPalette name: 'RdBu' anchors: (BpDivergingPalette rdbu: 11) colors
]

{ #category : 'examples' }
BpHeatmap class >> exampleAnnotated [
	"Show the figure of the gallery annotated heatmap: the numbers are written in the cells and the rows and columns are named."

	<example>
	^ BpFigure instanceHeatmap show: 'Annotated heatmap'
]

{ #category : 'examples' }
BpHeatmap class >> exampleInteraction [
	"Interaction handlers on the cells: hover a cell to outline it, click it to see its vegetable, farmer and number."

	<example>
	^ BpFigure instanceInteractiveHeatmap show: 'Heatmap interaction'
]

{ #category : 'examples' }
BpHeatmap class >> exampleOptions [
	"Show heatmaps with edges, a diverging color map, missing numbers, and a log scale with many cells."

	<example>
	^ BpFigure instanceHeatmapOptions show: 'Heatmap options'
]

{ #category : 'private - demo' }
BpHeatmap class >> harvestIn: aChart [
	"Add to aChart the heatmap of the gallery annotated heatmap, and answer it."

	^ (aChart heatmap: #( #( 0.8 2.4 2.5 3.9 0.0 4.0 0.0 ) #( 2.4 0.0 4.0 1.0 2.7 0.0 0.0 ) #( 1.1 2.4 0.8 4.3 1.9 4.4 0.0 )
		      #( 0.6 0.0 0.3 0.0 3.1 0.0 0.0 ) #( 0.7 1.7 0.6 2.6 2.2 6.2 0.0 ) #( 1.3 1.2 0.0 0.0 0.0 3.2 5.1 )
		      #( 0.1 2.0 0.0 1.4 0.0 1.9 6.3 ) ))
		  rowNames: #( 'cucumber' 'tomato' 'lettuce' 'asparagus' 'potato' 'wheat' 'barley' );
		  columnNames: #( 'Farmer Joe' 'Upland Bros.' 'Smith G.' 'Agrifun' 'Organiculture' 'BioGoods' 'Cornylee' );
		  yourself
]

{ #category : 'instances' }
BpHeatmap class >> instanceHarvest [
	"Answer a heatmap of seven vegetables and seven farmers."

	<sampleInstance>
	^ self harvestIn: (BpChart new
		   extent: 640 @ 480;
		   yourself)
]

{ #category : 'instance creation' }
BpHeatmap class >> matrix: aCollectionOfRows [
	"Answer a heatmap of aCollectionOfRows, the rows of a matrix: collections of numbers of the same size, nil for a missing one."

	^ self new
		  setMatrix: aCollectionOfRows;
		  yourself
]

{ #category : 'private - demo' }
BpHeatmap class >> wavesIn: aChart [
	"Add to aChart a heatmap of 40 rows and 60 columns, whose positive numbers go through three orders of magnitude, and answer it."

	^ aChart heatmap:
		  ((1 to: 40) collect: [ :row | (1 to: 60) collect: [ :column | 10 raisedTo: (row / 8) sin + (column / 10) cos * 0.75 ] ])
]

{ #category : 'accessing' }
BpHeatmap >> amountAtRow: aRow column: aColumn [
	"Answer the number of a cell, nil when it is missing."

	^ (rows at: aRow) at: aColumn
]

{ #category : 'accessing - options' }
BpHeatmap >> amountFormatter: aBlockOrNil [
	"Set a block answering the string written in a cell from its number; nil prints the numbers with the decimals they all need, two at most."

	amountFormatter := aBlockOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpHeatmap >> amounts [
	"Answer the numbers I show, without the missing ones."

	^ rows flatCollect: [ :row | row select: [ :each | each isNotNil ] ]
]

{ #category : 'private - computing' }
BpHeatmap >> cellFormatter [
	"Answer the block answering the string written in a cell from its number."

	| decimals |
	amountFormatter ifNotNil: [ ^ amountFormatter ].
	decimals := (BpTickLocator decimalsFor: self amounts) min: 2.
	^ [ :amount |
		  decimals isZero
			  ifTrue: [ amount rounded printString ]
			  ifFalse: [ amount printShowingDecimalPlaces: decimals ] ]
]

{ #category : 'axes' }
BpHeatmap >> colorCount [
	"My colors come from my color map."

	^ 0
]

{ #category : 'accessing - options' }
BpHeatmap >> colorMap: aPaletteOrBlock [
	"Set what maps the numbers to colors: a `BpInterpolatedPalette`, or a block from a fraction between 0 and 1 to a color."

	colorScale colorMap: aPaletteOrBlock.
	self refresh
]

{ #category : 'axes' }
BpHeatmap >> colorScale [
	"Answer what maps my numbers to colors."

	^ colorScale
]

{ #category : 'accessing' }
BpHeatmap >> columnCount [

	^ rows ifEmpty: [ 0 ] ifNotEmpty: [ rows first size ]
]

{ #category : 'accessing' }
BpHeatmap >> columnNameAt: anInteger [
	"Answer the name of a column, or its number without names."

	^ columnNames ifNil: [ anInteger printString ] ifNotNil: [ columnNames at: anInteger ]
]

{ #category : 'accessing - options' }
BpHeatmap >> columnNames: aCollectionOfStringsOrNil [
	"Set the names of the columns, shown along the x axis; nil shows their numbers."

	(aCollectionOfStringsOrNil isNil or: [ aCollectionOfStringsOrNil size = self columnCount ]) ifFalse: [
		^ self error: 'One name per column is needed' ].
	columnNames := aCollectionOfStringsOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpHeatmap >> compute [

	colorScale fitTo: self amounts
]

{ #category : 'axes' }
BpHeatmap >> countOn: anAxis [

	^ anAxis = #x
		  ifTrue: [ self columnCount ]
		  ifFalse: [ self rowCount ]
]

{ #category : 'accessing - options' }
BpHeatmap >> edgeColors: aColorOrNil [
	"Set the edge color of the cells. Without it (nil) the edge has the color of the cell; `Color transparent` draws no edge."

	edgeColors := aColorOrNil.
	self refresh
]

{ #category : 'initialization' }
BpHeatmap >> initialize [

	super initialize.
	rows := #(  ).
	showAmounts := false.
	colorScale := BpColorScale new.
	lineWidths := 1
]

{ #category : 'axes' }
BpHeatmap >> invertedAxes [
	"My first row is at the top, as a matrix is written."

	^ #( #y )
]

{ #category : 'accessing - options' }
BpHeatmap >> lineWidths: aNumber [
	"Set the width of the edges in points (1 by default)."

	lineWidths := aNumber.
	self refresh
]

{ #category : 'axes' }
BpHeatmap >> managedTicksOn: anAxis [
	"Answer the ticks of my columns or rows: their names, or the numbers of some of them."

	self rowCount isZero ifTrue: [ ^ nil ].
	^ (self namesOn: anAxis)
		  ifNil: [ (self tickIndexesOn: anAxis) collect: [ :each | each -> each printString ] ]
		  ifNotNil: [ :names | names asArray withIndexCollect: [ :each :index | index -> each asString ] ]
]

{ #category : 'axes' }
BpHeatmap >> namesOn: anAxis [

	^ anAxis = #x
		  ifTrue: [ columnNames ]
		  ifFalse: [ rowNames ]
]

{ #category : 'private - computing' }
BpHeatmap >> newCellAtRow: aRow column: aColumn formatter: aBlock [

	| cell amount |
	amount := self amountAtRow: aRow column: aColumn.
	cell := BpHeatmapCell new
		        artist: self;
		        dataset: 1;
		        row: aRow;
		        column: aColumn;
		        amount: amount;
		        dataBounds: (aColumn @ aRow - (1 / 2) extent: 1 @ 1);
		        yourself.
	self paint: cell with: (colorScale colorFor: amount).
	showAmounts ifTrue: [ cell showCenteredLabel: (aBlock value: amount) ].
	patchHandlers do: [ :each | self addHandler: each to: cell ].
	^ cell
]

{ #category : 'private - computing' }
BpHeatmap >> newPatches [
	"Answer one cell per number, row by row."

	| formatter cells |
	formatter := self cellFormatter.
	cells := OrderedCollection new.
	rows withIndexDo: [ :numbers :row |
		numbers withIndexDo: [ :amount :column |
			amount ifNotNil: [ cells add: (self newCellAtRow: row column: column formatter: formatter) ] ] ].
	^ cells asArray
]

{ #category : 'private - computing' }
BpHeatmap >> paint: aCell with: aColor [
	"Fill aCell with aColor, and draw its edge in the color of the edges, or in aColor so that no seam shows between two cells."

	aCell
		background: (self colorOf: aColor);
		border: (BlBorder paint: (self colorOf: (edgeColors ifNil: [ aColor ])) width: lineWidths * self class pixelsPerPoint)
]

{ #category : 'accessing' }
BpHeatmap >> rowCount [

	^ rows size
]

{ #category : 'accessing' }
BpHeatmap >> rowNameAt: anInteger [
	"Answer the name of a row, or its number without names."

	^ rowNames ifNil: [ anInteger printString ] ifNotNil: [ rowNames at: anInteger ]
]

{ #category : 'accessing - options' }
BpHeatmap >> rowNames: aCollectionOfStringsOrNil [
	"Set the names of the rows, shown along the y axis; nil shows their numbers."

	(aCollectionOfStringsOrNil isNil or: [ aCollectionOfStringsOrNil size = self rowCount ]) ifFalse: [
		^ self error: 'One name per row is needed' ].
	rowNames := aCollectionOfStringsOrNil.
	self refresh
]

{ #category : 'accessing - options' }
BpHeatmap >> scale: aSymbol [
	"Set the scale along which the numbers are mapped to colors: #linear (the default) or #log."

	colorScale scale: aSymbol.
	self refresh
]

{ #category : 'initialization' }
BpHeatmap >> setMatrix: aCollectionOfRows [

	(aCollectionOfRows isEmpty or: [ aCollectionOfRows first isEmpty ]) ifTrue: [ ^ self error: 'A heatmap needs at least one cell' ].
	(aCollectionOfRows allSatisfy: [ :each | each size = aCollectionOfRows first size ]) ifFalse: [
		^ self error: 'The rows must have the same size' ].
	rows := aCollectionOfRows collect: [ :each | each asArray ] as: Array.
	self refresh
]

{ #category : 'accessing - options' }
BpHeatmap >> showAmounts: aBoolean [
	"Write or not the number of each cell in it (false by default). A cell too small for its number does not show it."

	showAmounts := aBoolean.
	self refresh
]

{ #category : 'axes' }
BpHeatmap >> showsNumbersByColors [

	^ true
]

{ #category : 'axes' }
BpHeatmap >> stickyValuesOn: anAxis [
	"Answer the sides of my first and last cells: I fill the plot area."

	^ {
		  (1 / 2).
		  ((self countOn: anAxis) + (1 / 2)) }
]

{ #category : 'axes' }
BpHeatmap >> tickIndexesOn: anAxis [
	"Answer at most about ten columns or rows, far enough from each other to be labeled."

	| count |
	count := self countOn: anAxis.
	count = 1 ifTrue: [ ^ #( 1 ) ].
	^ (BpTickLocator linearTicksFrom: 1 to: count count: 10) select: [ :each | each isInteger ]
]

{ #category : 'accessing - options' }
BpHeatmap >> vMax: aNumberOrNil [
	"Set the number mapped to the end of the color map (the largest one by default)."

	colorScale vMax: aNumberOrNil.
	self refresh
]

{ #category : 'accessing - options' }
BpHeatmap >> vMin: aNumberOrNil [
	"Set the number mapped to the start of the color map (the smallest one by default)."

	colorScale vMin: aNumberOrNil.
	self refresh
]
