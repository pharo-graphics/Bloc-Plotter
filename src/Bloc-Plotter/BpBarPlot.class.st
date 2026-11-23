"
I am a bar plot: the `BpArtist` of matplotlib `Axes.bar` and `Axes.barh`. I draw one rectangle (`BpRectanglePatch`) per bar, standing on its `bottom` at its position on the position axis and as long as its height on the value axis. Positions are numbers or category names (strings), which then become the ticks of my position axis.

## Examples

```
BpBarPlot scriptPlotType.
BpBarPlot scriptBarColors.
BpBarPlot scriptStacked.
BpBarPlot scriptGrouped.
BpBarPlot scriptHorizontal.
BpBarPlot scriptInteraction.
BpBarPlot exampleThreeBars
```

## Design Rationale

- My setters are the arguments of matplotlib `Axes.bar` in camel case (`edgeColor:`, `lineWidth:`, `tickLabel:` for tick_label), with symbols for its strings (`align: #edge`, `orientation: #horizontal`), so that the matplotlib gallery can be written almost word for word. Each setting takes one value for all bars or one per bar, broadcast as numpy does; `x` and `height` too.
- I keep the vocabulary of `Axes.bar` whatever my orientation: `x` is the position axis, `height` the value axis, `width` the thickness and `bottom` the base of the bars. `BpAxes>>barhY:width:` maps the arguments of `Axes.barh` on them, so its `height` and `left` arguments are my `width:` and `bottom:`.
- Strings in `x` are categories, as the matplotlib category axis: each distinct one takes the next position from 0 in order of appearance, and the categories label the ticks of my position axis (`managedTicksOn:`). `tickLabel:` labels the bars at their positions instead; with numbers and no tick labels, my axes choose the ticks.
- As matplotlib 3.7, `label:` takes one label, for one legend entry, or one per bar, for an entry per bar; labels starting with an underscore are hidden, which lets bars of the same color share one entry.
- The bottoms of the bars are sticky on the value axis: autoscaling adds no margin below them, as matplotlib sticky edges.

## Usage

1. `BpAxes>>barX:height:` and `BpAxes>>barhY:width:` create me with my data (`x:height:`) and add me to the axes (see `BpArtist`), which give me one color of their cycle.
2. My axes read my `stickyValuesOn:` (the bottoms), `managedTicksOn:` (categories or tick labels) and `logAxes` (the value axis when `log:` is true).

- `positions`, `dataValues` (matplotlib `BarContainer.datavalues`) and `patches` are the results of my last computation.

## Implementation Notes

- I have one slot and setter per matplotlib argument, hence many slots.
- Not supported yet: error bars (xerr, yerr, ecolor, capsize), hatches, `Axes.bar_label`.
- Unlike matplotlib, I take a color of the cycle even when `color:` is given, because my axes give it to me before I am configured.
- My categories are my own: several bar plots in the same axes share positions only when their categories come in the same order.

## Invariants and Assumptions

- When `x` and `height` are both collections, they have the same size; `x:height:` changes both at once.
- The values of `x` are all numbers or all strings.
"
Class {
	#name : 'BpBarPlot',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'height',
		'width',
		'bottom',
		'align',
		'orientation',
		'color',
		'edgeColor',
		'lineWidth',
		'tickLabel',
		'log',
		'positions',
		'heights',
		'categories'
	],
	#category : 'Bloc-Plotter-Bar',
	#package : 'Bloc-Plotter',
	#tag : 'Bar'
}

{ #category : 'examples' }
BpBarPlot class >> exampleBarColors [
	"matplotlib gallery: Bar color demo (bar_colors): categories, one color and one label per bar; the underscore hides the second red label from the legend."

	<sampleInstance>
	| figure axes |
	figure := BpFigure new.
	axes := figure axes first.
	(axes barX: #( 'apple' 'blueberry' 'cherry' 'orange' ) height: #( 40 100 30 55 ))
		label: #( 'red' 'blue' '_red' 'orange' );
		color: #( 'tab:red' 'tab:blue' 'tab:red' 'tab:orange' ).
	axes
		title: 'Fruit supply by kind and color';
		legend.
	^ figure
]

{ #category : 'examples' }
BpBarPlot class >> exampleGrouped [
	"matplotlib gallery: Grouped bar chart with labels (barchart), without the bar labels: three bar plots shifted by their width; the middle one labels the ticks with the species (set_xticks)."

	<sampleInstance>
	| species means figure axes width |
	species := #( 'Adelie' 'Chinstrap' 'Gentoo' ).
	means := {
		         ('Bill Depth' -> #( 18.35 18.43 14.98 )).
		         ('Bill Length' -> #( 38.79 48.83 47.50 )).
		         ('Flipper Length' -> #( 189.95 195.82 217.19 )) }.
	figure := BpFigure new.
	axes := figure axes first.
	width := 0.25.
	means withIndexDo: [ :each :index |
		| offset |
		offset := width * (index - 1).
		(axes barX: ((0 to: 2) collect: [ :position | position + offset ]) height: each value)
			width: width;
			label: each key ].
	axes artists second tickLabel: species.
	axes
		title: 'Penguin attributes by species';
		yLimits: #( 0 250 );
		legend.
	^ figure
]

{ #category : 'examples' }
BpBarPlot class >> exampleHorizontal [
	"matplotlib gallery: Horizontal bar chart (barh), without the error bars: the names label the ticks of the y axis, from top to bottom as with invert_yaxis."

	<sampleInstance>
	| random people figure axes |
	random := Random seed: 19680801.
	people := #( 'Tom' 'Dick' 'Harry' 'Slim' 'Jim' ).
	figure := BpFigure new.
	axes := figure axes first.
	(axes barhY: #( 4 3 2 1 0 ) width: (people collect: [ :each | 3 + (10 * random next) ])) tickLabel: people.
	axes title: 'How fast do you want to go today?'.
	^ figure
]

{ #category : 'examples' }
BpBarPlot class >> exampleInteractiveBars [
	"Bars with interaction handlers: hovering a bar highlights it, clicking it shows its category and height in the title."

	<sampleInstance>
	| figure axes bars |
	figure := BpFigure new.
	axes := figure axes first.
	bars := axes barX: #( 'apple' 'blueberry' 'cherry' 'orange' ) height: #( 40 100 30 55 ).
	axes title: 'Click a bar'.
	bars
		whenPatch: BlMouseEnterEvent do: [ :event :bar | bar background: BpColors tab10 second ];
		whenPatch: BlMouseLeaveEvent do: [ :event :bar | bar background: BpColors tab10 first ];
		whenPatch: BlClickEvent do: [ :event :bar |
			axes title: ('{1}: {2}' format: {
				 (bars x at: bar bin).
				 bar amount }) ].
	^ figure
]

{ #category : 'examples' }
BpBarPlot class >> examplePlotType [
	"matplotlib plot types: bar(x, height), eight bars one unit wide outlined in white."

	<sampleInstance>
	| figure axes |
	figure := BpFigure new.
	axes := figure axes first.
	(axes barX: ((0 to: 7) collect: [ :each | each + 0.5 ]) height: #( 4.8 5.5 3.5 4.6 6.5 6.6 2.6 3.0 ))
		width: 1;
		edgeColor: 'white';
		lineWidth: 0.7.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7).
	^ figure
]

{ #category : 'examples' }
BpBarPlot class >> exampleStacked [
	"matplotlib gallery: Stacked bar chart (bar_stacked): each bar plot starts on the tops of the previous one (bottom:)."

	<sampleInstance>
	| species weightCounts figure axes bottom |
	species := #( 'Adelie' 'Chinstrap' 'Gentoo' ).
	weightCounts := {
		                ('Below' -> #( 70 31 58 )).
		                ('Above' -> #( 82 37 66 )) }.
	figure := BpFigure new.
	axes := figure axes first.
	bottom := #( 0 0 0 ).
	weightCounts do: [ :each |
		(axes barX: species height: each value)
			width: 0.5;
			label: each key;
			bottom: bottom.
		bottom := bottom with: each value collect: [ :base :count | base + count ] ].
	axes
		title: 'Number of penguins with above average body mass';
		legend.
	^ figure
]

{ #category : 'examples' }
BpBarPlot class >> exampleThreeBars [
	"Answer three bars of fruits, in new axes."

	<sampleInstance>
	^ (BpAxes new
		   extent: 400 @ 300;
		   yourself) barX: #( 'apple' 'blueberry' 'cherry' ) height: #( 40 100 30 )
]

{ #category : 'script' }
BpBarPlot class >> scriptBarColors [
	"Reproduce the matplotlib gallery 'Bar color demo': one color and one legend label per bar."

	<example>
	^ self exampleBarColors show: 'bar_colors'
]

{ #category : 'script' }
BpBarPlot class >> scriptGrouped [
	"Reproduce the matplotlib gallery 'Grouped bar chart with labels', without the bar labels: three groups of three bars."

	<example>
	^ self exampleGrouped show: 'barchart'
]

{ #category : 'script' }
BpBarPlot class >> scriptHorizontal [
	"Reproduce the matplotlib gallery 'Horizontal bar chart', without the error bars."

	<example>
	^ self exampleHorizontal show: 'barh'
]

{ #category : 'script' }
BpBarPlot class >> scriptInteraction [
	"Interaction handlers on bars: hover a bar to highlight it, click it to see its category and height."

	<example>
	^ self exampleInteractiveBars show: 'Bar interaction'
]

{ #category : 'script' }
BpBarPlot class >> scriptPlotType [
	"Reproduce the matplotlib plot type bar(x, height)."

	<example>
	^ self examplePlotType show: 'bar(x, height)'
]

{ #category : 'script' }
BpBarPlot class >> scriptStacked [
	"Reproduce the matplotlib gallery 'Stacked bar chart': bars on top of each other with bottom:."

	<example>
	^ self exampleStacked show: 'bar_stacked'
]

{ #category : 'accessing - options' }
BpBarPlot >> align [

	^ align
]

{ #category : 'accessing - options' }
BpBarPlot >> align: aSymbol [
	"Set how the bars stand on their positions: #center (the default) or #edge (their left edge, or bottom edge when horizontal, at their positions)."

	(#( #center #edge ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown align: ' , aSymbol printString ].
	align := aSymbol.
	self refresh
]

{ #category : 'private - computing' }
BpBarPlot >> barCount [
	"Answer the number of bars: the size of x or height, whichever is a collection, 1 when both are single values."

	(x isNil or: [ height isNil ]) ifTrue: [ ^ 0 ].
	((self isMany: x) and: [ (self isMany: height) and: [ x size ~= height size ] ]) ifTrue: [
		^ self error: ('x and height have different sizes: {1} and {2}' format: {
			   x size.
			   height size }) ].
	(self isMany: x) ifTrue: [ ^ x size ].
	(self isMany: height) ifTrue: [ ^ height size ].
	^ 1
]

{ #category : 'accessing - options' }
BpBarPlot >> bottom [

	^ bottom
]

{ #category : 'accessing - options' }
BpBarPlot >> bottom: aNumberOrCollection [
	"Set where the bars start on the value axis (0 by default), one for all or one per bar, as matplotlib bottom (left for barh)."

	bottom := aNumberOrCollection.
	self refresh
]

{ #category : 'private - patches' }
BpBarPlot >> bottomAt: anIndex [

	^ self setting: bottom at: anIndex
]

{ #category : 'accessing - results' }
BpBarPlot >> categories [
	"Answer the distinct categories of x in order of appearance, the first at position 0, or nil when x holds numbers."

	^ categories
]

{ #category : 'private - computing' }
BpBarPlot >> categoriesOf: aCollection [
	"Answer the distinct strings of aCollection in order of appearance, or nil when it holds numbers."

	(aCollection allSatisfy: [ :each | each isNumber ]) ifTrue: [ ^ nil ].
	(aCollection allSatisfy: [ :each | each isString ]) ifFalse: [ ^ self error: 'x mixes numbers and categories' ].
	^ (aCollection asOrderedCollection
		   removeDuplicates;
		   yourself) asArray
]

{ #category : 'accessing - style' }
BpBarPlot >> color [

	^ color
]

{ #category : 'accessing - style' }
BpBarPlot >> color: aColorOrCollection [
	"Set the fill color of the bars, one for all or one per bar (a Color or a matplotlib name). Without it, the bars take the color my axes give me from their cycle."

	color := aColorOrCollection.
	self refresh
]

{ #category : 'private - computing' }
BpBarPlot >> compute [
	"Broadcast x and height to one value per bar, as numpy, and replace the categories of x by their positions."

	| values |
	values := (1 to: self barCount) collect: [ :index | self setting: x at: index ].
	heights := (1 to: values size) collect: [ :index | self setting: height at: index ].
	categories := self categoriesOf: values.
	positions := categories ifNil: [ values ] ifNotNil: [ values collect: [ :each | (categories indexOf: each) - 1 ] ]
]

{ #category : 'accessing - results' }
BpBarPlot >> dataValues [
	"Answer the height of each bar (matplotlib BarContainer.datavalues)."

	^ heights
]

{ #category : 'accessing - style' }
BpBarPlot >> edgeColor [

	^ edgeColor
]

{ #category : 'accessing - style' }
BpBarPlot >> edgeColor: aColorOrCollection [
	"Set the outline color of the bars, one for all or one per bar. Bars have no outline by default."

	edgeColor := aColorOrCollection.
	self refresh
]

{ #category : 'accessing - data' }
BpBarPlot >> height [

	^ height
]

{ #category : 'accessing - data' }
BpBarPlot >> height: aCollectionOrNumber [
	"Set the heights of the bars, one for all or one per bar."

	height := aCollectionOrNumber.
	self refresh
]

{ #category : 'initialization' }
BpBarPlot >> initialize [

	super initialize.
	width := 0.8.
	bottom := 0.
	align := #center.
	orientation := #vertical.
	lineWidth := 1.
	log := false.
	positions := #(  ).
	heights := #(  )
]

{ #category : 'accessing - options' }
BpBarPlot >> isHorizontal [

	^ orientation = #horizontal
]

{ #category : 'private - computing' }
BpBarPlot >> isMany: aValue [
	"Answer whether aValue gives one value per bar rather than one for all."

	^ aValue isCollection and: [ aValue isString not ]
]

{ #category : 'private - style' }
BpBarPlot >> isShownLabel: aStringOrNil [
	"Answer whether aStringOrNil gives a legend entry: matplotlib hides labels starting with an underscore."

	^ aStringOrNil isNotNil and: [ aStringOrNil asString isNotEmpty and: [ aStringOrNil asString first ~= $_ ] ]
]

{ #category : 'accessing - style' }
BpBarPlot >> label [

	^ label
]

{ #category : 'axes' }
BpBarPlot >> legendEntries [
	"Answer one entry for my label, or one per bar when my label is a collection, as matplotlib; labels starting with an underscore are hidden."

	positions ifEmpty: [ ^ #(  ) ].
	(self isMany: label) ifFalse: [
		^ (self isShownLabel: label)
			  ifTrue: [ { (label asString -> (self newSwatchFor: 1)) } ]
			  ifFalse: [ #(  ) ] ].
	^ (1 to: positions size)
		  select: [ :index | self isShownLabel: (label at: index) ]
		  thenCollect: [ :index | (label at: index) asString -> (self newSwatchFor: index) ]
]

{ #category : 'accessing - style' }
BpBarPlot >> lineWidth [

	^ lineWidth
]

{ #category : 'accessing - style' }
BpBarPlot >> lineWidth: aNumberOrCollection [
	"Set the width of the outlines in points (1 by default), one for all or one per bar."

	lineWidth := aNumberOrCollection.
	self refresh
]

{ #category : 'accessing - options' }
BpBarPlot >> log [

	^ log
]

{ #category : 'accessing - options' }
BpBarPlot >> log: aBoolean [
	"When true, the value axis of my axes uses a log scale."

	log := aBoolean.
	self refresh
]

{ #category : 'axes' }
BpBarPlot >> logAxes [
	"With log true, my value axis is on a log scale, as matplotlib."

	^ log
		  ifTrue: [ { self valueAxis } ]
		  ifFalse: [ #(  ) ]
]

{ #category : 'axes' }
BpBarPlot >> managedTicksOn: anAxis [
	"Answer the ticks of my position axis: my tick labels at the positions of my bars, or my categories at theirs; nil lets my axes choose them."

	(anAxis ~= self positionAxis or: [ positions isEmpty ]) ifTrue: [ ^ nil ].
	tickLabel ifNotNil: [ ^ positions withIndexCollect: [ :each :index | each -> (self setting: tickLabel at: index) asString ] ].
	categories ifNil: [ ^ nil ].
	^ categories withIndexCollect: [ :each :index | index - 1 -> each ]
]

{ #category : 'private - patches' }
BpBarPlot >> newBarAt: anIndex [
	"Answer the bar at anIndex, from its start on the position axis to start + width and from its bottom to bottom + height."

	| thickness start base bar |
	thickness := self setting: width at: anIndex.
	start := (positions at: anIndex) - (align = #center
		          ifTrue: [ thickness / 2 ]
		          ifFalse: [ 0 ]).
	base := self bottomAt: anIndex.
	bar := BpRectanglePatch new
		       artist: self;
		       dataset: 1;
		       bin: anIndex;
		       amount: (heights at: anIndex);
		       dataBounds: (Rectangle encompassing: {
			        (self oriented: start @ base).
			        (self oriented: start + thickness @ (base + (heights at: anIndex))) });
		       yourself.
	self paint: bar at: anIndex.
	patchHandlers do: [ :each | self addHandler: each to: bar ].
	^ bar
]

{ #category : 'private - computing' }
BpBarPlot >> newPatches [
	"Answer one bar per position."

	^ (1 to: positions size) collect: [ :index | self newBarAt: index ]
]

{ #category : 'axes' }
BpBarPlot >> newSwatchFor: anIndex [

	| swatch |
	swatch := BlElement new
		          extent: 20 @ 10;
		          yourself.
	self paint: swatch at: anIndex.
	^ swatch
]

{ #category : 'accessing - options' }
BpBarPlot >> orientation [

	^ orientation
]

{ #category : 'accessing - options' }
BpBarPlot >> orientation: aSymbol [
	"Set #vertical bars (matplotlib bar, the default) or #horizontal ones (barh)."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - patches' }
BpBarPlot >> oriented: aPoint [
	"Answer aPoint, given as (position @ value), in data coordinates: swapped for horizontal bars."

	^ self isHorizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'private - style' }
BpBarPlot >> paint: anElement at: anIndex [
	"Give anElement the fill, outline and opacity of the bar at anIndex."

	| edge |
	anElement background: (self colorOf: ((self setting: color at: anIndex) ifNil: [ defaultColors first ])).
	edge := self setting: edgeColor at: anIndex.
	edge ifNotNil: [
		anElement border:
			(BlBorder paint: (self colorOf: edge) width: (self setting: lineWidth at: anIndex) * self class pixelsPerPoint) ]
]

{ #category : 'axes' }
BpBarPlot >> positionAxis [
	"Answer the axis (#x or #y) along which my bars are placed."

	^ self isHorizontal
		  ifTrue: [ #y ]
		  ifFalse: [ #x ]
]

{ #category : 'accessing - results' }
BpBarPlot >> positions [
	"Answer the position of each bar on the position axis: x, with the categories replaced by their positions."

	^ positions
]

{ #category : 'axes' }
BpBarPlot >> stickyValuesOn: anAxis [
	"Answer the bottoms of my bars on my value axis: autoscaling adds no margin beyond them, as matplotlib sticky edges."

	anAxis = self valueAxis ifFalse: [ ^ #(  ) ].
	^ ((1 to: positions size) collect: [ :index | self bottomAt: index ] as: Set) asArray
]

{ #category : 'accessing - options' }
BpBarPlot >> tickLabel [

	^ tickLabel
]

{ #category : 'accessing - options' }
BpBarPlot >> tickLabel: aStringOrCollection [
	"Label the ticks at the positions of the bars (matplotlib tick_label), one label for all or one per bar."

	tickLabel := aStringOrCollection.
	self refresh
]

{ #category : 'axes' }
BpBarPlot >> valueAxis [
	"Answer the axis (#x or #y) along which my bars grow."

	^ self isHorizontal
		  ifTrue: [ #x ]
		  ifFalse: [ #y ]
]

{ #category : 'accessing - options' }
BpBarPlot >> width [

	^ width
]

{ #category : 'accessing - options' }
BpBarPlot >> width: aNumberOrCollection [
	"Set the thickness of the bars along the position axis (0.8 by default), one for all or one per bar. A negative width with align: #edge puts the bars before their positions."

	width := aNumberOrCollection.
	self refresh
]

{ #category : 'accessing - data' }
BpBarPlot >> x [

	^ x
]

{ #category : 'accessing - data' }
BpBarPlot >> x: aCollectionOrValue [
	"Set the positions of the bars (matplotlib x): numbers, or category names placed from 0."

	x := aCollectionOrValue.
	self refresh
]

{ #category : 'accessing - data' }
BpBarPlot >> x: aCollectionOrValue height: aCollectionOrNumber [
	"Set the positions and the heights of the bars at once, so that their number can change."

	x := aCollectionOrValue.
	height := aCollectionOrNumber.
	self refresh
]
