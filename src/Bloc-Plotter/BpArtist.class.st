"
I am an artist of a `BpChart`: something drawn from data, such as a histogram (`BpHistogram`), a scatter plot (`BpScatterPlot`), a line plot (`BpLine`), a box plot (`BpBoxPlot`), a bar plot (`BpBarPlot`), a stem plot (`BpStemPlot`), the area between two curves (`BpFillBetween`), a stack plot (`BpStackPlot`), a step curve (`BpStairs`), a violin plot (`BpViolinPlot`), points with error bars (`BpErrorBar`, a `BpLine`), a hexbin (`BpHexbin`), a heatmap (`BpHeatmap`), a density plot (`BpDensityPlot`) or a row of a Kiviat chart (`BpKiviatRow`). I compute what my data show and build patches (`BpPatch`) that my chart places in its plot area; `whenPatch:do:` adds an interaction handler to all my patches.

## Examples

```
BpArtist exampleArtistsInOneChart
```

## Design Rationale

- I only know what my chart needs: my patches (`allPatches`), my legend entries, the values autoscaling must cover besides my patches (`requiredValuesOn:`) and must not go past (`stickyValuesOn:`), the ticks I place myself (`managedTicksOn:`), the axes I put on a log scale (`logAxes`) or turn around (`invertedAxes`), how many colors of its palette I take (`colorCount`), whether my patches are drawn above the grid (`isAboveGrid`), and whether their colors show numbers (`showsNumbersByColors`), which a color bar can tell. The chart ignores the kind of plot.
- Each change recomputes everything (`refresh`): subclasses define `compute` and `newPatches`, and new patches replace the previous ones. Handlers given to `whenPatch:do:` are kept and given to each new patch.
- Style settings take one value or one per dataset or point (`setting:at:`).
- My Live inspector pane (`TBpLiveInspection`) shows the figure of my chart, or a new figure holding me when I have no chart yet.

## Usage

1. My class creates me (`BpHistogram class>>xValues:`, `BpScatterPlot class>>x:y:`, `BpLine class>>x:y:`, `BpStackPlot class>>x:ys:`, `BpHexbin class>>x:y:`…), or a plotting method does (`BpChart>>barXValues:heightValues:`, `BpChart>>barhYValues:widthValues:`, `BpKiviat>>addRow:`), and `BpChart>>addArtist:` gives me my chart and my colors of the palette (`defaultColors:`).
2. Each setter calls `refresh`, which tells the chart (`BpChart>>artistChanged:`); it rebuilds its limits, patches, legend and ticks.

- I am mutable: keep me, not my patches, which are replaced at each change.
"
Class {
	#name : 'BpArtist',
	#superclass : 'Object',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'patchHandlers',
		'patches',
		'defaultColors',
		'alpha',
		'label',
		'chart'
	],
	#category : 'Bloc-Plotter-Chart',
	#package : 'Bloc-Plotter',
	#tag : 'Chart'
}

{ #category : 'private - demo' }
BpArtist class >> arangeFrom: aNumber to: anotherNumber by: aStep [
	"Answer the numbers from aNumber by aStep, below anotherNumber (excluded), as numpy arange, to write gallery examples."

	^ (0 to: (anotherNumber - aNumber / aStep) ceiling - 1) collect: [ :index | aNumber + (index * aStep) ]
]

{ #category : 'constants' }
BpArtist class >> dashPatterns [
	"Answer the dash pattern of each line style in points for a line one point wide."

	^ Dictionary new
		  at: #solid put: #(  );
		  at: #dashed put: #( 3.7 1.6 );
		  at: #dashdot put: #( 6.4 1.6 1 1.6 );
		  at: #dotted put: #( 1 1.65 );
		  yourself
]

{ #category : 'private - demo' }
BpArtist class >> demoRandom [
	"Answer the generator of the random demos, seeded as in the gallery of the reference figures."

	^ Random seed: 19680801
]

{ #category : 'examples' }
BpArtist class >> exampleArtistsInOneChart [
	"Show two kinds of artists in the same chart: a histogram and a scatter plot of its counts; each takes the next color of the palette and the chart scales to cover both."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart
		addArtist: self instanceHistogram;
		addArtist: self instanceCountMarkers;
		title: 'BpHistogram and BpScatterPlot';
		legend;
		grid: true.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Artists'
]

{ #category : 'instances' }
BpArtist class >> instanceCountMarkers [
	"Answer a scatter plot of the counts of `BpArtist class>>instanceHistogram`, a diamond at the center of each bin: an artist computed from another one."

	<sampleInstance>
	| histogram edges |
	histogram := self normalHistogram.
	edges := histogram binEdges.
	^ (BpScatterPlot x: ((1 to: 15) collect: [ :index | (edges at: index) + (edges at: index + 1) / 2 ]) y: histogram counts)
		  marker: 'D';
		  s: 50;
		  label: 'counts';
		  yourself
]

{ #category : 'instances' }
BpArtist class >> instanceHistogram [
	"Answer a histogram of 500 normal samples in 15 bins, a kind of artist."

	<sampleInstance>
	^ self normalHistogram
]

{ #category : 'constants' }
BpArtist class >> lineStyleNames [
	"Answer the line style of each line style string."

	^ Dictionary new
		  at: '-' put: #solid;
		  at: '--' put: #dashed;
		  at: '-.' put: #dashdot;
		  at: ':' put: #dotted;
		  at: 'solid' put: #solid;
		  at: 'dashed' put: #dashed;
		  at: 'dashdot' put: #dashdot;
		  at: 'dotted' put: #dotted;
		  at: 'None' put: #none;
		  at: 'none' put: #none;
		  at: '' put: #none;
		  at: ' ' put: #none;
		  yourself
]

{ #category : 'constants' }
BpArtist class >> lineStyleOf: aSymbolOrString [
	"Answer the line style #solid, #dashed, #dashdot, #dotted or #none named by aSymbolOrString, a symbol or a string ('-', '--', '-.', ':', 'None', ...)."

	^ self dashPatterns
		  at: aSymbolOrString asSymbol
		  ifPresent: [ :pattern | aSymbolOrString asSymbol ]
		  ifAbsent: [
		  self lineStyleNames
			  at: aSymbolOrString asString
			  ifAbsent: [ self error: 'Unknown line style: ' , aSymbolOrString printString ] ]
]

{ #category : 'private - demo' }
BpArtist class >> linspaceFrom: aNumber to: anotherNumber count: anInteger [
	"Answer anInteger numbers evenly spaced from aNumber to anotherNumber included, as numpy linspace, to write gallery examples."

	anInteger = 1 ifTrue: [ ^ { aNumber } ].
	^ (0 to: anInteger - 1) collect: [ :index | aNumber + (index * (anotherNumber - aNumber) / (anInteger - 1)) ]
]

{ #category : 'private - demo' }
BpArtist class >> next: aCount from: aRandom [
	"Answer aCount numbers drawn from aRandom, between 0 and 1."

	^ (1 to: aCount) collect: [ :each | aRandom next ]
]

{ #category : 'private - demo' }
BpArtist class >> normalHistogram [
	"Answer a histogram of 500 normal samples in 15 bins."

	| random |
	random := Random seed: 19680801.
	^ (BpHistogram xValues: ((1 to: 500) collect: [ :each | random nextNormal ]))
		  bins: 15;
		  yourself
]

{ #category : 'accessing' }
BpArtist class >> pixelsPerPoint [
	"Answer how many pixels a typographic point (1/72 inch) takes: figures are drawn at 100 dots per inch."

	^ 100 / 72
]

{ #category : 'interaction' }
BpArtist >> addHandler: anAssociation to: aPatch [

	aPatch addEventHandler: (BlEventHandler
		 on: anAssociation key
		 do: [ :event | anAssociation value cull: event cull: aPatch ])
]

{ #category : 'axes' }
BpArtist >> allPatches [
	"Answer all my patches, as a flat collection."

	^ patches
]

{ #category : 'accessing - style' }
BpArtist >> alpha: aNumberOrNil [
	"Set the opacity of my patches, between 0 and 1 (nil for opaque)."

	alpha := aNumberOrNil.
	self refresh
]

{ #category : 'accessing' }
BpArtist >> chart [

	^ chart
]

{ #category : 'accessing' }
BpArtist >> chart: aChart [

	chart := aChart
]

{ #category : 'axes' }
BpArtist >> colorCount [
	"Answer how many colors of the palette of my chart I take."

	^ 1
]

{ #category : 'private - style' }
BpArtist >> colorOf: aColor [
	"Answer aColor made transparent by my alpha. A transparent color stays so: it draws nothing."

	^ (alpha isNil or: [ aColor isTransparent ])
		  ifTrue: [ aColor ]
		  ifFalse: [ aColor alpha: alpha ]
]

{ #category : 'private - computing' }
BpArtist >> compute [
	"Compute what my patches show from my data and settings."

	self subclassResponsibility
]

{ #category : 'axes' }
BpArtist >> defaultColors: aCollectionOfColors [
	"Set the colors my chart gives me from its palette, one per color I need (colorCount)."

	defaultColors := aCollectionOfColors.
	self refresh
]

{ #category : 'initialization' }
BpArtist >> initialize [

	super initialize.
	patchHandlers := OrderedCollection new.
	patches := #(  ).
	defaultColors := BpPalette default colors
]

{ #category : 'axes' }
BpArtist >> invertedAxes [
	"Answer the axes (#x, #y) I turn around: their values go down to the left or to the top, unless the limits of my chart are given."

	^ #(  )
]

{ #category : 'axes' }
BpArtist >> isAboveGrid [
	"Answer whether my patches are drawn above the grid: the patches of bars and scatter points are drawn below it, lines above it."

	^ false
]

{ #category : 'private - style' }
BpArtist >> isMany: aValue [
	"Answer whether aValue gives one value per dataset, point or item rather than one for all: a collection other than a string."

	^ aValue isCollection and: [ aValue isString not ]
]

{ #category : 'accessing - style' }
BpArtist >> label: aStringOrCollection [
	"Set the label shown in the legend: one string, or one per dataset for a histogram of several datasets."

	label := aStringOrCollection.
	self refresh
]

{ #category : 'axes' }
BpArtist >> legendEntries [
	"Answer my legend entries: associations from a label to a swatch element."

	^ #(  )
]

{ #category : 'inspector extensions' }
BpArtist >> liveElement [
	"Answer the figure showing me. When I have no chart yet, I am added to the chart of a new figure."

	| figure |
	chart ifNotNil: [ ^ chart liveElement ].
	figure := BpFigure new.
	figure charts first addArtist: self.
	^ figure
]

{ #category : 'axes' }
BpArtist >> logAxes [
	"Answer the axes (#x, #y) I put on a log scale."

	^ #(  )
]

{ #category : 'axes' }
BpArtist >> managedTicksOn: anAxis [
	"Answer the ticks I place on anAxis, as location -> label associations, or nil to let my chart choose them."

	^ nil
]

{ #category : 'private - computing' }
BpArtist >> newPatches [
	"Answer new patches showing my last computation."

	^ self subclassResponsibility
]

{ #category : 'private - style' }
BpArtist >> paintOf: aColorOrNil [
	"Answer aColorOrNil with my alpha, transparent for nil."

	^ aColorOrNil ifNil: [ Color transparent ] ifNotNil: [ self colorOf: aColorOrNil ]
]

{ #category : 'axes' }
BpArtist >> palette [
	"Answer the palette of my chart, or the default one while I am in no chart."

	^ chart ifNil: [ BpPalette default ] ifNotNil: [ chart palette ]
]

{ #category : 'axes' }
BpArtist >> paletteColorAt: anIndex [

	^ self palette colorAt: anIndex
]

{ #category : 'accessing' }
BpArtist >> patches [
	"Answer the patches I currently draw."

	^ patches
]

{ #category : 'private - computing' }
BpArtist >> refresh [
	"Recompute my data and my patches, and let my chart show them."

	self compute.
	patches := self newPatches.
	chart ifNotNil: [ chart artistChanged: self ]
]

{ #category : 'axes' }
BpArtist >> requiredValuesOn: anAxis [
	"Answer values on anAxis (#x or #y) that autoscaling must cover besides my patches."

	^ #(  )
]

{ #category : 'private - style' }
BpArtist >> setting: aValueOrCollection at: anIndex [
	"Answer a style setting for one dataset or point: the setting itself, or its element at anIndex when it is a collection (one per dataset or point)."

	^ (self isMany: aValueOrCollection)
		  ifTrue: [ aValueOrCollection at: anIndex ]
		  ifFalse: [ aValueOrCollection ]
]

{ #category : 'axes' }
BpArtist >> showsNumbersByColors [
	"Answer whether the colors of my patches show numbers, on the `BpColorScale` answered by colorScale: I can then have a color bar."

	^ false
]

{ #category : 'axes' }
BpArtist >> stickyValuesOn: anAxis [
	"Answer the values autoscaling margins must not go past on anAxis (#x or #y)."

	^ #(  )
]

{ #category : 'private - style' }
BpArtist >> strokeColor: aColor width: aNumberOfPoints style: aLineStyle [
	"Answer the stroke of a line of aColor, aNumberOfPoints wide, in aLineStyle (#solid, #dashed, #dashdot or #dotted): the dashes scale with the width, solid lines have projecting caps and dashed ones butt caps."

	| width builder |
	width := aNumberOfPoints * self class pixelsPerPoint.
	builder := BlBorder builder
		           paint: aColor;
		           width: width;
		           joinRound;
		           yourself.
	aLineStyle = #solid
		ifTrue: [ builder capSquare ]
		ifFalse: [
			builder
				capButt;
				dashArray: ((self class dashPatterns at: aLineStyle) collect: [ :each | each * width ]) ].
	^ builder build
]

{ #category : 'interaction' }
BpArtist >> whenPatch: anEventClass do: aBlock [
	"Evaluate aBlock with the event and the patch each time one of my patches receives an event of anEventClass. The handler is kept when my patches are rebuilt."

	patchHandlers add: anEventClass -> aBlock.
	self allPatches do: [ :each | self addHandler: anEventClass -> aBlock to: each ]
]
