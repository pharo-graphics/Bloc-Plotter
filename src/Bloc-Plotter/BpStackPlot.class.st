"
I am a stack plot, added by `BpChart>>stackPlotX:ys:`: layers drawn on top of each other over the same x values, each one filled from the top of the previous layer to its own top. The running sums of the layers are my `stacks`; the curve the first layer starts from is my `baselineValues`, set by `baseline:`. I draw one closed `BpPolygonPatch` per layer, its `dataset` being the index of the layer.

## Examples

```
BpStackPlot examplePlotType.
BpStackPlot exampleStackPlotDemo.
BpStackPlot exampleBaselines.
BpStackPlot exampleInteraction
```

## Design Rationale

- A layer is the area between two curves, so its polygon has the vertices of a `BpFillBetween` filling everywhere: its start on the bottom curve, along the top curve, its end, and back along the bottom curve.
- The baselines: #zero stacks on 0; #sym centers the stack on 0; #wiggle minimizes the sum of the squared slopes of the layers, which gives streamgraphs; #weightedWiggle does the same, weighting each slope by the size of its layer.
- Each layer takes the next color of the palette of my chart; `colors:` gives one color per layer, repeated when there are fewer colors than layers. Layers have no outline unless `edgeColor:` is given, and `alpha:` makes them transparent.
- `label:` takes one label per layer (nil for none); a single string labels the first layer only.
- Like fills, my polygons are drawn below the grid.

## Usage

1. `BpChart>>stackPlotX:ys:` creates me with my data (`x:ys:`) and adds me to the chart (see `BpArtist`), which gives me one color of its palette per layer.
2. My chart reads my polygons (`patches`) for autoscaling and my `legendEntries` (one filled rectangle per labeled layer).

## Implementation Notes

- Not supported yet: hatches, and baselines given as a curve.
- I take colors of the palette even when `colors:` is given, because my chart gives them to me before I am configured.

## Invariants and Assumptions

- Each layer has one value per x; `x:ys:` changes the data at once. A single collection of numbers is one layer.
"
Class {
	#name : 'BpStackPlot',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'ys',
		'baseline',
		'colors',
		'edgeColor',
		'lineWidth',
		'baselineValues',
		'stacks'
	],
	#category : 'Bloc-Plotter-Stack',
	#package : 'Bloc-Plotter',
	#tag : 'Stack'
}

{ #category : 'examples' }
BpStackPlot class >> exampleBaselines [
	"Show the four baselines of a stack plot on the same layers."

	<example>
	^ BpFigure instanceStackPlotBaselines show: 'stackplot baselines'
]

{ #category : 'examples' }
BpStackPlot class >> exampleInteraction [
	"Interaction handlers on the layers of a stack plot: hover a continent to outline it, click it to see its population."

	<example>
	^ BpFigure instanceInteractiveStack show: 'Stack interaction'
]

{ #category : 'examples' }
BpStackPlot class >> examplePlotType [
	"Reproduce the plot type stackplot(x, y)."

	<example>
	^ BpFigure instanceStackPlotType show: 'stackplot(x, y)'
]

{ #category : 'examples' }
BpStackPlot class >> exampleStackPlotDemo [
	"Reproduce the two figures of the gallery 'Stackplots and streamgraphs': the world population by continent, then a streamgraph."

	<example>
	BpFigure instanceStackPlotWorldPopulation show: 'stackplot_demo'.
	^ BpFigure instanceStackPlotStreamGraph show: 'stackplot_demo streamgraph'
]

{ #category : 'private - demo' }
BpStackPlot class >> gaussianMixtureOver: someXs random: aRandom [
	"Answer the sum of five gaussians of random amplitudes, centers and widths over someXs, as the streamgraph of the gallery stackplot_demo builds its layers."

	| span values |
	span := someXs last - someXs first.
	values := Array new: someXs size withAll: 0.
	5 timesRepeat: [
		| amplitude center scale |
		amplitude := 1 / (0.1 + aRandom next).
		center := span * (2 * aRandom next - 0.5).
		scale := 10 / (0.1 + aRandom next) / span.
		values := values with: someXs collect: [ :value :each | value + (amplitude * (scale * (each - center)) squared negated exp) ] ].
	^ values
]

{ #category : 'instances' }
BpStackPlot class >> instanceLayers [
	"Answer three labeled layers stacked on zero, in a new chart with a legend."

	<sampleInstance>
	| chart stack |
	chart := BpChart new
		         extent: 400 @ 300;
		         yourself.
	stack := (chart stackPlotX: (1 to: 6) ys: #( #( 1 2 3 2 3 4 ) #( 2 2 1 2 3 2 ) #( 1 1 2 2 1 1 ) ))
		         label: #( 'first' 'second' 'third' );
		         yourself.
	chart legend.
	^ stack
]

{ #category : 'accessing' }
BpStackPlot >> baseline: aSymbol [
	"Set the curve the first layer starts from: #zero (the default), #sym (the stack centered on zero), #wiggle (the sum of the squared slopes of the layers is minimal, for streamgraphs) or #weightedWiggle (the same, weighted by the size of the layers)."

	(#( #zero #sym #wiggle #weightedWiggle ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown baseline: ' , aSymbol printString ].
	baseline := aSymbol.
	self refresh
]

{ #category : 'private - computing' }
BpStackPlot >> baselineOf: someLayers sums: someSums [
	"Answer the curve the first layer starts from, one value per x, for the running sums someSums of someLayers."

	someLayers isEmpty ifTrue: [ ^ Array new: x size withAll: 0 ].
	baseline = #sym ifTrue: [ ^ someSums last collect: [ :total | total / -2 ] ].
	baseline = #wiggle ifTrue: [ ^ self wiggleBaselineOf: someLayers ].
	baseline = #weightedWiggle ifTrue: [ ^ self weightedWiggleBaselineOf: someLayers sums: someSums ].
	^ Array new: x size withAll: 0
]

{ #category : 'results' }
BpStackPlot >> baselineValues [
	"Answer the curve the first layer starts from, one value per x."

	^ baselineValues
]

{ #category : 'private - style' }
BpStackPlot >> colorAt: anIndex [
	"Answer the fill color of a layer: my colors, repeated when there are fewer than layers, else the color my chart gave it."

	| palette |
	palette := colors ifNil: [ defaultColors ].
	(self isMany: palette) ifFalse: [ ^ palette ].
	^ palette at: anIndex - 1 \\ palette size + 1
]

{ #category : 'axes' }
BpStackPlot >> colorCount [
	"Answer one color of the palette per layer."

	^ self layers size
]

{ #category : 'accessing' }
BpStackPlot >> colors: aColorOrCollection [
	"Set the fill colors of the layers, one color for all or one per layer, repeated when there are fewer colors than layers. Without it, each layer takes the next color of the palette of my chart."

	colors := aColorOrCollection.
	self refresh
]

{ #category : 'private - computing' }
BpStackPlot >> compute [
	"Check that each layer has one value per x, then stack the layers on my baseline."

	| layers running sums |
	layers := self layers.
	layers withIndexDo: [ :each :index |
		each size ~= x size ifTrue: [
			^ self error: ('layer {1} has {2} values for {3} x values' format: {
				   index.
				   each size.
				   x size }) ] ].
	running := Array new: x size withAll: 0.
	sums := layers collect: [ :each | running := running with: each collect: [ :sum :value | sum + value ] ].
	baselineValues := self baselineOf: layers sums: sums.
	stacks := sums collect: [ :each | each with: baselineValues collect: [ :sum :shift | sum + shift ] ]
]

{ #category : 'accessing' }
BpStackPlot >> edgeColor: aColorOrNil [
	"Outline each layer with aColorOrNil; nil, the default, draws no outline."

	edgeColor := aColorOrNil.
	self refresh
]

{ #category : 'initialization' }
BpStackPlot >> initialize [

	super initialize.
	x := #(  ).
	ys := #(  ).
	baseline := #zero.
	lineWidth := 1.
	baselineValues := #(  ).
	stacks := #(  )
]

{ #category : 'private - style' }
BpStackPlot >> labelAt: anIndex [
	"Answer the label of a layer: the one at anIndex when my label is a collection, else my label for the first layer only."

	(self isMany: label) ifTrue: [ ^ label at: anIndex ifAbsent: [ nil ] ].
	anIndex = 1 ifFalse: [ ^ nil ].
	^ label
]

{ #category : 'private - computing' }
BpStackPlot >> layers [
	"Answer my layers as arrays: one collection of numbers is a single layer."

	ys isEmpty ifTrue: [ ^ #(  ) ].
	ys first isNumber ifTrue: [ ^ { ys asArray } ].
	^ ys asArray collect: [ :each | each asArray ]
]

{ #category : 'axes' }
BpStackPlot >> legendEntries [
	"Answer, for each layer with a label, its label and a rectangle filled as the layer."

	^ (1 to: stacks size) select: [ :index | (self labelAt: index) isNotNil ] thenCollect: [ :index |
		  (self labelAt: index) asString -> (BlElement new
			   extent: 20 @ 10;
			   in: [ :swatch | self paint: swatch layer: index ];
			   yourself) ]
]

{ #category : 'accessing' }
BpStackPlot >> lineWidth: aNumberOfPoints [
	"Set the width of the outlines, in points (1 by default)."

	lineWidth := aNumberOfPoints.
	self refresh
]

{ #category : 'private - computing' }
BpStackPlot >> newPatches [
	"Answer one closed polygon per layer, from the top of the previous layer (or the baseline) to its own top."

	| bottoms |
	x isEmpty ifTrue: [ ^ #(  ) ].
	bottoms := baselineValues.
	^ stacks withIndexCollect: [ :tops :index |
		  | polygon |
		  polygon := self newPolygonFor: index tops: tops bottoms: bottoms.
		  bottoms := tops.
		  polygon ]
]

{ #category : 'private - patches' }
BpStackPlot >> newPolygonFor: anIndex tops: someTops bottoms: someBottoms [
	"Answer the closed polygon of a layer: its start on the bottom curve, along the top curve, its end on the bottom curve, and back along it; styled and with my handlers."

	| polygon |
	polygon := BpPolygonPatch new
		           artist: self;
		           dataset: anIndex;
		           closed: true;
		           dataVertices:
			           { (x first @ someBottoms first) } , (x with: someTops collect: [ :eachX :each | eachX @ each ])
			           , { (x last @ someBottoms last) } , (x reversed with: someBottoms reversed collect: [ :eachX :each | eachX @ each ]);
		           yourself.
	self paint: polygon layer: anIndex.
	patchHandlers do: [ :each | self addHandler: each to: polygon ].
	^ polygon
]

{ #category : 'private - style' }
BpStackPlot >> paint: anElement layer: anIndex [
	"Give anElement the fill of a layer and, when I have an edge color, its outline."

	anElement background: (self paintOf: (self colorAt: anIndex)).
	(edgeColor isNil or: [ lineWidth isZero ]) ifTrue: [ ^ self ].
	anElement border: (BlBorder paint: (self paintOf: edgeColor) width: lineWidth * self class pixelsPerPoint)
]

{ #category : 'results' }
BpStackPlot >> stacks [
	"Answer the top of each layer, one value per x: the running sums of the layers, shifted by my baseline."

	^ stacks
]

{ #category : 'private - computing' }
BpStackPlot >> weightedWiggleBaselineOf: someLayers sums: someSums [
	"Answer the baseline minimizing the slopes of the layers weighted by their size: from x to x, it moves by the growth of each layer times how far the middle of the layer is above the middle of the stack, relative to the total; the stack is then centered on it."

	| totals center |
	totals := someSums last.
	center := 0.
	^ (1 to: x size) collect: [ :column |
		  column > 1 ifTrue: [
			  center := center + (someLayers withIndexCollect: [ :layer :row |
				             | total moveUp growth |
				             total := totals at: column.
				             moveUp := total > 0
					                       ifTrue: [ total - ((someSums at: row) at: column) + ((layer at: column) / 2) / total ]
					                       ifFalse: [ 0 ].
				             growth := (layer at: column) - (layer at: column - 1).
				             growth * (moveUp - (1 / 2)) ]) sum ].
		  center - ((totals at: column) / 2) ]
]

{ #category : 'private - computing' }
BpStackPlot >> wiggleBaselineOf: someLayers [
	"Answer the baseline minimizing the sum of the squared slopes of the layers: minus the sum of the layers weighted by m + 1/2 - i for the i-th of m layers, divided by m."

	| count |
	count := someLayers size.
	^ (1 to: x size) collect: [ :column |
		  (someLayers withIndexCollect: [ :layer :row | (layer at: column) * (count + (1 / 2) - row) ]) sum / count negated ]
]

{ #category : 'accessing' }
BpStackPlot >> x: aCollection ys: aCollectionOfCollections [
	"Set the x values and the layers to stack: one collection of numbers per layer, one number per x. A single collection of numbers is one layer."

	x := aCollection asArray.
	ys := aCollectionOfCollections.
	self refresh
]
