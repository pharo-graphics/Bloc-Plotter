"
I am a bar plot, added by `BpChart>>barX:height:` and `BpChart>>barhY:width:`. I draw one rectangle (`BpRectanglePatch`) per bar, standing on its `bottom` at its position on the position axis and as long as its height on the value axis. Positions are numbers or category names (strings), which then become the ticks of my position axis.

## Examples

```
BpBarPlot examplePlotType.
BpBarPlot exampleBarColors.
BpBarPlot exampleStacked.
BpBarPlot exampleGrouped.
BpBarPlot exampleHorizontal.
BpBarPlot exampleInteraction
```

## Design Rationale

- My settings take symbols (`align: #edge`, `orientation: #horizontal`). Each setting takes one value for all bars or one per bar, broadcast as numpy does; `x` and `height` too.
- I keep the vocabulary of `BpChart>>barX:height:` whatever my orientation: `x` is the position axis, `height` the value axis, `width` the thickness and `bottom` the base of the bars. `BpChart>>barhY:width:` keeps them: its y positions are my `x`, its widths my `height`, and the thickness and start of its bars my `width:` and `bottom:`.
- Strings in `x` are categories: each distinct one takes the next position from 0 in order of appearance, and the categories label the ticks of my position axis (`managedTicksOn:`). `tickLabel:` labels the bars at their positions instead; with numbers and no tick labels, my chart chooses the ticks.
- `label:` takes one label, for one legend entry, or one per bar, for an entry per bar; labels starting with an underscore are hidden, which lets bars of the same color share one entry.
- The bottoms of the bars are sticky on the value axis: autoscaling adds no margin below them.

## Usage

1. `BpChart>>barX:height:` and `BpChart>>barhY:width:` create me with my data (`x:height:`) and add me to the chart (see `BpArtist`), which gives me one color of its palette. `BpChart` creates me with `BpBarPlot class>>barX:height:` or `barhY:width:`, which also create me apart, to be added with `BpChart>>addArtist:`.
2. My chart reads my `stickyValuesOn:` (the bottoms), `managedTicksOn:` (categories or tick labels) and `logAxes` (the value axis when `log:` is true).

- `positions`, `dataValues` and `patches` are the results of my last computation.

## Implementation Notes

- I have one slot and setter per option, hence many slots.
- Not supported yet: error bars (xerr, yerr, ecolor, capsize), hatches, bar labels.
- I take a color of the palette even when `color:` is given, because my chart gives it to me without looking at my settings.
- My categories are my own: several bar plots in the same chart share positions only when their categories come in the same order.

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

{ #category : 'instance creation' }
BpBarPlot class >> barX: aCollectionOrValue height: aCollectionOrNumber [
	"Add vertical bars at the positions aCollectionOrValue (numbers or category names), aCollectionOrNumber high, and answer them, to be configured with width:, bottom:, align:, color:, tickLabel:, ... (see `BpBarPlot`)."

	^ self new
		x: aCollectionOrValue 
		height: aCollectionOrNumber;
		yourself
]

{ #category : 'instance creation' }
BpBarPlot class >> barhY: aCollectionOrValue width: aCollectionOrNumber [
	"Answer horizontal bars at the positions aCollectionOrValue on the y axis, aCollectionOrNumber long, the horizontal counterpart of `barX:height:`."

	^ self new
		  orientation: #horizontal;
		  x: aCollectionOrValue height: aCollectionOrNumber;
		  yourself
]

{ #category : 'examples' }
BpBarPlot class >> exampleBarColors [
	"Reproduce the gallery 'Bar color demo': one color and one legend label per bar."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: self instanceBarColors.
	chart
		title: 'Fruit supply by kind and color';
		legend.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'bar Colors'
]

{ #category : 'examples' }
BpBarPlot class >> exampleGrouped [
	"Reproduce the gallery 'Grouped bar chart with labels', without the bar labels: three groups of three bars."

	<example>
	| figure |
	figure := BpFigure new.
	figure chartAtRow: 1 column: 1 put: BpChart instanceGroupedBars.
	^ figure show: 'barchart'
]

{ #category : 'examples' }
BpBarPlot class >> exampleHorizontal [
	"Reproduce the gallery 'Horizontal bar chart', without the error bars."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: self instanceHorizontalBars.
	chart title: 'How fast do you want to go today?'.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'barh'
]

{ #category : 'examples' }
BpBarPlot class >> exampleInteraction [
	"Interaction handlers on bars: hover a bar to highlight it, click it to see its category and height."

	<example>
	| figure chart bars |
	figure := BpFigure new.
	chart := BpChart new.
	bars := chart addArtist: self instanceThreeBars.
	chart title: 'Click a bar'.
	bars
		whenPatch: BlMouseEnterEvent do: [ :event :bar | bar background: (chart palette colorAt: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :bar | bar background: (chart palette colorAt: 1) ];
		whenPatch: BlClickEvent do: [ :event :bar |
			chart title: ('{1}: {2}' format: {
				 (bars x at: bar bin).
				 bar amount }) ].
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Bar interaction'
]

{ #category : 'examples' }
BpBarPlot class >> examplePlotType [
	"Reproduce the plot type bar(x, height)."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: self instancePlotType.
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7).
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'bar(x, height)'
]

{ #category : 'examples' }
BpBarPlot class >> exampleStacked [
	"Reproduce the gallery 'Stacked bar chart': bars on top of each other with bottom:."

	<example>
	| figure |
	figure := BpFigure new.
	figure chartAtRow: 1 column: 1 put: BpChart instanceStackedBars.
	^ figure show: 'bar_stacked'
]

{ #category : 'instances' }
BpBarPlot class >> instanceBarColors [
	"Gallery: Bar color demo (bar_colors): categories, one color and one label per bar; the underscore hides the second red label from the legend."

	<sampleInstance>
	| chartPlotter |
	chartPlotter := self
		barX: #( 'apple' 'blueberry' 'cherry' 'orange' ) 
		height: #( 40 100 30 55 ).
	chartPlotter
		label: #( 'red' 'blue' '_red' 'orange' );
		color: (#( 1 2 1 5 ) collect: [ :each | BpQualitativePalette set1 colorAt: each ]).
	^ chartPlotter
]

{ #category : 'instances' }
BpBarPlot class >> instanceHorizontalBars [
	"Gallery: Horizontal bar chart (barh), without the error bars: the names label the ticks of the y axis, from top to bottom."

	<sampleInstance>
	| random people |
	random := Random seed: 19680801.
	people := #( 'Tom' 'Dick' 'Harry' 'Slim' 'Jim' ).
	^ (self barhY: #( 4 3 2 1 0 ) width: (people collect: [ :each | 3 + (10 * random next) ]))
		  tickLabel: people;
		  yourself
]

{ #category : 'instances' }
BpBarPlot class >> instancePlotType [
	"Plot types: bar(x, height), eight bars one unit wide outlined in white."

	<sampleInstance>
	^ (self barX: ((0 to: 7) collect: [ :each | each + 0.5 ]) height: #( 4.8 5.5 3.5 4.6 6.5 6.6 2.6 3.0 ))
		  width: 1;
		  edgeColor: ((BpSequentialPalette greys: 9) colorAt: 1);
		  lineWidth: 0.7;
		  yourself
]

{ #category : 'instances' }
BpBarPlot class >> instanceThreeBars [
	"Answer three bars of fruits."

	<sampleInstance>
	^ self barX: #( 'apple' 'blueberry' 'cherry' ) height: #( 40 100 30 )
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
	"Set where the bars start on the value axis (0 by default), one for all or one per bar."

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
	"Set the fill color of the bars, one for all or one per bar. Without it, the bars take the next color of the palette of my chart."

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
	"Answer the height of each bar."

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

{ #category : 'private - style' }
BpBarPlot >> isShownLabel: aStringOrNil [
	"Answer whether aStringOrNil gives a legend entry: labels starting with an underscore are hidden."

	^ aStringOrNil isNotNil and: [ aStringOrNil asString isNotEmpty and: [ aStringOrNil asString first ~= $_ ] ]
]

{ #category : 'accessing - style' }
BpBarPlot >> label [

	^ label
]

{ #category : 'axes' }
BpBarPlot >> legendEntries [
	"Answer one entry for my label, or one per bar when my label is a collection; labels starting with an underscore are hidden."

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
	"When true, the value axis of my chart uses a log scale."

	log := aBoolean.
	self refresh
]

{ #category : 'axes' }
BpBarPlot >> logAxes [
	"With log true, my value axis is on a log scale."

	^ log
		  ifTrue: [ { self valueAxis } ]
		  ifFalse: [ #(  ) ]
]

{ #category : 'axes' }
BpBarPlot >> managedTicksOn: anAxis [
	"Answer the ticks of my position axis: my tick labels at the positions of my bars, or my categories at theirs; nil lets my chart choose them."

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
	"Set #vertical bars (`BpChart>>barX:height:`, the default) or #horizontal ones (`BpChart>>barhY:width:`)."

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
	"Answer the bottoms of my bars on my value axis: autoscaling adds no margin beyond them."

	anAxis = self valueAxis ifFalse: [ ^ #(  ) ].
	^ ((1 to: positions size) collect: [ :index | self bottomAt: index ] as: Set) asArray
]

{ #category : 'accessing - options' }
BpBarPlot >> tickLabel [

	^ tickLabel
]

{ #category : 'accessing - options' }
BpBarPlot >> tickLabel: aStringOrCollection [
	"Label the ticks at the positions of the bars, one label for all or one per bar."

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
	"Set the positions of the bars: numbers, or category names placed from 0."

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
