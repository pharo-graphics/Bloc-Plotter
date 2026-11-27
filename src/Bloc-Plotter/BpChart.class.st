"
I am a plot area with its ticks, title and legend. I hold artists (`BpArtist`), such as a `BpHistogram`, a `BpScatterPlot`, a `BpLine`, a `BpBoxPlot`, a `BpStemPlot`, a `BpDensityPlot`, a `BpErrorBar`, a `BpStairs`, a `BpFillBetween`, a `BpStackPlot`, a `BpViolinPlot`, a `BpHexbin` or a `BpHeatmap` added by `addArtist:`, or a `BpBarPlot` added by `barXValues:heightValues:` or `barhYValues:widthValues:`, compute the limits and scales of the data from them, and show their patches in my `BpPlotArea` through a `BpDataTransform`.

## Examples

```
BpChart exampleArtistsInOneChart.
BpChart instanceArtistsInOneChart.
BpChart instanceHistogram.
BpChart instanceGroupedBars.
BpChart instanceStackedBars.
BpChart instanceLineFormats.
BpChart instanceLinePlotType
```

## Design Rationale

- Autoscaling adds a margin of 5% on each side, stopped by the sticky values of the artists: the bars of a histogram start exactly at 0. Artists can also require values to be covered (`BpArtist>>requiredValuesOn:`): a box plot keeps half a unit around its positions.
- My scales follow my artists (`BpArtist>>logAxes`): a histogram with `log: true` puts its value axis on a log scale. An artist can also turn an axis around (`BpArtist>>invertedAxes`), as the rows of a heatmap; limits given from the largest to the smallest value do it too.
- Ticks are placed at fixed locations when given (`xTicks:`, `yTicks:`), else where an artist manages them (`BpArtist>>managedTicksOn:`: a box plot puts one at each box, a bar plot one at each category), otherwise their number is a setting (`xTickCount`, 6 by default, and `yTickCount`, 8) instead of depending on the axis length: computing it from my size would change my children during the layout pass and trigger another layout.
- My title is a `BpText`, so a line break gives a title on several lines.
- The transform, the ticks, the grid lines and the place of the legend are created or chosen by methods of their own (`newTransform`, `newTickOn:location:text:`, `newGridLineFor:`, `showLegend:`), which `BpPolarChart` redefines, as well as the default settings (`initializeSettings`).
- I have one slot per setting, hence many slots.

## Usage

1. `BpFigure>>rows:columns:chartClass:` creates me, or I am built apart and placed with `BpFigure>>chartAtRow:column:put:`; I can also be shown alone.
2. `addArtist:` adds an artist created by its class (`BpHistogram class>>xValues:`, `BpScatterPlot class>>x:y:`, `BpLine class>>x:y:`, `BpFillBetween class>>x:y1:y2:`, `BpHeatmap class>>matrix:`…), gives it the next colors of my palette (`nextColors:`) and answers it; several artists of different kinds can share me (`BpChart class>>instanceArtistsInOneChart`). `barXValues:heightValues:` and `barhYValues:widthValues:` create a bar plot and add it the same way. `palette:` changes the palette and recolors the artists already added.
3. When an artist changes, it sends me `artistChanged:` and I `rebuild`: scales, limits (`autoScale:`), patches, legend, ticks (`BpTick`), color bars (`BpColorBar`, added by `addColorBarFor:`) and, after `grid: true`, grid lines (`BpGridLine`).
4. `BpChartLayout` computes my plot bounds from the size of my tick labels, title and color bars, which gives its extent to my data transform.

- Nil limits mean autoscaling, and a tick formatter is a block answering the label of a value.
- I am mutable and keep my artists, but each rebuild replaces the ticks, legend and patches I show.

## Implementation Notes

- Not supported yet: axis labels, shared axes, a layout fitting the charts to their labels, the style of the plot types page (small figure, grid below the data).
"
Class {
	#name : 'BpChart',
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
		'yTicks',
		'palette',
		'colorBars'
	],
	#category : 'Bloc-Plotter-Chart',
	#package : 'Bloc-Plotter',
	#tag : 'Chart'
}

{ #category : 'examples' }
BpChart class >> exampleArtistsInOneChart [
	"Show two kinds of artists in the same chart: a histogram and a scatter plot of its counts (see `BpChart class>>instanceArtistsInOneChart`)."

	<example>
	| figure |
	figure := BpFigure new.
	figure chartAtRow: 1 column: 1 put: self instanceArtistsInOneChart.
	^ figure show: 'Artists'
]

{ #category : 'instances' }
BpChart class >> instanceArtistsInOneChart [
	"Answer a chart holding two kinds of artists: a histogram of normal samples and, above it, a scatter plot of its counts. Each takes the next color of the palette and the chart scales to cover both."

	<sampleInstance>
	| random chart histogram edges |
	random := Random seed: 19680801.
	chart := self new.
	histogram := chart addArtist: ((BpHistogram xValues: ((1 to: 500) collect: [ :each | random nextNormal ]))
		              bins: 15;
		              yourself).
	edges := histogram binEdges.
	chart addArtist:
		((BpScatterPlot x: ((1 to: 15) collect: [ :index | (edges at: index) + (edges at: index + 1) / 2 ]) y: histogram counts)
			 marker: 'D';
			 s: 50;
			 label: 'counts';
			 yourself).
	^ chart
		  title: 'BpHistogram and BpScatterPlot';
		  legend;
		  grid: true;
		  yourself
]

{ #category : 'instances' }
BpChart class >> instanceGroupedBars [
	"Answer a chart of three groups of bars side by side (see `BpBarPlot`), the ticks labeled with the penguin species."

	<sampleInstance>
	| chart |
	chart := self new.
	chart
		addArtist: BpBarPlot instanceBillDepths;
		addArtist: BpBarPlot instanceBillLengths;
		addArtist: BpBarPlot instanceFlipperLengths.
	chart
		title: 'Penguin attributes by species';
		yLimits: #( 0 250 );
		legend.
	^ chart
]

{ #category : 'instances' }
BpChart class >> instanceHistogram [
	"Answer a chart showing a histogram, with a title."

	<sampleInstance>
	^ (self new
		   extent: 400 @ 300;
		   yourself)
		  addArtist: BpHistogram instanceNormalSamples;
		  title: 'normal samples';
		  yourself
]

{ #category : 'instances' }
BpChart class >> instanceLineFormats [
	"Answer a chart of three curves drawn with format strings (see `BpLine`) in the colors of the palette set1, with a legend."

	<sampleInstance>
	| chart |
	chart := self new.
	chart palette: BpQualitativePalette set1.
	chart
		addArtist: BpLine instanceLinearDashed;
		addArtist: BpLine instanceQuadraticSquares;
		addArtist: BpLine instanceCubicTriangles.
	chart
		title: 'Format strings';
		legend.
	^ chart
]

{ #category : 'instances' }
BpChart class >> instanceLinePlotType [
	"Answer the chart of the plot type of `BpLine`: markers only, a line, and a line with markers, with fixed limits and ticks."

	<sampleInstance>
	| chart |
	chart := self new.
	chart
		addArtist: BpLine instancePlotTypeMarkers;
		addArtist: BpLine instancePlotTypeLine;
		addArtist: BpLine instancePlotTypeLineMarkers.
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ chart
]

{ #category : 'instances' }
BpChart class >> instanceStackedBars [
	"Answer a chart of two layers of bars, the second standing on the first (see `BpBarPlot`)."

	<sampleInstance>
	| chart |
	chart := self new.
	chart
		addArtist: BpBarPlot instanceBelowAverageMass;
		addArtist: BpBarPlot instanceAboveAverageMass.
	chart
		title: 'Number of penguins with above average body mass';
		legend.
	^ chart
]

{ #category : 'plotting' }
BpChart >> addArtist: anArtist [
	"Show anArtist, giving it the next colors of my palette. Answer anArtist."

	artists add: anArtist.
	anArtist chart: self.
	self giveColorsTo: anArtist.
	^ anArtist
]

{ #category : 'plotting' }
BpChart >> addColorBarFor: anArtist [
	"Add beside my plot area a color bar telling which numbers anArtist (a heatmap, a hexbin or a scatter plot of numbers) shows by which colors, and answer it, to be configured with label:, tickCount:, ... (see `BpColorBar`)."

	| bar |
	bar := BpColorBar on: anArtist.
	colorBars add: bar.
	self addChild: bar.
	^ bar
]

{ #category : 'plotting' }
BpChart >> artistChanged: anArtist [

	self rebuild
]

{ #category : 'accessing' }
BpChart >> artists [

	^ artists
]

{ #category : 'private - building' }
BpChart >> autoScale: anAxis [
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

{ #category : 'private - building' }
BpChart >> automaticLimitsOn: anAxis [
	"Answer the limits covering my artists, turned around when one of them asks for it."

	| limits |
	limits := self autoScale: anAxis.
	^ (artists anySatisfy: [ :each | each invertedAxes includes: anAxis ])
		  ifTrue: [ limits reversed ]
		  ifFalse: [ limits ]
]

{ #category : 'plotting' }
BpChart >> barXValues: aCollectionOrValue heightValues: aCollectionOrNumber [
	"Add vertical bars at the positions aCollectionOrValue (numbers or category names), aCollectionOrNumber high, and answer them, to be configured with width:, bottom:, align:, color:, tickLabel:, ... (see `BpBarPlot`)."

	^ self addArtist: (BpBarPlot barXValues: aCollectionOrValue heightValues: aCollectionOrNumber)
]

{ #category : 'plotting' }
BpChart >> barhYValues: aCollectionOrValue widthValues: aCollectionOrNumber [
	"Add horizontal bars at the positions aCollectionOrValue on the y axis, aCollectionOrNumber long, and answer them, the horizontal counterpart of `barX:height:`. They keep the vocabulary of `barX:height:`: their thickness is width:, their start is bottom:."

	^ self addArtist: (BpBarPlot barhYValues: aCollectionOrValue widthValues: aCollectionOrNumber)
]

{ #category : 'accessing' }
BpChart >> colorBars [

	^ colorBars
]

{ #category : 'layout' }
BpChart >> colorBarsWidth [
	"Answer the width my color bars take on my right side, with the space before each one. They must be measured."

	colorBars ifEmpty: [ ^ 0 ].
	^ colorBars inject: 4 into: [ :sum :each | sum + 12 + each measuredExtent x ]
]

{ #category : 'layout' }
BpChart >> computePlotBoundsIn: anExtent [
	"Compute the bounds of my plot area in anExtent, leaving room for the tick labels on the left and at the bottom, for my title at the top and for my color bars on the right. My tick labels, title and color bars must be measured."

	| leftTicks bottomTicks left bottom top right |
	leftTicks := ticks select: [ :each | each axis = #y ].
	bottomTicks := ticks select: [ :each | each axis = #x ].
	left := (leftTicks inject: 0 into: [ :max :each | max max: each label measuredExtent x ]) + 10.
	bottom := (bottomTicks inject: 0 into: [ :max :each | max max: each label measuredExtent y ]) + 10.
	top := self title isEmpty
		       ifTrue: [ 10 ]
		       ifFalse: [ titleElement measuredExtent y + 10 ].
	right := bottomTicks ifEmpty: [ 12 ] ifNotEmpty: [ bottomTicks last label measuredExtent x / 2 + 4 max: 12 ].
	right := right max: self colorBarsWidth.
	self plotBounds: (left @ top corner: (anExtent x - right max: left + 1) @ (anExtent y - bottom max: top + 1))
]

{ #category : 'accessing' }
BpChart >> dataTransform [
	"Answer the transform from data coordinates to the pixels of my plot area."

	^ transform
]

{ #category : 'private - building' }
BpChart >> dataValuesOn: anAxis [
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
BpChart >> defaultLabelsFor: aCollectionOfLocations on: anAxis [

	^ (self scaleOf: anAxis) = #log
		  ifTrue: [ BpTickLocator logLabelsFor: aCollectionOfLocations ]
		  ifFalse: [ BpTickLocator labelsFor: aCollectionOfLocations ]
]

{ #category : 'private - building' }
BpChart >> giveColorsTo: anArtist [

	anArtist defaultColors: (self nextColors: anArtist colorCount)
]

{ #category : 'plotting' }
BpChart >> grid: aBoolean [
	"Show or hide lines across the plot area at each tick."

	showGrid := aBoolean.
	self rebuild
]

{ #category : 'initialization' }
BpChart >> initialize [

	super initialize.
	self initializeSettings.
	transform := self newTransform.
	plotArea := BpPlotArea new
		            dataTransform: transform;
		            yourself.
	titleElement := BpText new.
	self
		layout: BpChartLayout new;
		background: Color white;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChildren: {
			plotArea.
			titleElement }.
	self rebuild
]

{ #category : 'initialization' }
BpChart >> initializeSettings [
	"Give my settings their default values, before my parts are created."

	artists := OrderedCollection new.
	colorBars := OrderedCollection new.
	ticks := #(  ).
	showLegend := false.
	showGrid := false.
	xScale := #linear.
	yScale := #linear.
	xTickCount := 6.
	yTickCount := 8.
	palette := BpPalette default.
	colorIndex := 0.
	plotBounds := 0 @ 0 corner: 1 @ 1
]

{ #category : 'layout' }
BpChart >> layoutColorBarsContext: aBlElementBoundsUpdater [
	"Place my color bars along my right side."

	| left |
	left := self measuredExtent x - self colorBarsWidth.
	colorBars do: [ :each |
		left := left + 12.
		each applyLayoutIn: (left @ plotBounds top extent: each measuredExtent) context: aBlElementBoundsUpdater.
		left := left + each measuredExtent x ]
]

{ #category : 'layout' }
BpChart >> layoutLegendContext: aBlElementBoundsUpdater [
	"Place my legend. Nothing to do: my plot area places it."

	
]

{ #category : 'plotting' }
BpChart >> legend [
	"Show a legend with the label of each dataset that has one."

	showLegend := true.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> legendElement [

	^ plotArea legend
]

{ #category : 'private - building' }
BpChart >> limitsFrom: aLow to: aHigh on: anAxis [
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
BpChart >> limitsOn: anAxis [

	^ anAxis = #x
		  ifTrue: [ transform xLimits ]
		  ifFalse: [ transform yLimits ]
]

{ #category : 'private - building' }
BpChart >> logLimitsOf: aCollectionOfPositiveValues [
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
BpChart >> managedTicksOn: anAxis [
	"Answer the ticks an artist places on anAxis, unless ticks were fixed with xTicks: or yTicks:."

	(anAxis = #x
		 ifTrue: [ xTicks ]
		 ifFalse: [ yTicks ]) ifNotNil: [ ^ nil ].
	artists do: [ :each | (each managedTicksOn: anAxis) ifNotNil: [ :managed | ^ managed ] ].
	^ nil
]

{ #category : 'layout' }
BpChart >> measureColorBars [
	"Give my color bars the height of my plot area."

	colorBars do: [ :each | each measure: (BlExtentMeasurementSpec exact: each measuredExtent x @ plotBounds height) ]
]

{ #category : 'private - building' }
BpChart >> newGridLineFor: aTick [

	^ BpGridLine axis: aTick axis location: aTick location
]

{ #category : 'private - building' }
BpChart >> newGridLines [
	"Answer a line for each of my ticks when my grid is shown."

	^ showGrid
		  ifTrue: [ ticks collect: [ :each | self newGridLineFor: each ] ]
		  ifFalse: [ #(  ) ]
]

{ #category : 'private - building' }
BpChart >> newLegend [

	| entries |
	showLegend ifFalse: [ ^ nil ].
	entries := artists flatCollect: [ :each | each legendEntries ].
	entries ifEmpty: [ ^ nil ].
	^ BpLegend entries: entries
]

{ #category : 'private - building' }
BpChart >> newTickOn: anAxis location: aNumber text: aString [

	^ BpTick axis: anAxis location: aNumber text: aString
]

{ #category : 'private - building' }
BpChart >> newTicksOn: anAxis [
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
	^ locations asArray with: labels asArray collect: [ :location :text | self newTickOn: anAxis location: location text: text ]
]

{ #category : 'private - building' }
BpChart >> newTransform [

	^ BpDataTransform new
]

{ #category : 'plotting' }
BpChart >> nextColors: anInteger [
	"Answer the next anInteger colors of my palette."

	| colors |
	colors := (1 to: anInteger) collect: [ :index | palette colorAt: colorIndex + index ].
	colorIndex := colorIndex + anInteger.
	^ colors
]

{ #category : 'accessing' }
BpChart >> palette [

	^ palette
]

{ #category : 'accessing' }
BpChart >> palette: anEnumeratedPalette [
	"Take the colors of my artists from anEnumeratedPalette: the artists I already show are recolored, in the order they were added."

	palette := anEnumeratedPalette.
	colorIndex := 0.
	artists do: [ :each | self giveColorsTo: each ]
]

{ #category : 'accessing' }
BpChart >> patches [

	^ artists flatCollect: [ :each | each allPatches ]
]

{ #category : 'accessing' }
BpChart >> plotArea [

	^ plotArea
]

{ #category : 'accessing' }
BpChart >> plotBounds [
	"Answer the bounds of my plot area, as computed by my layout."

	^ plotBounds
]

{ #category : 'accessing' }
BpChart >> plotBounds: aRectangle [

	plotBounds := aRectangle.
	transform extent: (aRectangle extent max: 1 @ 1)
]

{ #category : 'private - building' }
BpChart >> rebuild [
	"Recompute my scales and limits from my artists, then show their patches, my legend, my ticks, my grid and my color bars."

	| patches |
	self updateScales.
	transform
		xScale: xScale;
		yScale: yScale;
		xLimits: (xLimits ifNil: [ self automaticLimitsOn: #x ]);
		yLimits: (yLimits ifNil: [ self automaticLimitsOn: #y ]).
	patches := self patches.
	patches do: [ :each | transform preparePatch: each ].
	plotArea patches: patches.
	self showLegend: self newLegend.
	self rebuildTicks.
	plotArea gridLines: self newGridLines.
	colorBars do: [ :each | each refresh ]
]

{ #category : 'private - building' }
BpChart >> rebuildTicks [
	"Replace my ticks by the ones of my current limits and scales."

	ticks do: [ :each | self removeChildren: each elements ].
	ticks := (self newTicksOn: #x) , (self newTicksOn: #y).
	ticks do: [ :each | self addChildren: each elements ]
]

{ #category : 'private - building' }
BpChart >> scaleOf: anAxis [

	^ anAxis = #x
		  ifTrue: [ xScale ]
		  ifFalse: [ yScale ]
]

{ #category : 'private - building' }
BpChart >> showLegend: aLegendOrNil [
	"Show aLegendOrNil instead of my current legend, in my plot area."

	plotArea legend: aLegendOrNil
]

{ #category : 'private - building' }
BpChart >> tickCountOn: anAxis [

	^ anAxis = #x
		  ifTrue: [ xTickCount ]
		  ifFalse: [ yTickCount ]
]

{ #category : 'private - building' }
BpChart >> tickLocationsOn: anAxis [

	| fixed limits |
	fixed := anAxis = #x
		         ifTrue: [ xTicks ]
		         ifFalse: [ yTicks ].
	fixed ifNotNil: [ ^ fixed ].
	limits := self limitsOn: anAxis.
	^ (self scaleOf: anAxis) = #log
		  ifTrue: [ BpTickLocator logTicksFrom: limits min to: limits max ]
		  ifFalse: [ BpTickLocator linearTicksFrom: limits min to: limits max count: (self tickCountOn: anAxis) ]
]

{ #category : 'accessing' }
BpChart >> ticks [

	^ ticks
]

{ #category : 'accessing' }
BpChart >> title [

	^ titleElement text asString
]

{ #category : 'accessing' }
BpChart >> title: aString [
	"Set the title shown above my plot area; a line break gives a title on several lines."

	titleElement text: (aString asRopedText fontSize: 14)
]

{ #category : 'layout' }
BpChart >> titleBottom [
	"Answer the y below my title, above my plot area."

	^ plotBounds top - 6
]

{ #category : 'accessing' }
BpChart >> titleElement [

	^ titleElement
]

{ #category : 'private - building' }
BpChart >> updateScales [
	"Put on a log scale the axes my artists ask for, such as the value axis of a histogram with log: true."

	artists do: [ :each |
		each logAxes do: [ :axis |
			axis = #x
				ifTrue: [ xScale := #log ]
				ifFalse: [ yScale := #log ] ] ]
]

{ #category : 'accessing' }
BpChart >> xLimits [
	"Answer the data values shown at the left and right of my plot area."

	^ transform xLimits
]

{ #category : 'accessing' }
BpChart >> xLimits: aCollectionOrNil [
	"Set the left and right data values; nil computes them from the data."

	xLimits := aCollectionOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> xScale [

	^ xScale
]

{ #category : 'accessing' }
BpChart >> xScale: aSymbol [
	"Set #linear or #log."

	xScale := aSymbol.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> xTickCount [

	^ xTickCount
]

{ #category : 'accessing' }
BpChart >> xTickCount: anInteger [
	"Set the largest number of intervals between x ticks."

	xTickCount := anInteger.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> xTickFormatter: aBlockOrNil [
	"Set a block answering the label of an x tick from its value; nil prints the values."

	xTickFormatter := aBlockOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> xTicks: aCollectionOfNumbers [
	"Put the ticks of the x axis at aCollectionOfNumbers instead of choosing them; nil chooses them again."

	xTicks := aCollectionOfNumbers ifNotNil: [ aCollectionOfNumbers asArray ].
	self rebuild
]

{ #category : 'accessing' }
BpChart >> yLimits [

	^ transform yLimits
]

{ #category : 'accessing' }
BpChart >> yLimits: aCollectionOrNil [
	"Set the bottom and top data values; nil computes them from the data."

	yLimits := aCollectionOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> yScale [

	^ yScale
]

{ #category : 'accessing' }
BpChart >> yScale: aSymbol [
	"Set #linear or #log."

	yScale := aSymbol.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> yTickCount [

	^ yTickCount
]

{ #category : 'accessing' }
BpChart >> yTickCount: anInteger [
	"Set the largest number of intervals between y ticks."

	yTickCount := anInteger.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> yTickFormatter: aBlockOrNil [
	"Set a block answering the label of a y tick from its value; nil prints the values."

	yTickFormatter := aBlockOrNil.
	self rebuild
]

{ #category : 'accessing' }
BpChart >> yTicks: aCollectionOfNumbers [
	"Put the ticks of the y axis at aCollectionOfNumbers instead of choosing them; nil chooses them again."

	yTicks := aCollectionOfNumbers ifNotNil: [ aCollectionOfNumbers asArray ].
	self rebuild
]
