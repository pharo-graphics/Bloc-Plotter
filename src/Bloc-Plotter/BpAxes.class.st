"
I am a plot area with its ticks, title and legend. I hold artists (`BpArtist`), such as a `BpHistogram` added by `hist:`, a `BpScatterPlot` added by `scatterX:y:`, a `BpLine` added by `plotX:y:`, a `BpBoxPlot` added by `boxPlot:`, a `BpBarPlot` added by `barX:height:` or `barhY:width:`, a `BpStemPlot` added by `stem:` or `stemLocations:heads:`, a `BpFillBetween` added by `fillBetweenX:y1:y2:` or `fillBetweenY:x1:x2:`, a `BpStackPlot` added by `stackPlotX:ys:`, a `BpStairs` added by `stairs:` or `stairs:edges:`, a `BpViolinPlot` added by `violinPlot:` or `violinPlot:positions:`, or a `BpErrorBar` added by `errorBarX:y:yErr:` or `errorBarX:y:xErr:yErr:`, compute the limits and scales of the data from them, and show their patches in my `BpPlotArea` through a `BpDataTransform`.

## Examples

```
BpAxes instanceHistogram
```

## Design Rationale

- Autoscaling adds a margin of 5% on each side, stopped by the sticky values of the artists: the bars of a histogram start exactly at 0. Artists can also require values to be covered (`BpArtist>>requiredValuesOn:`): a box plot keeps half a unit around its positions.
- My scales follow my artists (`BpArtist>>logAxes`): a histogram with `log: true` puts its value axis on a log scale.
- Ticks are placed at fixed locations when given (`xTicks:`, `yTicks:`), else where an artist manages them (`BpArtist>>managedTicksOn:`: a box plot puts one at each box, a bar plot one at each category), otherwise their number is a setting (`xTickCount`, 6 by default, and `yTickCount`, 8) instead of depending on the axis length: computing it from my size would change my children during the layout pass and trigger another layout.
- My title is a `BpText`, so a line break gives a title on several lines.
- I have one slot per setting, hence many slots.

## Usage

1. `BpFigure>>rows:columns:` creates me; I can also be shown alone.
2. `hist:`, `scatterX:y:`, `plotX:y:`, `boxPlot:`, `barX:height:`, `barhY:width:`, `stem:`, `stemLocations:heads:`, `fillBetweenX:y1:y2:`, `fillBetweenY:x1:x2:` (and their variants filling down to 0), `stackPlotX:ys:`, `stairs:`, `stairs:edges:`, `violinPlot:`, `violinPlot:positions:`, `errorBarX:y:yErr:` and `errorBarX:y:xErr:yErr:` create an artist, and `addArtist:` gives it the next colors of my color cycle (`nextColors:`, the tab10 cycle of `BpColors`).
3. When an artist changes, it sends me `artistChanged:` and I `rebuild`: scales, limits (`autoScale:`), patches, legend, ticks (`BpTick`) and, after `grid: true`, grid lines (`BpGridLine`).
4. `BpAxesLayout` computes my plot bounds from the size of my tick labels and title, which gives its extent to my data transform.

- Nil limits mean autoscaling, and a tick formatter is a block answering the label of a value.
- I am mutable and keep my artists, but each rebuild replaces the ticks, legend and patches I show.

## Implementation Notes

- Not supported yet: axis labels, shared axes, a layout fitting the axes to their labels, colorbars, the style of the plot types page (small figure, grid below the data).
"
Class {
	#name : 'BpAxes',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'artists',
		'transform',
		'plotArea',
		'titleElement',
		'ticks',
		'showLegend',
		'xLimits',
		'yLimits',
		'xScale',
		'yScale',
		'xTickCount',
		'yTickCount',
		'colorIndex',
		'plotBounds',
		'xTickFormatter',
		'yTickFormatter',
		'showGrid',
		'xTicks',
		'yTicks'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'instances' }
BpAxes class >> instanceHistogram [
	"Answer axes showing a histogram, with a title."

	<sampleInstance>
	| random axes |
	random := Random seed: 19680801.
	axes := self new
		        extent: 400 @ 300;
		        yourself.
	(axes hist: ((1 to: 100) collect: [ :each | random nextNormalMean: 200 deviation: 25 ])) bins: 20.
	axes title: 'normal samples'.
	^ axes
]

{ #category : 'plotting' }
BpAxes >> addArtist: anArtist [
	"Show anArtist, giving it the next colors of my color cycle. Answer anArtist."

	artists add: anArtist.
	anArtist axes: self.
	anArtist defaultColors: (self nextColors: anArtist colorCount).
	^ anArtist
]

{ #category : 'plotting' }
BpAxes >> artistChanged: anArtist [

	self rebuild
]

{ #category : 'accessing' }
BpAxes >> artists [

	^ artists
]

{ #category : 'private - building' }
BpAxes >> autoScale: anAxis [
	"Answer the limits of anAxis (#x or #y) covering all patches, with a margin on each side."

	| values |
	values := self dataValuesOn: anAxis.
	(self scaleOf: anAxis) = #log ifTrue: [ ^ self logLimitsOf: (values select: [ :each | each > 0 ]) ].
	values ifEmpty: [ ^ #( 0 1 ) ].
	values min = values max ifTrue: [
		^ {
			  (values min - 0.5).
			  (values max + 0.5) } ].
	^ self limitsFrom: values min to: values max on: anAxis
]

{ #category : 'plotting' }
BpAxes >> barX: aCollectionOrValue height: aCollectionOrNumber [
	"Add vertical bars at the positions aCollectionOrValue (numbers or category names), aCollectionOrNumber high, and answer them, to be configured with width:, bottom:, align:, color:, tickLabel:, ... (see `BpBarPlot`)."

	^ self addArtist: (BpBarPlot new
		   x: aCollectionOrValue height: aCollectionOrNumber;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> barhY: aCollectionOrValue width: aCollectionOrNumber [
	"Add horizontal bars at the positions aCollectionOrValue on the y axis, aCollectionOrNumber long, and answer them, the horizontal counterpart of `barX:height:`. They keep the vocabulary of `barX:height:`: their thickness is width:, their start is bottom:."

	^ self addArtist: (BpBarPlot new
		   orientation: #horizontal;
		   x: aCollectionOrValue height: aCollectionOrNumber;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> boxPlot: aCollection [
	"Add a box plot of aCollection (numbers for one box, or one collection of numbers per box) and answer it, to be configured with notch:, whiskers:, positions:, widths:, patchArtist:, ... (see `BpBoxPlot`)."

	^ self addArtist: (BpBoxPlot new
		   x: aCollection;
		   yourself)
]

{ #category : 'layout' }
BpAxes >> computePlotBoundsIn: anExtent [
	"Compute the bounds of my plot area in anExtent, leaving room for the tick labels on the left and at the bottom, and for my title at the top. My tick labels and title must be measured."

	| leftTicks bottomTicks left bottom top right |
	leftTicks := ticks select: [ :each | each axis = #y ].
	bottomTicks := ticks select: [ :each | each axis = #x ].
	left := (leftTicks inject: 0 into: [ :max :each | max max: each label measuredExtent x ]) + 10.
	bottom := (bottomTicks inject: 0 into: [ :max :each | max max: each label measuredExtent y ]) + 10.
	top := self title isEmpty
		       ifTrue: [ 10 ]
		       ifFalse: [ titleElement measuredExtent y + 10 ].
	right := bottomTicks ifEmpty: [ 12 ] ifNotEmpty: [ bottomTicks last label measuredExtent x / 2 + 4 max: 12 ].
	self plotBounds: (left @ top corner: (anExtent x - right max: left + 1) @ (anExtent y - bottom max: top + 1))
]

{ #category : 'accessing' }
BpAxes >> dataTransform [
	"Answer the transform from data coordinates to the pixels of my plot area."

	^ transform
]

{ #category : 'private - building' }
BpAxes >> dataValuesOn: anAxis [
	"Answer the lowest and highest coordinates on anAxis of every patch, and the values my artists require."

	^ (self patches flatCollect: [ :each |
		   | box |
		   box := each dataBounds.
		   anAxis = #x
			   ifTrue: [
				   {
					   box left.
					   box right } ]
			   ifFalse: [
				   {
					   box top.
					   box bottom } ] ]) , (artists flatCollect: [ :each | each requiredValuesOn: anAxis ])
]

{ #category : 'private - building' }
BpAxes >> defaultLabelsFor: aCollectionOfLocations on: anAxis [

	^ (self scaleOf: anAxis) = #log
		  ifTrue: [ BpTickLocator logLabelsFor: aCollectionOfLocations ]
		  ifFalse: [ BpTickLocator labelsFor: aCollectionOfLocations ]
]

{ #category : 'plotting' }
BpAxes >> errorBarX: xValues y: yValues xErr: anXErrorOrNil yErr: aYErrorOrNil [
	"Draw the points of xValues and yValues joined by a line, with error bars on x and y (a number for every point, one number per point, or the lower then the upper errors; nil for none), and answer them, to be configured with format:, capSize:, errorColor:, upperLimits:, ... (see `BpErrorBar`)."

	^ self addArtist: ((BpErrorBar x: xValues y: yValues)
		   xErr: anXErrorOrNil;
		   yErr: aYErrorOrNil;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> errorBarX: xValues y: yValues yErr: anErrorOrNil [
	"Draw the points of xValues and yValues joined by a line, with error bars of anErrorOrNil on y, and answer them (see `errorBarX:y:xErr:yErr:`)."

	^ self
		  errorBarX: xValues
		  y: yValues
		  xErr: nil
		  yErr: anErrorOrNil
]

{ #category : 'plotting' }
BpAxes >> fillBetweenX: aCollection y1: aCollectionOrNumber [
	"Fill the area between the curve aCollectionOrNumber over aCollection and 0, and answer it (see `fillBetweenX:y1:y2:`)."

	^ self fillBetweenX: aCollection y1: aCollectionOrNumber y2: 0
]

{ #category : 'plotting' }
BpAxes >> fillBetweenX: aCollection y1: aCollectionOrNumber y2: anotherCollectionOrNumber [
	"Fill the area between two curves over aCollection (one value per x, or one for all) and answer it, to be configured with where:, interpolate:, step:, color:, alpha:, ... (see `BpFillBetween`)."

	^ self addArtist: (BpFillBetween new
		   x: aCollection y1: aCollectionOrNumber y2: anotherCollectionOrNumber;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> fillBetweenY: aCollection x1: aCollectionOrNumber [
	"Fill the area between the curve aCollectionOrNumber over the y values aCollection and 0, and answer it (see `fillBetweenY:x1:x2:`)."

	^ self fillBetweenY: aCollection x1: aCollectionOrNumber x2: 0
]

{ #category : 'plotting' }
BpAxes >> fillBetweenY: aCollection x1: aCollectionOrNumber x2: anotherCollectionOrNumber [
	"Fill the area between two curves over the y values aCollection and answer it, the horizontal counterpart of `fillBetweenX:y1:y2:`. The fill keeps the vocabulary of `fillBetweenX:y1:y2:`: y is its x, x1 and x2 its y1 and y2."

	^ self addArtist: (BpFillBetween new
		   orientation: #horizontal;
		   x: aCollection y1: aCollectionOrNumber y2: anotherCollectionOrNumber;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> grid: aBoolean [
	"Show or hide lines across the plot area at each tick."

	showGrid := aBoolean.
	self rebuild
]

{ #category : 'plotting' }
BpAxes >> hist: aCollection [
	"Add a histogram of aCollection (numbers, or one collection of numbers per dataset) and answer it, to be configured with bins:, density:, histType:, ... (see `BpHistogram`)."

	^ self addArtist: (BpHistogram new
		   x: aCollection;
		   yourself)
]

{ #category : 'initialization' }
BpAxes >> initialize [

	super initialize.
	artists := OrderedCollection new.
	ticks := #(  ).
	showLegend := false.
	showGrid := false.
	xScale := #linear.
	yScale := #linear.
	xTickCount := 6.
	yTickCount := 8.
	colorIndex := 0.
	plotBounds := 0 @ 0 corner: 1 @ 1.
	transform := BpDataTransform new.
	plotArea := BpPlotArea new
		            dataTransform: transform;
		            yourself.
	titleElement := BpText new.
	self
		layout: BpAxesLayout new;
		background: Color white;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChildren: {
			plotArea.
			titleElement }.
	self rebuild
]

{ #category : 'plotting' }
BpAxes >> legend [
	"Show a legend with the label of each dataset that has one."

	showLegend := true.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> legendElement [

	^ plotArea legend
]

{ #category : 'private - building' }
BpAxes >> limitsFrom: aLow to: aHigh on: anAxis [
	"Answer aLow and aHigh widened by 5% of their distance, the margins stopping at the sticky values of the artists (0 for the bars of a histogram)."

	| margin stickies |
	margin := aHigh - aLow * 0.05.
	stickies := artists flatCollect: [ :each | each stickyValuesOn: anAxis ].
	^ {
		  ((stickies select: [ :each | each between: aLow - margin and: aLow ])
			   ifEmpty: [ aLow - margin ]
			   ifNotEmpty: [ :found | found max ]).
		  ((stickies select: [ :each | each between: aHigh and: aHigh + margin ])
			   ifEmpty: [ aHigh + margin ]
			   ifNotEmpty: [ :found | found min ]) }
]

{ #category : 'private - building' }
BpAxes >> limitsOn: anAxis [

	^ anAxis = #x
		  ifTrue: [ transform xLimits ]
		  ifFalse: [ transform yLimits ]
]

{ #category : 'private - building' }
BpAxes >> logLimitsOf: aCollectionOfPositiveValues [
	"Answer limits covering the values with a margin of 5% on each side, measured in decades."

	| low high margin |
	aCollectionOfPositiveValues ifEmpty: [ ^ #( 1 10 ) ].
	low := aCollectionOfPositiveValues min log: 10.
	high := aCollectionOfPositiveValues max log: 10.
	margin := high = low
		          ifTrue: [ 1 ]
		          ifFalse: [ high - low * 0.05 ].
	^ {
		  (10 raisedTo: low - margin).
		  (10 raisedTo: high + margin) }
]

{ #category : 'private - building' }
BpAxes >> managedTicksOn: anAxis [
	"Answer the ticks an artist places on anAxis, unless ticks were fixed with xTicks: or yTicks:."

	(anAxis = #x
		 ifTrue: [ xTicks ]
		 ifFalse: [ yTicks ]) ifNotNil: [ ^ nil ].
	artists do: [ :each | (each managedTicksOn: anAxis) ifNotNil: [ :managed | ^ managed ] ].
	^ nil
]

{ #category : 'private - building' }
BpAxes >> newLegend [

	| entries |
	showLegend ifFalse: [ ^ nil ].
	entries := artists flatCollect: [ :each | each legendEntries ].
	entries ifEmpty: [ ^ nil ].
	^ BpLegend entries: entries
]

{ #category : 'private - building' }
BpAxes >> newTicksOn: anAxis [
	"Answer the ticks of anAxis: at its fixed locations, or the ones an artist manages (a box plot), or chosen for my current limits and scale, labeled by its formatter."

	| managed locations labels formatter |
	managed := self managedTicksOn: anAxis.
	locations := managed ifNil: [ self tickLocationsOn: anAxis ] ifNotNil: [ managed collect: [ :each | each key ] ].
	formatter := anAxis = #x
		             ifTrue: [ xTickFormatter ]
		             ifFalse: [ yTickFormatter ].
	labels := formatter
		          ifNil: [
		          managed ifNil: [ self defaultLabelsFor: locations on: anAxis ] ifNotNil: [ managed collect: [ :each | each value ] ] ]
		          ifNotNil: [ locations collect: [ :each | (formatter value: each) asString ] ].
	^ locations asArray with: labels asArray collect: [ :location :text | BpTick axis: anAxis location: location text: text ]
]

{ #category : 'plotting' }
BpAxes >> nextColors: anInteger [
	"Answer the next anInteger colors of my color cycle, the tab10 colors of `BpColors`."

	| cycle colors |
	cycle := BpColors tab10.
	colors := (1 to: anInteger) collect: [ :index | cycle at: colorIndex + index - 1 \\ cycle size + 1 ].
	colorIndex := colorIndex + anInteger.
	^ colors
]

{ #category : 'accessing' }
BpAxes >> patches [

	^ artists flatCollect: [ :each | each allPatches ]
]

{ #category : 'accessing' }
BpAxes >> plotArea [

	^ plotArea
]

{ #category : 'accessing' }
BpAxes >> plotBounds [
	"Answer the bounds of my plot area, as computed by my layout."

	^ plotBounds
]

{ #category : 'accessing' }
BpAxes >> plotBounds: aRectangle [

	plotBounds := aRectangle.
	transform extent: (aRectangle extent max: 1 @ 1)
]

{ #category : 'plotting' }
BpAxes >> plotX: xValues y: yValues [
	"Draw a line through the points of xValues and yValues. Answer the `BpLine`, to set its style."

	^ self addArtist: (BpLine x: xValues y: yValues)
]

{ #category : 'plotting' }
BpAxes >> plotX: xValues y: yValues format: aString [
	"Draw the points of xValues and yValues with the format aString ('o-', 'r--', 'x', ...; see `BpLine>>format:`). Answer the `BpLine`."

	^ (self plotX: xValues y: yValues)
		  format: aString;
		  yourself
]

{ #category : 'private - building' }
BpAxes >> rebuild [
	"Recompute my scales and limits from my artists, then show their patches, my legend, my ticks and my grid."

	self updateScales.
	transform
		xScale: xScale;
		yScale: yScale;
		xLimits: (xLimits ifNil: [ self autoScale: #x ]);
		yLimits: (yLimits ifNil: [ self autoScale: #y ]).
	plotArea patches: self patches.
	plotArea legend: self newLegend.
	self rebuildTicks.
	plotArea gridLines: (showGrid
		 ifTrue: [ ticks collect: [ :each | BpGridLine axis: each axis location: each location ] ]
		 ifFalse: [ #(  ) ])
]

{ #category : 'private - building' }
BpAxes >> rebuildTicks [
	"Replace my ticks by the ones of my current limits and scales."

	ticks do: [ :each | self removeChildren: each elements ].
	ticks := (self newTicksOn: #x) , (self newTicksOn: #y).
	ticks do: [ :each | self addChildren: each elements ]
]

{ #category : 'private - building' }
BpAxes >> scaleOf: anAxis [

	^ anAxis = #x
		  ifTrue: [ xScale ]
		  ifFalse: [ yScale ]
]

{ #category : 'plotting' }
BpAxes >> scatterX: xValues y: yValues [
	"Add a scatter plot of the points (xValues at: i) @ (yValues at: i) and answer it, to be configured with s:, c:, marker:, alpha:, ... (see `BpScatterPlot`)."

	^ self addArtist: (BpScatterPlot x: xValues y: yValues)
]

{ #category : 'plotting' }
BpAxes >> stackPlotX: aCollection ys: aCollectionOfCollections [
	"Stack the layers aCollectionOfCollections (one value per x each) over aCollection and answer the stack, to be configured with baseline:, colors:, label:, alpha:, ... (see `BpStackPlot`)."

	^ self addArtist: (BpStackPlot new
		   x: aCollection ys: aCollectionOfCollections;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> stairs: aCollection [
	"Draw steps of the heights aCollection between the edges 0, 1, 2, ... and answer them (see `stairs:edges:`)."

	^ self stairs: aCollection edges: nil
]

{ #category : 'plotting' }
BpAxes >> stairs: aCollection edges: aCollectionOrNil [
	"Draw steps of the heights aCollection between the edges aCollectionOrNil (one more than the heights, nil for 0, 1, 2, ...) and answer them, to be configured with baseline:, fill:, orientation:, color:, ... (see `BpStairs`)."

	^ self addArtist: (BpStairs new
		   values: aCollection edges: aCollectionOrNil;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> stem: aCollection [
	"Add a stem plot of the heads aCollection, located at 0, 1, 2, ..., and answer it, to be configured with lineFormat:, markerFormat:, baseFormat:, bottom:, orientation:, ... (see `BpStemPlot`)."

	^ self addArtist: (BpStemPlot new
		   heads: aCollection;
		   yourself)
]

{ #category : 'plotting' }
BpAxes >> stemLocations: aCollection heads: anotherCollection [
	"Add a stem plot of the heads anotherCollection at the locations aCollection and answer it (see `stem:`)."

	^ self addArtist: (BpStemPlot new
		   locations: aCollection heads: anotherCollection;
		   yourself)
]

{ #category : 'private - building' }
BpAxes >> tickCountOn: anAxis [

	^ anAxis = #x
		  ifTrue: [ xTickCount ]
		  ifFalse: [ yTickCount ]
]

{ #category : 'private - building' }
BpAxes >> tickLocationsOn: anAxis [

	| fixed limits |
	fixed := anAxis = #x
		         ifTrue: [ xTicks ]
		         ifFalse: [ yTicks ].
	fixed ifNotNil: [ ^ fixed ].
	limits := self limitsOn: anAxis.
	^ (self scaleOf: anAxis) = #log
		  ifTrue: [ BpTickLocator logTicksFrom: limits first to: limits last ]
		  ifFalse: [ BpTickLocator linearTicksFrom: limits first to: limits last count: (self tickCountOn: anAxis) ]
]

{ #category : 'accessing' }
BpAxes >> ticks [

	^ ticks
]

{ #category : 'accessing' }
BpAxes >> title [

	^ titleElement text asString
]

{ #category : 'accessing' }
BpAxes >> title: aString [
	"Set the title shown above my plot area; a line break gives a title on several lines."

	titleElement text: (aString asRopedText fontSize: 14)
]

{ #category : 'accessing' }
BpAxes >> titleElement [

	^ titleElement
]

{ #category : 'private - building' }
BpAxes >> updateScales [
	"Put on a log scale the axes my artists ask for, such as the value axis of a histogram with log: true."

	artists do: [ :each |
		each logAxes do: [ :axis |
			axis = #x
				ifTrue: [ xScale := #log ]
				ifFalse: [ yScale := #log ] ] ]
]

{ #category : 'plotting' }
BpAxes >> violinPlot: aCollection [
	"Draw violins of the data aCollection (a collection of numbers for one violin, or one collection per violin) at the positions 1, 2, 3, ... and answer them (see `violinPlot:positions:`)."

	^ self violinPlot: aCollection positions: nil
]

{ #category : 'plotting' }
BpAxes >> violinPlot: aCollection positions: aCollectionOrNil [
	"Draw violins of the data aCollection (a collection of numbers for one violin, or one collection per violin) at the positions aCollectionOrNil (nil for 1, 2, 3, ...) and answer them, to be configured with widths:, showMeans:, showMedians:, quantiles:, side:, ... (see `BpViolinPlot`)."

	^ self addArtist: (BpViolinPlot new
		   x: aCollection;
		   positions: aCollectionOrNil;
		   yourself)
]

{ #category : 'accessing' }
BpAxes >> xLimits [
	"Answer the data values shown at the left and right of my plot area."

	^ transform xLimits
]

{ #category : 'accessing' }
BpAxes >> xLimits: aCollectionOrNil [
	"Set the left and right data values; nil computes them from the data."

	xLimits := aCollectionOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> xScale [

	^ xScale
]

{ #category : 'accessing' }
BpAxes >> xScale: aSymbol [
	"Set #linear or #log."

	xScale := aSymbol.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> xTickCount [

	^ xTickCount
]

{ #category : 'accessing' }
BpAxes >> xTickCount: anInteger [
	"Set the largest number of intervals between x ticks."

	xTickCount := anInteger.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> xTickFormatter: aBlockOrNil [
	"Set a block answering the label of an x tick from its value; nil prints the values."

	xTickFormatter := aBlockOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> xTicks: aCollectionOfNumbers [
	"Put the ticks of the x axis at aCollectionOfNumbers instead of choosing them; nil chooses them again."

	xTicks := aCollectionOfNumbers ifNotNil: [ aCollectionOfNumbers asArray ].
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> yLimits [

	^ transform yLimits
]

{ #category : 'accessing' }
BpAxes >> yLimits: aCollectionOrNil [
	"Set the bottom and top data values; nil computes them from the data."

	yLimits := aCollectionOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> yScale [

	^ yScale
]

{ #category : 'accessing' }
BpAxes >> yScale: aSymbol [
	"Set #linear or #log."

	yScale := aSymbol.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> yTickCount [

	^ yTickCount
]

{ #category : 'accessing' }
BpAxes >> yTickCount: anInteger [
	"Set the largest number of intervals between y ticks."

	yTickCount := anInteger.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> yTickFormatter: aBlockOrNil [
	"Set a block answering the label of a y tick from its value; nil prints the values."

	yTickFormatter := aBlockOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpAxes >> yTicks: aCollectionOfNumbers [
	"Put the ticks of the y axis at aCollectionOfNumbers instead of choosing them; nil chooses them again."

	yTicks := aCollectionOfNumbers ifNotNil: [ aCollectionOfNumbers asArray ].
	self rebuild
]
