"
I am a stack plot, added by `BpAxes>>stackPlotX:ys:`: layers drawn on top of each other over the same x values, each one filled from the top of the previous layer to its own top. The running sums of the layers are my `stacks`; the curve the first layer starts from is my `baselineValues`, set by `baseline:`. I draw one closed `BpPolygonPatch` per layer, its `dataset` being the index of the layer.

## Examples

```
BpStackPlot scriptPlotType.
BpStackPlot scriptStackplotDemo.
BpStackPlot scriptBaselines.
BpStackPlot scriptInteraction.
BpStackPlot exampleLayers
```

## Design Rationale

- A layer is the area between two curves, so its polygon has the vertices of a `BpFillBetween` filling everywhere: its start on the bottom curve, along the top curve, its end, and back along the bottom curve.
- The baselines: #zero stacks on 0; #sym centers the stack on 0; #wiggle minimizes the sum of the squared slopes of the layers, which gives streamgraphs; #weightedWiggle does the same, weighting each slope by the size of its layer.
- Each layer takes the next color of the cycle; `colors:` gives one color per layer, repeated when there are fewer colors than layers. Layers have no outline unless `edgeColor:` is given, and `alpha:` makes them transparent.
- `label:` takes one label per layer (nil for none); a single string labels the first layer only.
- Like fills, my polygons are drawn below the grid.

## Usage

1. `BpAxes>>stackPlotX:ys:` creates me with my data (`x:ys:`) and adds me to the axes (see `BpArtist`), which give me one color of their cycle per layer.
2. My axes read my polygons (`patches`) for autoscaling and my `legendEntries` (one filled rectangle per labeled layer).

## Implementation Notes

- Not supported yet: hatches, and baselines given as a curve.
- I take colors of the cycle even when `colors:` is given, because my axes give them to me before I am configured.

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
	"The same three layers stacked on each baseline: #zero, #sym, #wiggle and #weightedWiggle."

	<sampleInstance>
	| random x layers figure |
	random := Random seed: 19680801.
	x := self linspaceFrom: 0 to: 100 count: 101.
	layers := (1 to: 3) collect: [ :each | self gaussianMixtureOver: x random: random ].
	figure := BpFigure rows: 2 columns: 2.
	#( #zero #sym #wiggle #weightedWiggle ) withIndexDo: [ :each :index |
		| axes |
		axes := figure axes at: index.
		(axes stackPlotX: x ys: layers) baseline: each.
		axes title: 'baseline: #' , each ].
	^ figure
]

{ #category : 'examples' }
BpStackPlot class >> exampleInteractiveStack [
	"The world population by continent: hovering a layer outlines it, clicking it shows its continent and its last value in the title."

	<sampleInstance>
	| figure axes stack |
	figure := self exampleWorldPopulation.
	axes := figure axes first.
	axes title: 'Click a continent'.
	stack := axes artists first.
	stack
		whenPatch: BlMouseEnterEvent do: [ :event :polygon | polygon border: (BlBorder paint: Color black width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :polygon | polygon border: BlBorder empty ];
		whenPatch: BlClickEvent do: [ :event :polygon |
			axes title: ('{1}: {2} billion people in 2018' format: {
				 (stack labelAt: polygon dataset).
				 ((stack stacks at: polygon dataset) last - (polygon dataset = 1
					   ifTrue: [ stack baselineValues last ]
					   ifFalse: [ (stack stacks at: polygon dataset - 1) last ]) printShowingDecimalPlaces: 3) }) ].
	^ figure
]

{ #category : 'examples' }
BpStackPlot class >> exampleLayers [
	"Answer three labeled layers stacked on zero, in new axes with a legend."

	<sampleInstance>
	| axes stack |
	axes := BpAxes new
		        extent: 400 @ 300;
		        yourself.
	stack := (axes stackPlotX: (1 to: 6) ys: #( #( 1 2 3 2 3 4 ) #( 2 2 1 2 3 2 ) #( 1 1 2 2 1 1 ) ))
		         label: #( 'first' 'second' 'third' );
		         yourself.
	axes legend.
	^ stack
]

{ #category : 'examples' }
BpStackPlot class >> examplePlotType [
	"Plot types: stackplot(x, y), three layers over x = 0, 2, 4, 6, 8 with fixed limits and ticks."

	<sampleInstance>
	| figure axes |
	figure := BpFigure new.
	axes := figure axes first.
	axes stackPlotX: (self arangeFrom: 0 to: 10 by: 2) ys: #( #( 1 1.25 2 2.75 3 ) #( 1 1 1 1 1 ) #( 2 1 2 1 2 ) ).
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'examples' }
BpStackPlot class >> exampleStreamGraph [
	"Gallery: Stackplots and streamgraphs (stackplot_demo), second figure: three random mixtures of gaussians stacked on the #wiggle baseline."

	<sampleInstance>
	| random x figure |
	random := Random seed: 19680801.
	x := self linspaceFrom: 0 to: 100 count: 101.
	figure := BpFigure new.
	(figure axes first stackPlotX: x ys: ((1 to: 3) collect: [ :each | self gaussianMixtureOver: x random: random ])) baseline:
		#wiggle.
	^ figure
]

{ #category : 'examples' }
BpStackPlot class >> exampleWorldPopulation [
	"Gallery: Stackplots and streamgraphs (stackplot_demo), first figure: the population of each continent from 1950 to 2018, in billions, one labeled layer per continent."

	<sampleInstance>
	| population figure axes |
	population := {
		              ('Africa' -> #( 0.228 0.284 0.365 0.477 0.631 0.814 1.044 1.275 )).
		              ('the Americas' -> #( 0.340 0.425 0.519 0.619 0.727 0.840 0.943 1.006 )).
		              ('Asia' -> #( 1.394 1.686 2.120 2.625 3.202 3.714 4.169 4.560 )).
		              ('Europe' -> #( 0.220 0.253 0.276 0.295 0.310 0.303 0.294 0.293 )).
		              ('Oceania' -> #( 0.012 0.015 0.019 0.022 0.026 0.031 0.036 0.039 )) }.
	figure := BpFigure new.
	axes := figure axes first.
	(axes stackPlotX: #( 1950 1960 1970 1980 1990 2000 2010 2018 ) ys: (population collect: [ :each | each value ]))
		label: (population collect: [ :each | each key ]);
		alpha: 0.8.
	axes
		legend;
		title: 'World population'.
	^ figure
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

{ #category : 'script' }
BpStackPlot class >> scriptBaselines [
	"Show the four baselines of a stack plot on the same layers."

	<example>
	^ self exampleBaselines show: 'stackplot baselines'
]

{ #category : 'script' }
BpStackPlot class >> scriptInteraction [
	"Interaction handlers on the layers of a stack plot: hover a continent to outline it, click it to see its population."

	<example>
	^ self exampleInteractiveStack show: 'Stack interaction'
]

{ #category : 'script' }
BpStackPlot class >> scriptPlotType [
	"Reproduce the plot type stackplot(x, y)."

	<example>
	^ self examplePlotType show: 'stackplot(x, y)'
]

{ #category : 'script' }
BpStackPlot class >> scriptStackplotDemo [
	"Reproduce the two figures of the gallery 'Stackplots and streamgraphs': the world population by continent, then a streamgraph."

	<example>
	self exampleWorldPopulation show: 'stackplot_demo'.
	^ self exampleStreamGraph show: 'stackplot_demo streamgraph'
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
	"Answer the fill color of a layer: my colors, repeated when there are fewer than layers, else the color my axes gave it."

	| palette |
	palette := colors ifNil: [ defaultColors ].
	(self isMany: palette) ifFalse: [ ^ palette ].
	^ palette at: anIndex - 1 \\ palette size + 1
]

{ #category : 'axes' }
BpStackPlot >> colorCount [
	"Answer one color of the cycle per layer."

	^ self layers size
]

{ #category : 'accessing' }
BpStackPlot >> colors: aColorOrCollection [
	"Set the fill colors of the layers, one color for all or one per layer, repeated when there are fewer colors than layers. Without it, each layer takes the next color of the cycle of my axes."

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
BpStackPlot >> edgeColor: aColorOrName [
	"Outline each layer with aColorOrName; nil, the default, draws no outline."

	edgeColor := aColorOrName.
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
