"
I am a figure: a grid of `BpAxes`, the Bloc counterpart of the matplotlib figure answered by `plt.subplots(nrows, ncols)`. Plots are added to the axes answered by `axesAtRow:column:`, and `show:` opens me, like `plt.show()`; `savefig:` saves me as SVG, PDF or PNG, like `fig.savefig()`.

## Examples

```
BpFigure exampleTwoByTwo.
BpFigure scriptTwoByTwo.
BpFigure scriptHisttypes.
BpFigure scriptMultihist.
BpFigure scriptOptions.
BpFigure scriptInteraction.
BpFigure scriptScatter.
BpFigure scriptSavefig
```

More figures of the matplotlib gallery are shown by the scripts of `BpHistogram`.

## Design Rationale

- Rows and columns are counted from 1, as Pharo collections: `axesAtRow: 1 column: 1` is matplotlib `axs[0, 0]`.
- My default extent is the matplotlib one, 640 by 480, so that the figures of the matplotlib gallery keep their proportions. `figureExtent` answers the size asked with `extent:` (matplotlib figsize): `show:` sizes its space with it, since `extent` is only known once I am laid out.

- `savefig:` chooses the format from the extension of the file. SVG and PDF are vector graphics; `savefig:dpi:` sets the resolution of a PNG, 100 dots per inch giving my extent in pixels as matplotlib.

## Usage

1. `rows:columns:` (also on the class side) creates my axes, row by row, in a `BlGridLayout`.
2. Plots are added to my axes (`axesAtRow:column:`, `axes`), for example with `BpAxes>>hist:`.
3. `show:` opens me in a space of my extent.

- I am mutable: plots can be added before or after I am shown, and `rows:columns:` replaces all my axes with what they show.

## Implementation Notes

- Saving uses the exporters of Bloc (`BAExporter`): they draw me on an Alexandrie canvas over a Cairo SVG, PDF or image surface, so what is saved is exactly what is shown. The SVG draws texts as glyph paths; the PDF keeps them as text.
"
Class {
	#name : 'BpFigure',
	#superclass : 'BlElement',
	#instVars : [
		'rows',
		'columns',
		'axes'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'examples' }
BpFigure class >> exampleTwoByTwo [
	"Answer a figure of two rows of two axes, each with a title, ready to receive plots."

	<sampleInstance>
	| figure |
	figure := self rows: 2 columns: 2.
	figure axes withIndexDo: [ :axes :index | axes title: 'axes ' , index printString ].
	^ figure
]

{ #category : 'instance creation' }
BpFigure class >> rows: aRowCount columns: aColumnCount [
	"Answer a figure with a grid of axes, as matplotlib plt.subplots(nrows, ncols)."

	^ self new
		  rows: aRowCount columns: aColumnCount;
		  yourself
]

{ #category : 'script' }
BpFigure class >> scriptHisttypes [
	"Show a figure of four axes, each with a different kind of histogram (the matplotlib gallery histogram_histtypes)."

	<example>
	^ BpHistogram exampleHisttypes show: 'histogram_histtypes'
]

{ #category : 'script' }
BpFigure class >> scriptInteraction [
	"Show a figure of one axes whose histogram reacts to the mouse: hover a bar to highlight it, click it to see its bin and count."

	<example>
	^ BpHistogram exampleInteractiveHistogram show: 'Histogram interaction'
]

{ #category : 'script' }
BpFigure class >> scriptMultihist [
	"Show a figure of four axes with several datasets per histogram (the matplotlib gallery histogram_multihist)."

	<example>
	^ BpHistogram exampleMultihist show: 'histogram_multihist'
]

{ #category : 'script' }
BpFigure class >> scriptOptions [
	"Show a figure of two rows of three axes, larger than the default one (extent: 900 @ 520), each with a histogram option."

	<example>
	^ BpHistogram exampleOptions show: 'hist options'
]

{ #category : 'script' }
BpFigure class >> scriptSavefig [
	"Save the histtypes figure of the matplotlib gallery as SVG and PDF (vector graphics) and as PNG at 200 dots per inch, in the image directory, and inspect the files."

	<example>
	| figure directory files |
	figure := BpHistogram exampleHisttypes.
	directory := FileLocator imageDirectory asFileReference.
	files := { 'histogram_histtypes.svg'. 'histogram_histtypes.pdf' } collect: [ :each | figure savefig: directory / each ].
	files := files , { (figure savefig: directory / 'histogram_histtypes.png' dpi: 200) }.
	^ files inspect
]

{ #category : 'script' }
BpFigure class >> scriptScatter [
	"Show a figure of one axes with a scatter of random points of random sizes and colors (the matplotlib gallery scatter)."

	<example>
	^ BpScatter exampleScatter show: 'scatter'
]

{ #category : 'script' }
BpFigure class >> scriptTwoByTwo [
	"Show an empty figure of two rows of two axes, as matplotlib plt.subplots(2, 2) followed by plt.show()."

	<example>
	^ self exampleTwoByTwo show: 'Figure 2 x 2'
]

{ #category : 'accessing' }
BpFigure >> axes [
	"Answer my axes, row by row."

	^ axes
]

{ #category : 'accessing' }
BpFigure >> axesAtRow: aRowIndex column: aColumnIndex [
	"Answer the axes in a row and a column, both counted from 1 (matplotlib axs[row - 1, column - 1])."

	^ axes at: aRowIndex - 1 * columns + aColumnIndex
]

{ #category : 'accessing' }
BpFigure >> columns [

	^ columns
]

{ #category : 'saving' }
BpFigure >> exporterFor: anExtension [
	"Answer the Bloc exporter writing files of anExtension; it draws me on an Alexandrie canvas of the format."

	anExtension = 'svg' ifTrue: [ ^ BAExporter svg ].
	anExtension = 'pdf' ifTrue: [ ^ BAExporter pdf ].
	anExtension = 'png' ifTrue: [ ^ BAExporter png ].
	^ self error: ('Unsupported format: {1} (use svg, pdf or png)' format: { anExtension printString })
]

{ #category : 'accessing' }
BpFigure >> figureExtent [
	"Answer the size asked for me with extent: (matplotlib figsize). Unlike extent, it is known before I am laid out."

	^ self constraints horizontal resizer size @ self constraints vertical resizer size
]

{ #category : 'initialization' }
BpFigure >> initialize [

	super initialize.
	self
		background: Color white;
		padding: (BlInsets all: 6);
		extent: 640 @ 480.
	self rows: 1 columns: 1
]

{ #category : 'accessing' }
BpFigure >> rows [

	^ rows
]

{ #category : 'accessing' }
BpFigure >> rows: aRowCount columns: aColumnCount [
	"Replace my axes by a grid of aRowCount by aColumnCount new axes."

	rows := aRowCount.
	columns := aColumnCount.
	self removeChildren.
	self layout: (BlGridLayout horizontal
		 columnCount: aColumnCount;
		 cellSpacing: 4;
		 yourself).
	axes := (1 to: aRowCount * aColumnCount) collect: [ :each | BpAxes new ].
	self addChildren: axes
]

{ #category : 'saving' }
BpFigure >> savefig: aFileReference [
	"Save me in aFileReference, as matplotlib savefig: SVG or PDF (vector graphics) or PNG, chosen by its extension. Answer the file."

	^ self savefig: aFileReference dpi: 100
]

{ #category : 'saving' }
BpFigure >> savefig: aFileReference dpi: aNumber [
	"Save me in aFileReference, chosen by its extension; a PNG has aNumber dots per inch, 100 giving my extent in pixels as matplotlib. Answer the file."

	| file extension exporter |
	file := aFileReference asFileReference.
	extension := file extension asLowercase.
	exporter := self exporterFor: extension.
	extension = 'png' ifTrue: [ exporter scale: aNumber / 100 ].
	^ exporter
		  element: self;
		  target: file;
		  export
]

{ #category : 'opening' }
BpFigure >> show: aTitle [
	"Open a space of my figure extent showing me, as matplotlib plt.show(). Answer the space."

	| space |
	space := BlSpace new.
	space
		title: aTitle;
		extent: self figureExtent.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ].
	space root addChild: self.
	space show; 	settle.
	^ space
]
