"
I am a figure: a grid of `BpAxes`. Plots are added to the axes answered by `axesAtRow:column:`, `show:` opens me, and `saveAsSVG:`, `saveAsPDF:` and `saveAsPNG:` save me.

## Examples

```
BpFigure exampleTwoByTwo.
BpFigure exampleHistTypes.
BpFigure exampleMultiHist.
BpFigure exampleOptions.
BpFigure exampleInteraction.
BpFigure exampleScatter.
BpFigure examplePlot.
BpFigure exampleBar.
BpFigure exampleStem.
BpFigure exampleFillBetween.
BpFigure exampleStackPlot.
BpFigure exampleStairs.
BpFigure exampleViolinPlot.
BpFigure exampleErrorBar.
BpFigure exampleBoxPlot
```

More figures of the gallery are shown by the scripts of `BpHistogram`, `BpScatterPlot`, `BpLine`, `BpBoxPlot`, `BpBarPlot`, `BpStemPlot`, `BpFillBetween`, `BpStackPlot`, `BpStairs`, `BpViolinPlot` and `BpErrorBar`.

## Design Rationale

- Rows and columns are counted from 1, as Pharo collections: `axesAtRow: 1 column: 1` is the top left axes.
- My default extent is 640 by 480, so that the figures of the gallery keep their proportions. `figureExtent` answers the size asked with `extent:`: `show:` sizes its space with it, since `extent` is only known once I am laid out.

- Each format has its own message, so the format never depends on the name of the file. SVG and PDF are vector graphics; `saveAsPNG:dpi:` sets the resolution of a PNG, 100 dots per inch giving my extent in pixels.

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
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'rows',
		'columns',
		'axes'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'private - demo' }
BpFigure class >> addHistogramOptionsFirstRowTo: aFigure data: aCollection [
	"Add the cumulative, horizontal and log scale histograms of aCollection to the first row of aFigure."

	((aFigure axesAtRow: 1 column: 1) hist: aCollection)
		bins: 30;
		density: true;
		cumulative: true;
		histType: #step.
	((aFigure axesAtRow: 1 column: 1) hist: aCollection)
		bins: 30;
		density: true;
		cumulative: -1;
		histType: #step.
	(aFigure axesAtRow: 1 column: 1) title: 'cumulative: true and -1'.
	((aFigure axesAtRow: 1 column: 2) hist: aCollection)
		bins: 15;
		orientation: #horizontal;
		relativeWidth: 0.9.
	(aFigure axesAtRow: 1 column: 2) title: 'orientation: #horizontal'.
	((aFigure axesAtRow: 1 column: 3) hist: aCollection)
		bins: 30;
		log: true.
	(aFigure axesAtRow: 1 column: 3) title: 'log: true'
]

{ #category : 'private - demo' }
BpFigure class >> addHistogramOptionsSecondRowTo: aFigure data: aCollection [
	"Add the left aligned, bin strategy and weighted histograms of aCollection to the second row of aFigure."

	((aFigure axesAtRow: 2 column: 1) hist: aCollection)
		bins: #( -3 -2 -1 0 1 2 3 );
		align: #left;
		relativeWidth: 0.5;
		bottom: 50.
	(aFigure axesAtRow: 2 column: 1) title: 'align: #left, bottom: 50'.
	((aFigure axesAtRow: 2 column: 2) hist: aCollection)
		bins: #fd;
		histType: #stepfilled;
		edgeColor: Color black.
	(aFigure axesAtRow: 2 column: 2) title: 'bins: #fd'.
	((aFigure axesAtRow: 2 column: 3) hist: aCollection)
		bins: 20;
		range: #( 0 3 );
		weights: (aCollection collect: [ :each | 0.5 ]).
	(aFigure axesAtRow: 2 column: 3) title: 'range: #(0 3), weights: 0.5'
]

{ #category : 'examples' }
BpFigure class >> exampleBar [
	"Show the figure of the gallery bar color demo: one bar per category, with its own color and legend label (see `BpBarPlot`)."

	<example>
	^ self instanceBarColors show: 'bar'
]

{ #category : 'examples' }
BpFigure class >> exampleBoxPlot [
	"Show the six box plot variants of the gallery (see `BpBoxPlot`)."

	<example>
	^ self instanceBoxPlotDemo show: 'boxplot_demo'
]

{ #category : 'examples' }
BpFigure class >> exampleErrorBar [
	"Show the figure of the gallery error bar limits: upper and lower limits on all or some points (see `BpErrorBar`)."

	<example>
	^ self instanceErrorBarLimits show: 'errorbar'
]

{ #category : 'examples' }
BpFigure class >> exampleFillBetween [
	"Show the figure of the gallery fill_between demo: the area between a curve and 0, a curve and 1, and two curves (see `BpFillBetween`)."

	<example>
	^ self instanceFillBetweenDemo show: 'fill_between'
]

{ #category : 'examples' }
BpFigure class >> exampleHistTypes [
	"Show a figure of four axes, each with a different kind of histogram (the gallery histogram_histtypes)."

	<example>
	^ self instanceHistTypes show: 'histogram_histtypes'
]

{ #category : 'examples' }
BpFigure class >> exampleInteraction [
	"Show a figure of one axes whose histogram reacts to the mouse: hover a bar to highlight it, click it to see its bin and count."

	<example>
	^ self instanceInteractiveHistogram show: 'Histogram interaction'
]

{ #category : 'examples' }
BpFigure class >> exampleMultiHist [
	"Show a figure of four axes with several datasets per histogram (the gallery histogram_multihist)."

	<example>
	^ self instanceMultiHist show: 'histogram_multihist'
]

{ #category : 'examples' }
BpFigure class >> exampleOptions [
	"Show a figure of two rows of three axes, larger than the default one (extent: 900 @ 520), each with a histogram option."

	<example>
	^ self instanceHistogramOptions show: 'hist options'
]

{ #category : 'examples' }
BpFigure class >> examplePlot [
	"Show the figure of the plot type page: lines and markers drawn with format strings (see `BpLine`)."

	<example>
	^ self instanceLinePlotType show: 'plot'
]

{ #category : 'examples' }
BpFigure class >> exampleScatter [
	"Show a figure of one axes with a scatter of random points of random sizes and colors (the gallery scatter)."

	<example>
	^ self instanceScatter show: 'scatter'
]

{ #category : 'examples' }
BpFigure class >> exampleStackPlot [
	"Show the figure of the gallery stackplot demo: the world population stacked by continent (see `BpStackPlot`)."

	<example>
	^ self instanceStackPlotWorldPopulation show: 'stackplot'
]

{ #category : 'examples' }
BpFigure class >> exampleStairs [
	"Show the figure of the gallery stairs demo: step histograms, filled and horizontal steps (see `BpStairs`)."

	<example>
	^ self instanceStairsDemo show: 'stairs'
]

{ #category : 'examples' }
BpFigure class >> exampleStem [
	"Show the figure of the gallery stem plot: exp(sin(x)) drawn as stems (see `BpStemPlot`)."

	<example>
	^ self instanceStemPlot show: 'stem'
]

{ #category : 'examples' }
BpFigure class >> exampleTwoByTwo [
	"Show an empty figure of two rows of two axes."

	<example>
	^ self instanceTwoByTwo show: 'Figure 2 x 2'
]

{ #category : 'examples' }
BpFigure class >> exampleViolinPlot [
	"Show the figure of the gallery violin plot basics: points, widths, means, medians, bandwidths and quantiles (see `BpViolinPlot`)."

	<example>
	^ self instanceViolinPlotBasics show: 'violinplot'
]

{ #category : 'instances - artists' }
BpFigure class >> instanceAllMarkers [
	"Every marker symbol, tuple and TeX shape known, one per column."

	<sampleInstance>
	| specifications figure axes |
	specifications := #( 'o' '.' 's' '^' 'v' '<' '>' 'D' 'd' 'p' 'h' 'H' '8' '*' 'P' 'X' '+' 'x' '|' '_' #( 6 1 0 ) #( 6 2 0 )
	                     '$\clubsuit$' '$\spadesuit$' '$\heartsuit$' '$\diamondsuit$' ).
	figure := self new.
	figure extent: 1000 @ 220.
	axes := figure axes first.
	specifications withIndexDo: [ :each :index |
		(axes scatterX: { index } y: #( 0 ))
			s: 200;
			c: 'k';
			marker: each ].
	axes
		title: 'Markers: o . s ^ v < > D d p h H 8 * P X + x | _ (6,1) (6,2) and the TeX card suits';
		yTickCount: 1.
	^ figure
]

{ #category : 'instances - artists' }
BpFigure class >> instanceArtistsInOneAxes [
	"Two kinds of artists in the same axes: a histogram of normal samples and, above it, a scatter plot of their counts; each takes the next color of the cycle and the axes scale to cover both."

	<sampleInstance>
	| random samples axes figure histogram |
	random := Random seed: 19680801.
	samples := (1 to: 500) collect: [ :each | random nextNormal ].
	figure := self new.
	axes := figure axes first.
	histogram := (axes hist: samples)
		             bins: 15;
		             yourself.
	(axes
		 scatterX: ((1 to: 15) collect: [ :index | (histogram binEdges at: index) + (histogram binEdges at: index + 1) / 2 ])
		 y: histogram counts)
		marker: 'D';
		s: 50;
		label: 'counts'.
	axes
		title: 'BpHistogram and BpScatterPlot';
		legend;
		grid: true.
	^ figure
]

{ #category : 'instances - bar plot' }
BpFigure class >> instanceBarColors [
	"Gallery: Bar color demo (bar_colors): categories, one color and one label per bar; the underscore hides the second red label from the legend."

	<sampleInstance>
	| figure axes |
	figure := self new.
	axes := figure axes first.
	(axes barX: #( 'apple' 'blueberry' 'cherry' 'orange' ) height: #( 40 100 30 55 ))
		label: #( 'red' 'blue' '_red' 'orange' );
		color: #( 'tab:red' 'tab:blue' 'tab:red' 'tab:orange' ).
	axes
		title: 'Fruit supply by kind and color';
		legend.
	^ figure
]

{ #category : 'instances - bar plot' }
BpFigure class >> instanceBarPlotGrouped [
	"Gallery: Grouped bar chart with labels (barchart), without the bar labels: three bar plots shifted by their width; the middle one labels the ticks with the species."

	<sampleInstance>
	| species means figure axes width |
	species := #( 'Adelie' 'Chinstrap' 'Gentoo' ).
	means := {
		         ('Bill Depth' -> #( 18.35 18.43 14.98 )).
		         ('Bill Length' -> #( 38.79 48.83 47.50 )).
		         ('Flipper Length' -> #( 189.95 195.82 217.19 )) }.
	figure := self new.
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

{ #category : 'instances - bar plot' }
BpFigure class >> instanceBarPlotHorizontal [
	"Gallery: Horizontal bar chart (barh), without the error bars: the names label the ticks of the y axis, from top to bottom."

	<sampleInstance>
	| random people figure axes |
	random := Random seed: 19680801.
	people := #( 'Tom' 'Dick' 'Harry' 'Slim' 'Jim' ).
	figure := self new.
	axes := figure axes first.
	(axes barhY: #( 4 3 2 1 0 ) width: (people collect: [ :each | 3 + (10 * random next) ])) tickLabel: people.
	axes title: 'How fast do you want to go today?'.
	^ figure
]

{ #category : 'instances - bar plot' }
BpFigure class >> instanceBarPlotStacked [
	"Gallery: Stacked bar chart (bar_stacked): each bar plot starts on the tops of the previous one (bottom:)."

	<sampleInstance>
	| species weightCounts figure axes bottom |
	species := #( 'Adelie' 'Chinstrap' 'Gentoo' ).
	weightCounts := {
		                ('Below' -> #( 70 31 58 )).
		                ('Above' -> #( 82 37 66 )) }.
	figure := self new.
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

{ #category : 'instances - bar plot' }
BpFigure class >> instanceBarPlotType [
	"Plot types: bar(x, height), eight bars one unit wide outlined in white."

	<sampleInstance>
	| figure axes |
	figure := self new.
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

{ #category : 'instances - box plot' }
BpFigure class >> instanceBoxPlotDemo [
	"Gallery: Boxplots (boxplot_demo), first figure: the same data drawn as a basic, a notched, a horizontal box plot, with other flier symbols, without fliers and with shorter whiskers."

	<sampleInstance>
	| random data figure settings |
	random := Random seed: 19680801.
	data := ((1 to: 50) collect: [ :each | random next * 100 ]) , (Array new: 25 withAll: 50)
	        , ((1 to: 10) collect: [ :each | random next * 100 + 100 ]) , ((1 to: 10) collect: [ :each | random next * -100 ]).
	figure := self rows: 2 columns: 3.
	settings := {
		            ('basic plot' -> [ :box |  ]).
		            ('notched plot' -> [ :box | box notch: true ]).
		            ((String cr join: #( 'change outlier' 'point symbols' )) -> [ :box | box flierSymbol: 'gD' ]).
		            ((String cr join: #( 'don''t show' 'outlier points' )) -> [ :box | box flierSymbol: '' ]).
		            ('horizontal boxes' -> [ :box |
			             box
				             flierSymbol: 'rs';
				             orientation: #horizontal ]).
		            ('change whisker length' -> [ :box |
			             box
				             flierSymbol: 'rs';
				             orientation: #horizontal;
				             whiskers: 0.75 ]) }.
	settings withIndexDo: [ :each :index |
		| axes |
		axes := figure axesAtRow: index - 1 // 3 + 1 column: index - 1 \\ 3 + 1.
		each value value: (axes boxPlot: data).
		axes title: each key ].
	^ figure
]

{ #category : 'instances - box plot' }
BpFigure class >> instanceBoxPlotType [
	"Plot types: boxplot(X), three filled boxes at 2, 4 and 6 without fliers, with white medians and edges."

	<sampleInstance>
	| random columns figure axes |
	random := Random seed: 10.
	columns := #( #( 3 1.25 ) #( 5 1 ) #( 4 1.25 ) ) collect: [ :meanAndDeviation |
		           (1 to: 100) collect: [ :each | random nextNormalMean: meanAndDeviation first deviation: meanAndDeviation last ] ].
	figure := self new.
	axes := figure axes first.
	(axes boxPlot: columns)
		positions: #( 2 4 6 );
		widths: 1.5;
		patchArtist: true;
		showFliers: false;
		medianProperties: {
			(#color -> 'white').
			(#lineWidth -> 0.5) } asDictionary;
		boxProperties: {
			(#faceColor -> 'C0').
			(#edgeColor -> 'white').
			(#lineWidth -> 0.5) } asDictionary;
		whiskerProperties: {
			(#color -> 'C0').
			(#lineWidth -> 1.5) } asDictionary;
		capProperties: {
			(#color -> 'C0').
			(#lineWidth -> 1.5) } asDictionary.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceErrorBarFeatures [
	"Gallery: Different ways of specifying error bars (errorbar_features): symmetric errors varying with x, then asymmetric x errors on a log scale."

	<sampleInstance>
	| figure x y error symmetric asymmetric |
	figure := self rows: 2 columns: 1.
	figure extent: 640 @ 640.
	x := BpErrorBar arangeFrom: 0.1 to: 4 by: 0.5.
	y := x collect: [ :each | each negated exp ].
	error := x collect: [ :each | 0.2 * each + 0.1 ].
	symmetric := figure axesAtRow: 1 column: 1.
	(symmetric errorBarX: x y: y yErr: error) format: '-o'.
	symmetric title: 'variable, symmetric error'.
	asymmetric := figure axesAtRow: 2 column: 1.
	(asymmetric
		 errorBarX: x
		 y: y
		 xErr: {
			 (error collect: [ :each | each * 0.4 ]).
			 error }
		 yErr: nil) format: 'o'.
	asymmetric
		title: 'variable, asymmetric error';
		yScale: #log.
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceErrorBarFunction [
	"Gallery: Errorbar function (errorbar), the same error on every point: 0.2 in x and 0.4 in y."

	<sampleInstance>
	| figure axes x |
	figure := self new.
	axes := figure axes first.
	x := BpErrorBar arangeFrom: 0.1 to: 4 by: 0.5.
	axes
		errorBarX: x
		y: (x collect: [ :each | each negated exp ])
		xErr: 0.2
		yErr: 0.4.
	axes title: 'Simplest errorbars, 0.2 in x, 0.4 in y'.
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceErrorBarLimits [
	"Gallery: Including upper and lower limits in error bars (errorbar_limits_simple), first figure: limits on all points, on both sides, or on some points only."

	<sampleInstance>
	| figure |
	figure := self new.
	BpErrorBar addLimitSeriesTo: figure axes first.
	figure axes first legend.
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceErrorBarPlotType [
	"Plot types: errorbar(x, y, yerr, xerr), three circles with 2 point wide error bars and caps, with fixed limits and ticks."

	<sampleInstance>
	| figure axes |
	figure := self new.
	axes := figure axes first.
	(axes errorBarX: #( 2 4 6 ) y: #( 3.6 5 4.2 ) yErr: #( 0.9 1.2 0.5 ))
		format: 'o';
		lineWidth: 2;
		capSize: 6.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7).
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceErrorBarSubsample [
	"Gallery: Errorbar subsampling (errorbar_subsample): all error bars, one in six, then the second series shifted by three points."

	<sampleInstance>
	| figure |
	figure := self rows: 1 columns: 3.
	figure extent: 1000 @ 360.
	1 to: 3 do: [ :column | BpErrorBar subsampleIn: (figure axesAtRow: 1 column: column) column: column ].
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceFillBetweenConfidenceBand [
	"Gallery: Fill the area between two lines (fill_between_demo), confidence bands: a linear fit of the data and its confidence band, half transparent."

	<sampleInstance>
	| x y band figure axes |
	x := BpFillBetween linspaceFrom: 0 to: 10 count: 11.
	y := #( 3.9 4.4 10.8 10.3 11.2 13.1 14.1 9.9 13.9 15.1 12.5 ).
	band := BpFillBetween confidenceBandOf: x and: y.
	figure := self new.
	axes := figure axes first.
	axes plotX: x y: (band first with: band last collect: [ :low :high | low + high / 2 ]) format: '-'.
	(axes fillBetweenX: x y1: band first y2: band last) alpha: 0.2.
	(axes plotX: x y: y format: 'o') color: 'tab:brown'.
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceFillBetweenDemo [
	"Gallery: Fill the area between two lines (fill_between_demo), basic usage: between y1 and 0, y1 and 1, y1 and y2."

	<sampleInstance>
	| x y1 y2 figure |
	x := BpFillBetween arangeFrom: 0.0 to: 2 by: 0.01.
	y1 := x collect: [ :each | (2 * Float pi * each) sin ].
	y2 := x collect: [ :each | 0.8 * (4 * Float pi * each) sin ].
	figure := self rows: 3 columns: 1.
	figure extent: 600 @ 600.
	(figure axesAtRow: 1 column: 1) fillBetweenX: x y1: y1.
	(figure axesAtRow: 1 column: 1) title: 'fill between y1 and 0'.
	(figure axesAtRow: 2 column: 1) fillBetweenX: x y1: y1 y2: 1.
	(figure axesAtRow: 2 column: 1) title: 'fill between y1 and 1'.
	(figure axesAtRow: 3 column: 1) fillBetweenX: x y1: y1 y2: y2.
	(figure axesAtRow: 3 column: 1) title: 'fill between y1 and y2'.
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceFillBetweenPlotType [
	"Plot types: fill_between(x, y1, y2), a half transparent band between two noisy lines and the line in its middle."

	<sampleInstance>
	| random x y1 y2 figure axes |
	random := Random seed: 1.
	x := BpFillBetween linspaceFrom: 0 to: 8 count: 16.
	y1 := x collect: [ :each | 3 + (4 * each / 8) + (random next * 0.5) ].
	y2 := x collect: [ :each | 1 + (2 * each / 8) + (random next * 0.5) ].
	figure := self new.
	axes := figure axes first.
	(axes fillBetweenX: x y1: y1 y2: y2)
		alpha: 0.5;
		lineWidth: 0.
	(axes plotX: x y: (y1 with: y2 collect: [ :a :b | a + b / 2 ])) lineWidth: 2.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceFillBetweenSteps [
	"The three step styles of a fill (step: #pre, #post and #mid), with the data points marked."

	<sampleInstance>
	| x y figure |
	x := 1 to: 8.
	y := #( 2 4 3 6 5 7 4 6 ).
	figure := self rows: 1 columns: 3.
	figure extent: 900 @ 320.
	#( #pre #post #mid ) withIndexDo: [ :style :column |
		| axes |
		axes := figure axesAtRow: 1 column: column.
		(axes fillBetweenX: x y1: y)
			step: style;
			alpha: 0.4.
		axes plotX: x y: y format: 'o'.
		axes title: 'step: #' , style ].
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceFillBetweenX [
	"Gallery: Fill the area between two vertical lines (fill_betweenx_demo): between (x1, 0), (x1, 1) and (x1, x2) along y."

	<sampleInstance>
	| y x1 x2 figure |
	y := BpFillBetween arangeFrom: 0.0 to: 2 by: 0.01.
	x1 := y collect: [ :each | (2 * Float pi * each) sin ].
	x2 := y collect: [ :each | 1.2 * (4 * Float pi * each) sin ].
	figure := self rows: 1 columns: 3.
	figure extent: 600 @ 600.
	(figure axesAtRow: 1 column: 1) fillBetweenY: y x1: 0 x2: x1.
	(figure axesAtRow: 1 column: 1) title: 'between (x1, 0)'.
	(figure axesAtRow: 1 column: 2) fillBetweenY: y x1: x1 x2: 1.
	(figure axesAtRow: 1 column: 2) title: 'between (x1, 1)'.
	(figure axesAtRow: 1 column: 3) fillBetweenY: y x1: x1 x2: x2.
	(figure axesAtRow: 1 column: 3) title: 'between (x1, x2)'.
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceHistTypes [
	"Gallery: Demo of the histogram function's different histtype settings (histogram_histtypes)."

	<sampleInstance>
	| random x w figure bottomLeft |
	random := Random seed: 19680801.
	x := (1 to: 100) collect: [ :each | random nextNormalMean: 200 deviation: 25 ].
	w := (1 to: 100) collect: [ :each | random nextNormalMean: 200 deviation: 10 ].
	figure := self rows: 2 columns: 2.
	((figure axesAtRow: 1 column: 1) hist: x)
		bins: 20;
		density: true;
		histType: #stepfilled;
		faceColor: (BpColors named: 'g');
		alpha: 0.75.
	(figure axesAtRow: 1 column: 1) title: 'stepfilled'.
	((figure axesAtRow: 1 column: 2) hist: x)
		bins: 20;
		density: true;
		histType: #step;
		faceColor: (BpColors named: 'g');
		alpha: 0.75.
	(figure axesAtRow: 1 column: 2) title: 'step'.
	bottomLeft := figure axesAtRow: 2 column: 1.
	(bottomLeft hist: x)
		density: true;
		histType: #barstacked;
		relativeWidth: 0.8.
	(bottomLeft hist: w)
		density: true;
		histType: #barstacked;
		relativeWidth: 0.8.
	bottomLeft title: 'barstacked'.
	"Create a histogram by providing the bin edges (unequally spaced)."
	((figure axesAtRow: 2 column: 2) hist: x)
		bins: #( 100 150 180 195 205 220 250 300 );
		density: true;
		histType: #bar;
		relativeWidth: 0.8.
	(figure axesAtRow: 2 column: 2) title: 'bar, unequal bins'.
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceHistogramColorByHeight [
	"Gallery: Histograms (hist), second figure: bars colored by their height with viridis (normalized between the lowest and the highest bar), and a density with percent tick labels."

	<sampleInstance>
	| random dist1 figure histogram lowest highest |
	random := Random seed: 19680801.
	dist1 := (1 to: 100000) collect: [ :each | random nextNormal ].
	figure := self rows: 1 columns: 2.
	histogram := ((figure axesAtRow: 1 column: 1) hist: dist1)
		             bins: 20;
		             yourself.
	lowest := histogram counts min.
	highest := histogram counts max.
	histogram patches do: [ :each | each background: (BpColors viridis: each amount - lowest / (highest - lowest)) ].
	((figure axesAtRow: 1 column: 2) hist: dist1)
		bins: 20;
		density: true.
	(figure axesAtRow: 1 column: 2) yTickFormatter: [ :value | (value * 100) rounded printString , '%' ].
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceHistogramOptions [
	"The other options of `BpHistogram`: cumulative densities, horizontal bars, log scale, bars aligned on the left edges and starting at a bottom, and a bin strategy."

	<sampleInstance>
	| random x figure |
	random := Random seed: 19680801.
	x := (1 to: 1000) collect: [ :each | random nextNormal ].
	figure := self rows: 2 columns: 3.
	figure extent: 900 @ 520.
	self addHistogramOptionsFirstRowTo: figure data: x.
	self addHistogramOptionsSecondRowTo: figure data: x.
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceHistogramTwoDistributions [
	"Gallery: Histograms (hist), first figure: the number of bins set with bins."

	<sampleInstance>
	| random dist1 dist2 figure |
	random := Random seed: 19680801.
	dist1 := (1 to: 100000) collect: [ :each | random nextNormal ].
	dist2 := (1 to: 100000) collect: [ :each | random nextNormalMean: 5 deviation: 0.4 ].
	figure := self rows: 1 columns: 2.
	((figure axesAtRow: 1 column: 1) hist: dist1) bins: 20.
	((figure axesAtRow: 1 column: 2) hist: dist2) bins: 20.
	^ figure
]

{ #category : 'instances - bar plot' }
BpFigure class >> instanceInteractiveBars [
	"Bars with interaction handlers: hovering a bar highlights it, clicking it shows its category and height in the title."

	<sampleInstance>
	| figure axes bars |
	figure := self new.
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

{ #category : 'instances - box plot' }
BpFigure class >> instanceInteractiveBoxPlot [
	"Three filled boxes: hovering a part outlines it in red, clicking a part shows the statistics of its box in the title."

	<sampleInstance>
	| figure axes boxPlot names |
	names := #( 'A' 'B' 'C' ).
	figure := self new.
	axes := figure axes first.
	boxPlot := (axes boxPlot: (BpBoxPlot instanceThreeBoxes statistics collect: [ :each | each values ]))
		           patchArtist: true;
		           showMeans: true;
		           tickLabels: names;
		           yourself.
	axes title: 'Click a box'.
	boxPlot
		whenPatch: BlMouseEnterEvent do: [ :event :patch |
			patch userData at: #border put: patch border.
			patch border: (BlBorder paint: Color red width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :patch | patch userData at: #border ifPresent: [ :border | patch border: border ] ];
		whenPatch: BlClickEvent do: [ :event :patch |
			| stats |
			stats := boxPlot statistics at: patch dataset.
			axes title: ('{1}: median {2}, quartiles {3} and {4}, mean {5}' format: {
				 (names at: patch dataset).
				 (stats median printShowingDecimalPlaces: 2).
				 (stats q1 printShowingDecimalPlaces: 2).
				 (stats q3 printShowingDecimalPlaces: 2).
				 (stats mean printShowingDecimalPlaces: 2) }) ].
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceInteractiveErrorBars [
	"Measures with error bars: hovering a bar thickens it, clicking it shows the measure in the title."

	<sampleInstance>
	| figure axes measures errors errorBar |
	figure := self new.
	axes := figure axes first.
	axes title: 'Click an error bar'.
	measures := #( 2.1 3.4 3.0 4.6 5.2 ).
	errors := #( 0.3 0.5 0.4 0.6 0.3 ).
	errorBar := (axes errorBarX: (1 to: 5) y: measures yErr: errors)
		            format: 'o';
		            capSize: 5;
		            yourself.
	errorBar
		whenPatch: BlMouseEnterEvent
		do: [ :event :patch |
			(errorBar barPatches includes: patch) ifTrue: [ patch border: (BlBorder paint: patch border paint width: 5) ] ];
		whenPatch: BlMouseLeaveEvent
		do: [ :event :patch |
			(errorBar barPatches includes: patch) ifTrue: [ patch border: (BlBorder paint: patch border paint width: 2) ] ];
		whenPatch: BlClickEvent do: [ :event :patch |
			(errorBar barPatches includes: patch) ifTrue: [
				axes title: ('measure {1}: {2} ± {3}' format: {
					 patch dataset.
					 (measures at: patch dataset).
					 (errors at: patch dataset) }) ] ].
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceInteractiveFill [
	"A sine filled in C0 where it is positive and in C1 where it is negative, one polygon per hump: hovering a polygon outlines it, clicking it shows its x range in the title."

	<sampleInstance>
	| x y figure axes fills |
	x := BpFillBetween linspaceFrom: 0 to: 4 * Float pi count: 200.
	y := x collect: [ :each | each sin ].
	figure := self new.
	axes := figure axes first.
	axes title: 'Click a hump'.
	fills := {
		         ((axes fillBetweenX: x y1: y)
			          where: (y collect: [ :each | each >= 0 ]);
			          interpolate: true;
			          color: 'C0';
			          yourself).
		         ((axes fillBetweenX: x y1: y)
			          where: (y collect: [ :each | each <= 0 ]);
			          interpolate: true;
			          color: 'C1';
			          yourself) }.
	fills do: [ :fill |
		fill
			whenPatch: BlMouseEnterEvent do: [ :event :polygon | polygon border: (BlBorder paint: Color black width: 2) ];
			whenPatch: BlMouseLeaveEvent do: [ :event :polygon | fill paint: polygon ];
			whenPatch: BlClickEvent do: [ :event :polygon |
				axes title: ('from x = {1} to x = {2}' format: {
					 ((polygon dataVertices collect: [ :each | each x ]) min printShowingDecimalPlaces: 2).
					 ((polygon dataVertices collect: [ :each | each x ]) max printShowingDecimalPlaces: 2) }) ] ].
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceInteractiveHistogram [
	"A histogram with interaction handlers on its bars: hovering a bar highlights it, clicking it shows its bin and count in the title."

	<sampleInstance>
	| random figure axes histogram |
	random := Random seed: 19680801.
	figure := self new.
	axes := figure axes first.
	histogram := axes hist: ((1 to: 1000) collect: [ :each | random nextNormal ]).
	histogram
		bins: 20;
		edgeColor: Color white.
	axes title: 'Click a bar'.
	histogram
		whenPatch: BlMouseEnterEvent do: [ :event :bar | bar background: BpColors tab10 second ];
		whenPatch: BlMouseLeaveEvent do: [ :event :bar | bar background: BpColors tab10 first ];
		whenPatch: BlClickEvent do: [ :event :bar |
			axes title: ('[{1}, {2}): {3} values' format: {
				 ((histogram binEdges at: bar bin) printShowingDecimalPlaces: 2).
				 ((histogram binEdges at: bar bin + 1) printShowingDecimalPlaces: 2).
				 bar amount }) ].
	^ figure
]

{ #category : 'instances - scatter plot' }
BpFigure class >> instanceInteractiveScatter [
	"A scatter with interaction handlers on its markers: hovering a marker outlines it, clicking it shows its point and value in the title."

	<sampleInstance>
	| random figure axes scatter |
	random := Random seed: 19680801.
	figure := self new.
	axes := figure axes first.
	scatter := axes scatterX: ((1 to: 50) collect: [ :each | random next ]) y: ((1 to: 50) collect: [ :each | random next ]).
	scatter
		c: ((1 to: 50) collect: [ :each | random next ]);
		s: 150;
		edgeColors: 'none'.
	axes title: 'Click a point'.
	scatter
		whenPatch: BlMouseEnterEvent do: [ :event :point | point border: (BlBorder paint: Color black width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :point | point border: BlBorder empty ];
		whenPatch: BlClickEvent do: [ :event :point |
			axes title: ('point {1}: ({2}, {3}), c = {4}' format: {
				 point index.
				 (point dataPoint x printShowingDecimalPlaces: 2).
				 (point dataPoint y printShowingDecimalPlaces: 2).
				 (point amount printShowingDecimalPlaces: 2) }) ].
	^ figure
]

{ #category : 'instances - stack plot' }
BpFigure class >> instanceInteractiveStack [
	"The world population by continent: hovering a layer outlines it, clicking it shows its continent and its last value in the title."

	<sampleInstance>
	| figure axes stack |
	figure := self instanceStackPlotWorldPopulation.
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

{ #category : 'instances - stairs' }
BpFigure class >> instanceInteractiveStairs [
	"Three step curves: hovering one thickens it, clicking it shows its name in the title."

	<sampleInstance>
	| figure axes edges |
	figure := self new.
	axes := figure axes first.
	axes title: 'Click a step curve'.
	edges := 0 to: 12.
	{
		('sin' -> [ :each | (each / 2) sin ]).
		('cos' -> [ :each | (each / 2) cos ]).
		('half sin' -> [ :each | (each / 2) sin / 2 ]) } do: [ :each |
			| stairs |
			stairs := (axes stairs: ((0 to: 11) collect: [ :index | each value value: index + (1 / 2) ]) edges: edges)
				          baseline: nil;
				          label: each key;
				          yourself.
			stairs
				whenPatch: BlMouseEnterEvent do: [ :event :polygon | polygon border: (BlBorder paint: polygon border paint width: 4) ];
				whenPatch: BlMouseLeaveEvent do: [ :event :polygon | stairs paint: polygon ];
				whenPatch: BlClickEvent do: [ :event :polygon | axes title: ('clicked: {1}' format: { each key }) ] ].
	axes legend.
	^ figure
]

{ #category : 'instances - stem plot' }
BpFigure class >> instanceInteractiveStems [
	"Stems with interaction handlers: hovering a stem or a marker paints it red, clicking a marker shows its location and head in the title."

	<sampleInstance>
	| figure axes stems |
	figure := self new.
	axes := figure axes first.
	stems := axes stemLocations: (1 to: 10) heads: ((1 to: 10) collect: [ :each | (each / 2) sin * 5 ]).
	axes title: 'Click a marker'.
	stems
		whenPatch: BlMouseEnterEvent do: [ :event :patch |
			patch userData at: #border put: patch border.
			patch border: (BlBorder paint: Color red width: 3) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :patch | patch userData at: #border ifPresent: [ :border | patch border: border ] ];
		whenPatch: BlClickEvent do: [ :event :patch |
			(stems markerLine includes: patch) ifTrue: [
				axes title: ('stem {1}: head {2}' format: {
					 (stems locations at: patch index).
					 ((stems heads at: patch index) printShowingDecimalPlaces: 2) }) ] ].
	^ figure
]

{ #category : 'instances - violin plot' }
BpFigure class >> instanceInteractiveViolins [
	"Three violins: hovering one makes it opaque, clicking it shows its median in the title."

	<sampleInstance>
	| random figure axes violins isBody |
	random := Random seed: 3.
	figure := self new.
	axes := figure axes first.
	axes title: 'Click a violin'.
	violins := (axes violinPlot: ((1 to: 3) collect: [ :each |
		             BpViolinPlot
			             normalSamples: 200
			             mean: each
			             deviation: each / 2
			             random: random ]))
		           showMedians: true;
		           yourself.
	isBody := [ :patch | (violins parts at: #bodies) includes: patch ].
	violins
		whenPatch: BlMouseEnterEvent
		do: [ :event :patch | (isBody value: patch) ifTrue: [ patch background: (patch background paint color alpha: 0.8) ] ];
		whenPatch: BlMouseLeaveEvent
		do: [ :event :patch | (isBody value: patch) ifTrue: [ violins paintBody: patch dataset: patch dataset ] ];
		whenPatch: BlClickEvent do: [ :event :patch |
			axes title: ('violin {1}: median {2}' format: {
				 patch dataset.
				 ((violins statistics at: patch dataset) median printShowingDecimalPlaces: 2) }) ].
	^ figure
]

{ #category : 'instances - line' }
BpFigure class >> instanceLineFormats [
	"Three curves drawn with format strings ('r--', 'bs', 'g^') and a legend, as in the pyplot tutorial."

	<sampleInstance>
	| figure axes t |
	t := (0 to: 24) collect: [ :index | index / 5 ].
	figure := self new.
	axes := figure axes first.
	(axes plotX: t y: t format: 'r--') label: 'linear'.
	(axes plotX: t y: (t collect: [ :each | each squared ]) format: 'bs') label: 'quadratic'.
	(axes plotX: t y: (t collect: [ :each | each raisedTo: 3 ]) format: 'g^') label: 'cubic'.
	axes
		title: 'Format strings';
		legend.
	^ figure
]

{ #category : 'instances - line' }
BpFigure class >> instanceLinePlotType [
	"Plot types: plot(x, y), markers only, a line, and a line with markers, with fixed limits and ticks."

	<sampleInstance>
	| figure axes x y x2 y2 |
	x := (0 to: 99) collect: [ :index | index * 10 / 99.0 ].
	y := x collect: [ :each | 4 + (2 * each) sin ].
	x2 := (0 to: 24) collect: [ :index | index * 10 / 24.0 ].
	y2 := x2 collect: [ :each | 4 + (2 * each) sin ].
	figure := self new.
	axes := figure axes first.
	(axes plotX: x2 y: (y2 collect: [ :each | each + 2.5 ]) format: 'x') markerEdgeWidth: 2.
	(axes plotX: x y: y) lineWidth: 2.
	(axes plotX: x2 y: (y2 collect: [ :each | each - 2.5 ]) format: 'o-') lineWidth: 2.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceMultiHist [
	"Gallery: Plot multiple data sets as histograms (histogram_multihist), first figure."

	<sampleInstance>
	| random x colors xMulti figure |
	random := Random seed: 19680801.
	x := (1 to: 3) collect: [ :dataset | (1 to: 1000) collect: [ :each | random nextNormal ] ].
	figure := self rows: 2 columns: 2.
	colors := #( 'red' 'tan' 'lime' ).
	((figure axesAtRow: 1 column: 1) hist: x)
		bins: 10;
		density: true;
		histType: #bar;
		color: (colors collect: [ :each | BpColors named: each ]);
		label: colors.
	(figure axesAtRow: 1 column: 1)
		legend;
		title: 'bars with legend'.
	((figure axesAtRow: 1 column: 2) hist: x)
		bins: 10;
		density: true;
		histType: #bar;
		stacked: true.
	(figure axesAtRow: 1 column: 2) title: 'stacked bar'.
	((figure axesAtRow: 2 column: 1) hist: x)
		bins: 10;
		histType: #step;
		stacked: true;
		fill: false.
	(figure axesAtRow: 2 column: 1) title: 'stack step (unfilled)'.
	"Make a multiple-histogram of data-sets with different length."
	xMulti := #( 10000 5000 2000 ) collect: [ :size | (1 to: size) collect: [ :each | random nextNormal ] ].
	((figure axesAtRow: 2 column: 2) hist: xMulti)
		bins: 10;
		histType: #bar.
	(figure axesAtRow: 2 column: 2) title: 'different sample sizes'.
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceMultiHistStyles [
	"Gallery: Plot multiple data sets as histograms (histogram_multihist), one style setting per dataset: edge color, face color, line width and line style."

	<sampleInstance>
	| random x figure colors |
	random := Random seed: 19680801.
	x := (1 to: 3) collect: [ :dataset | (1 to: 1000) collect: [ :each | random nextNormal ] ].
	colors := #( 'green' 'red' 'blue' ) collect: [ :each | BpColors named: each ].
	figure := self rows: 2 columns: 2.
	((figure axesAtRow: 1 column: 1) hist: x)
		bins: 10;
		fill: false;
		histType: #step;
		stacked: true;
		edgeColor: colors;
		label: #( 'green' 'red' 'blue' ).
	(figure axesAtRow: 1 column: 1)
		legend;
		title: 'Stacked Steps with Edgecolors'.
	((figure axesAtRow: 1 column: 2) hist: x)
		bins: 10;
		histType: #barstacked;
		faceColor: colors;
		label: #( 'green' 'red' 'blue' ).
	(figure axesAtRow: 1 column: 2)
		legend;
		title: 'Bars with different Facecolors'.
	((figure axesAtRow: 2 column: 1) hist: x)
		bins: 10;
		fill: false;
		histType: #bar;
		lineWidth: #( 1 2 3 );
		edgeColor: colors;
		label: #( '1' '2' '3' ).
	(figure axesAtRow: 2 column: 1)
		legend;
		title: 'Bars with Linewidths'.
	((figure axesAtRow: 2 column: 2) hist: x)
		bins: 10;
		fill: false;
		histType: #bar;
		lineStyle: #( #solid #dotted #dashed );
		edgeColor: colors;
		label: #( '-' ':' '--' ).
	(figure axesAtRow: 2 column: 2)
		legend;
		title: 'Bars with Linestyles'.
	^ figure
]

{ #category : 'instances - scatter plot' }
BpFigure class >> instanceScatter [
	"Gallery: Scatter plot (scatter): random points with random sizes and colors."

	<sampleInstance>
	| random n x y colors area figure |
	random := Random seed: 19680801.
	n := 50.
	x := (1 to: n) collect: [ :each | random next ].
	y := (1 to: n) collect: [ :each | random next ].
	colors := (1 to: n) collect: [ :each | random next ].
	"0 to 15 point radii"
	area := (1 to: n) collect: [ :each | (30 * random next) squared ].
	figure := self new.
	(figure axes first scatterX: x y: y)
		s: area;
		c: colors;
		alpha: 0.5.
	^ figure
]

{ #category : 'instances - scatter plot' }
BpFigure class >> instanceScatterMarkers [
	"Gallery: Marker examples (scatter_star_poly): a marker symbol, a TeX symbol, a path, a pentagon, a star and an asterisk."

	<sampleInstance>
	| random x y z figure |
	random := Random seed: 19680801.
	x := (1 to: 10) collect: [ :each | random next ].
	y := (1 to: 10) collect: [ :each | random next ].
	z := x with: y collect: [ :eachX :eachY | (eachX squared + eachY squared) sqrt ].
	figure := self rows: 2 columns: 3.
	{
		('>' -> 'marker=''>''').
		('$\clubsuit$' -> 'marker=''$\clubsuit$''').
		(#( #( -1 -1 ) #( 1 -1 ) #( 1 1 ) #( -1 -1 ) ) -> 'marker=verts').
		(#( 5 0 ) -> 'marker=(5, 0)').
		(#( 5 1 ) -> 'marker=(5, 1)').
		(#( 5 2 ) -> 'marker=(5, 2)') } withIndexDo: [ :each :index |
			| axes |
			axes := figure axes at: index.
			(axes scatterX: x y: y)
				s: 80;
				c: z;
				marker: each key.
			axes title: each value ].
	^ figure
]

{ #category : 'instances - scatter plot' }
BpFigure class >> instanceScatterWithLegend [
	"Gallery: Scatter plot with a legend (scatter_with_legend), first figure: one scatter per color, each with a label."

	<sampleInstance>
	| random figure axes |
	random := Random seed: 19680801.
	figure := self new.
	axes := figure axes first.
	#( 'tab:blue' 'tab:orange' 'tab:green' ) do: [ :color |
		| n x y scale |
		n := 750.
		x := (1 to: n) collect: [ :each | random next ].
		y := (1 to: n) collect: [ :each | random next ].
		scale := (1 to: n) collect: [ :each | 200.0 * random next ].
		(axes scatterX: x y: y)
			c: color;
			s: scale;
			label: color;
			alpha: 0.3;
			edgeColors: 'none' ].
	axes
		legend;
		grid: true.
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceSelectiveFill [
	"Gallery: Fill the area between two lines (fill_between_demo), selectively filling horizontal regions: where y1 > y2 in C0, where y1 < y2 in C1, without and with interpolation at the crossing."

	<sampleInstance>
	| x y1 y2 figure |
	x := #( 0 1 2 3 ).
	y1 := #( 0.8 0.8 0.2 0.2 ).
	y2 := #( 0 0 1 1 ).
	figure := self rows: 2 columns: 1.
	#( false true ) withIndexDo: [ :interpolation :row |
		| axes |
		axes := figure axesAtRow: row column: 1.
		axes title: 'interpolation=' , (interpolation
			 ifTrue: [ 'True' ]
			 ifFalse: [ 'False' ]).
		axes plotX: x y: y1 format: 'o--'.
		axes plotX: x y: y2 format: 'o--'.
		(axes fillBetweenX: x y1: y1 y2: y2)
			where: (y1 with: y2 collect: [ :a :b | a > b ]);
			color: 'C0';
			alpha: 0.3;
			interpolate: interpolation.
		(axes fillBetweenX: x y1: y1 y2: y2)
			where: (y1 with: y2 collect: [ :a :b | a < b ]);
			color: 'C1';
			alpha: 0.3;
			interpolate: interpolation ].
	^ figure
]

{ #category : 'instances - violin plot' }
BpFigure class >> instanceSplitViolins [
	"Two groups compared on each side of the same positions: the low halves on the left, the high halves on the right."

	<sampleInstance>
	| random figure axes |
	random := Random seed: 7.
	figure := self new.
	axes := figure axes first.
	(axes violinPlot: ((1 to: 4) collect: [ :each |
		  BpViolinPlot
			  normalSamples: 150
			  mean: each
			  deviation: 1
			  random: random ]))
		side: #low;
		showExtrema: false;
		showMedians: true;
		label: 'before'.
	(axes violinPlot: ((1 to: 4) collect: [ :each |
		  BpViolinPlot
			  normalSamples: 150
			  mean: each + 1
			  deviation: 0.6
			  random: random ]))
		side: #high;
		showExtrema: false;
		showMedians: true;
		label: 'after'.
	axes
		title: 'Split violins';
		legend.
	^ figure
]

{ #category : 'instances - stack plot' }
BpFigure class >> instanceStackPlotBaselines [
	"The same three layers stacked on each baseline: #zero, #sym, #wiggle and #weightedWiggle."

	<sampleInstance>
	| random x layers figure |
	random := Random seed: 19680801.
	x := BpStackPlot linspaceFrom: 0 to: 100 count: 101.
	layers := (1 to: 3) collect: [ :each | BpStackPlot gaussianMixtureOver: x random: random ].
	figure := self rows: 2 columns: 2.
	#( #zero #sym #wiggle #weightedWiggle ) withIndexDo: [ :each :index |
		| axes |
		axes := figure axes at: index.
		(axes stackPlotX: x ys: layers) baseline: each.
		axes title: 'baseline: #' , each ].
	^ figure
]

{ #category : 'instances - stack plot' }
BpFigure class >> instanceStackPlotStreamGraph [
	"Gallery: Stackplots and streamgraphs (stackplot_demo), second figure: three random mixtures of gaussians stacked on the #wiggle baseline."

	<sampleInstance>
	| random x figure |
	random := Random seed: 19680801.
	x := BpStackPlot linspaceFrom: 0 to: 100 count: 101.
	figure := self new.
	(figure axes first stackPlotX: x ys: ((1 to: 3) collect: [ :each | BpStackPlot gaussianMixtureOver: x random: random ]))
		baseline: #wiggle.
	^ figure
]

{ #category : 'instances - stack plot' }
BpFigure class >> instanceStackPlotType [
	"Plot types: stackplot(x, y), three layers over x = 0, 2, 4, 6, 8 with fixed limits and ticks."

	<sampleInstance>
	| figure axes |
	figure := self new.
	axes := figure axes first.
	axes stackPlotX: (BpStackPlot arangeFrom: 0 to: 10 by: 2) ys: #( #( 1 1.25 2 2.75 3 ) #( 1 1 1 1 1 ) #( 2 1 2 1 2 ) ).
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'instances - stack plot' }
BpFigure class >> instanceStackPlotWorldPopulation [
	"Gallery: Stackplots and streamgraphs (stackplot_demo), first figure: the population of each continent from 1950 to 2018, in billions, one labeled layer per continent."

	<sampleInstance>
	| population figure axes |
	population := {
		              ('Africa' -> #( 0.228 0.284 0.365 0.477 0.631 0.814 1.044 1.275 )).
		              ('the Americas' -> #( 0.340 0.425 0.519 0.619 0.727 0.840 0.943 1.006 )).
		              ('Asia' -> #( 1.394 1.686 2.120 2.625 3.202 3.714 4.169 4.560 )).
		              ('Europe' -> #( 0.220 0.253 0.276 0.295 0.310 0.303 0.294 0.293 )).
		              ('Oceania' -> #( 0.012 0.015 0.019 0.022 0.026 0.031 0.036 0.039 )) }.
	figure := self new.
	axes := figure axes first.
	(axes stackPlotX: #( 1950 1960 1970 1980 1990 2000 2010 2018 ) ys: (population collect: [ :each | each value ]))
		label: (population collect: [ :each | each key ]);
		alpha: 0.8.
	axes
		legend;
		title: 'World population'.
	^ figure
]

{ #category : 'instances - stairs' }
BpFigure class >> instanceStairsDemo [
	"Gallery: Stairs Demo (stairs_demo), first figure: step histograms with a modified baseline or none, filled and horizontal steps, and stairs added to their axes as an artist."

	<sampleInstance>
	| figure artist |
	figure := self rows: 3 columns: 1.
	figure extent: 600 @ 900.
	BpStairs stepHistogramsIn: (figure axesAtRow: 1 column: 1).
	BpStairs filledStepsIn: (figure axesAtRow: 2 column: 1).
	artist := figure axesAtRow: 3 column: 1.
	artist addArtist: (BpStairs new
		 values: #( 1 2 3 2 1 ) edges: (1 to: 6);
		 label: 'Artist added to the axes';
		 yourself).
	artist
		xLimits: #( 0 7 );
		yLimits: #( -1 5 );
		title: 'BpStairs artist'.
	figure axes do: [ :each | each legend ].
	^ figure
]

{ #category : 'instances - stairs' }
BpFigure class >> instanceStairsPlotType [
	"Plot types: stairs(values), eight steps 2.5 points wide with fixed limits and ticks."

	<sampleInstance>
	| figure axes |
	figure := self new.
	axes := figure axes first.
	(axes stairs: #( 4.8 5.5 3.5 4.6 6.5 6.6 2.6 3.0 )) lineWidth: 2.5.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'instances - stem plot' }
BpFigure class >> instanceStemPlot [
	"Gallery: Stem plot (stem_plot), first figure: exp(sin(x)) at 41 locations between 0.1 and 2 pi."

	<sampleInstance>
	| figure |
	figure := self new.
	figure axes first
		stemLocations: BpStemPlot stemPlotLocations
		heads: (BpStemPlot stemPlotLocations collect: [ :each | each sin exp ]).
	^ figure
]

{ #category : 'instances - stem plot' }
BpFigure class >> instanceStemPlotStyled [
	"Gallery: Stem plot (stem_plot), second figure: grey stems, hollow diamonds and the baseline at 1.1."

	<sampleInstance>
	| figure |
	figure := self new.
	(figure axes first
		 stemLocations: BpStemPlot stemPlotLocations
		 heads: (BpStemPlot stemPlotLocations collect: [ :each | each sin exp ]))
		lineFormat: 'grey';
		markerFormat: 'D';
		bottom: 1.1;
		markerFaceColor: 'none'.
	^ figure
]

{ #category : 'instances - stem plot' }
BpFigure class >> instanceStemPlotType [
	"Plot types: stem(x, y), eight stems with fixed limits and ticks."

	<sampleInstance>
	| figure axes |
	figure := self new.
	axes := figure axes first.
	axes stemLocations: ((0 to: 7) collect: [ :each | each + 0.5 ]) heads: #( 4.8 5.5 3.5 4.6 6.5 6.6 2.6 3.0 ).
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'instances' }
BpFigure class >> instanceTwoByTwo [
	"Answer a figure of two rows of two axes, each with a title, ready to receive plots."

	<sampleInstance>
	| figure |
	figure := self rows: 2 columns: 2.
	figure axes withIndexDo: [ :axes :index | axes title: 'axes ' , index printString ].
	^ figure
]

{ #category : 'instances - violin plot' }
BpFigure class >> instanceViolinPlotBasics [
	"Gallery: Violin plot basics (violinplot), custom violins 1, 2 and 4, vertical then horizontal: fewer or more points, widths, means and medians, the Silverman bandwidth, a bandwidth factor and quantiles."

	<sampleInstance>
	| data figure |
	data := BpViolinPlot basicsData.
	figure := self rows: 2 columns: 3.
	figure extent: 1000 @ 600.
	#( 1 2 4 ) withIndexDo: [ :number :column |
		BpViolinPlot
			customViolinsIn: (figure axesAtRow: 1 column: column)
			data: data
			number: number
			horizontal: false.
		BpViolinPlot
			customViolinsIn: (figure axesAtRow: 2 column: column)
			data: data
			number: number
			horizontal: true ].
	^ figure
]

{ #category : 'instances - violin plot' }
BpFigure class >> instanceViolinPlotType [
	"Plot types: violinplot(D), three violins 2 wide at 2, 4 and 6, without lines, nearly opaque, with fixed limits and ticks."

	<sampleInstance>
	| random figure axes |
	random := Random seed: 10.
	figure := self new.
	axes := figure axes first.
	(axes
		 violinPlot: {
			 (BpViolinPlot
				  normalSamples: 200
				  mean: 3
				  deviation: 0.75
				  random: random).
			 (BpViolinPlot
				  normalSamples: 200
				  mean: 5
				  deviation: 1
				  random: random).
			 (BpViolinPlot
				  normalSamples: 200
				  mean: 4
				  deviation: 0.75
				  random: random) }
		 positions: #( 2 4 6 ))
		widths: 2;
		showExtrema: false;
		alpha: 0.9.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7).
	^ figure
]

{ #category : 'instance creation' }
BpFigure class >> rows: aRowCount columns: aColumnCount [
	"Answer a figure with a grid of axes."

	^ self new
		  rows: aRowCount columns: aColumnCount;
		  yourself
]

{ #category : 'scripts' }
BpFigure class >> scriptSave [
	"Save the histtypes figure of the gallery as SVG and PDF (vector graphics) and as PNG at 200 dots per inch, in the image directory, and inspect the files."

	<script>
	| figure directory |
	figure := self instanceHistTypes.
	directory := FileLocator imageDirectory asFileReference.
	^ {
		  (figure saveAsSVG: directory / 'histogram_histtypes.svg').
		  (figure saveAsPDF: directory / 'histogram_histtypes.pdf').
		  (figure saveAsPNG: directory / 'histogram_histtypes.png' dpi: 200) } inspect
]

{ #category : 'accessing' }
BpFigure >> axes [
	"Answer my axes, row by row."

	^ axes
]

{ #category : 'accessing' }
BpFigure >> axesAtRow: aRowIndex column: aColumnIndex [
	"Answer the axes in a row and a column, both counted from 1."

	^ axes at: aRowIndex - 1 * columns + aColumnIndex
]

{ #category : 'accessing' }
BpFigure >> columns [

	^ columns
]

{ #category : 'accessing' }
BpFigure >> figureExtent [
	"Answer the size asked for me with extent:. Unlike extent, it is known before I am laid out. Once I fill my parent (in a window or a Live pane), answer my current extent."

	| horizontal vertical |
	horizontal := self constraints horizontal resizer.
	vertical := self constraints vertical resizer.
	^ (horizontal isExact and: [ vertical isExact ])
		  ifTrue: [ horizontal size @ vertical size ]
		  ifFalse: [ self extent ]
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

{ #category : 'inspector extensions' }
BpFigure >> prepareForLiveView [
	"Fill the Live pane, as I fill the space opened by show:."

	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ]
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

{ #category : 'private - saving' }
BpFigure >> save: anExporter in: aFileReference [
	"Let anExporter draw me on an Alexandrie canvas of its format and write aFileReference. Answer the file."

	^ anExporter
		  element: self;
		  target: aFileReference asFileReference;
		  export
]

{ #category : 'saving' }
BpFigure >> saveAsPDF: aFileReference [
	"Save me in aFileReference as a PDF of vector graphics. Answer the file."

	^ self save: BAExporter pdf in: aFileReference
]

{ #category : 'saving' }
BpFigure >> saveAsPNG: aFileReference [
	"Save me in aFileReference as a PNG of my extent in pixels (100 dots per inch). Answer the file."

	^ self saveAsPNG: aFileReference dpi: 100
]

{ #category : 'saving' }
BpFigure >> saveAsPNG: aFileReference dpi: aNumber [
	"Save me in aFileReference as a PNG of aNumber dots per inch: 100 gives my extent in pixels. Answer the file."

	^ self
		  save: (BAExporter png
			   scale: aNumber / 100;
			   yourself)
		  in: aFileReference
]

{ #category : 'saving' }
BpFigure >> saveAsSVG: aFileReference [
	"Save me in aFileReference as SVG vector graphics. Answer the file."

	^ self save: BAExporter svg in: aFileReference
]

{ #category : 'opening' }
BpFigure >> show: aTitle [
	"Open a space of my figure extent showing me. Answer the space."

	| space |
	space := BlSpace new.
	space
		title: aTitle;
		extent: self figureExtent.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ].
	space root addChild: self.
	space
		show;
		settle.
	^ space
]
