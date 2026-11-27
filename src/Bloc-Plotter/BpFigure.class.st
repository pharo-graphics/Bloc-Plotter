"
I am a figure: a grid of `BpChart`. I'm the page, and a `BpChart` is one plot on it. Both are BlElement
  subclasses, but neither inherits from the other: a figure contains charts.

```
  BpFigure            	grid, palette, window, export
   └─ BpChart (1..n)  	scales, limits, ticks, title, legend
       └─ BpArtist    	histogram, bars, scatter, line…
           └─ patches 	the shapes drawn
```

Plots are added to the charts answered by `chartAtRow:column:`, `chartAtRow:column:put:` places a chart of yours, `show:` opens me, and `saveAsSVG:`, `saveAsPDF:` and `saveAsPNG:` save me.

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
BpFigure exampleBoxPlot.
BpFigure exampleHexbin.
BpFigure exampleHeatmap.
BpFigure exampleColorBar.
BpFigure exampleDensityPlot.
BpFigure examplePolarBar.
BpFigure exampleRadarChart
```

More figures of the gallery are shown by the examples of `BpHistogram`, `BpScatterPlot`, `BpLine`, `BpBoxPlot`, `BpBarPlot`, `BpStemPlot`, `BpFillBetween`, `BpStackPlot`, `BpStairs`, `BpViolinPlot`, `BpErrorBar`, `BpHexbin`, `BpHeatmap`, `BpColorBar`, `BpDensityPlot`, `BpPolarChart` and `BpKiviat`.

## Design Rationale

- Rows and columns are counted from 1, as Pharo collections: `chartAtRow: 1 column: 1` is the top left chart.
- My palettes are handled by a `BpPaletteSource`: by default (`chartPersonalPalette`) each chart has its own palette, and after `uniquePalette:` all my charts take the same one, the ones I create or am given later too. `palette` answers the unique palette, and raises an error when each chart has its own.
- My default extent is 640 by 480, so that the figures of the gallery keep their proportions. `figureExtent` answers the size asked with `extent:`: `show:` sizes its space with it, since `extent` is only known once I am laid out.

- Each format has its own message, so the format never depends on the name of the file. SVG and PDF are vector graphics; `saveAsPNG:dpi:` sets the resolution of a PNG, 100 dots per inch giving my extent in pixels.

## Usage

1. `rows:columns:` (also on the class side) creates my charts, row by row, in a `BlGridLayout`; `rows:columns:chartClass:` creates charts of another class, such as `BpPolarChart` or `BpKiviat`.
2. Plots are added to my charts (`chartAtRow:column:`, `charts`) with `BpChart>>addArtist:`. A chart built apart replaces one of mine with `chartAtRow:column:put:`.
3. `show:` opens me in a space of my extent.

- I am mutable: plots can be added before or after I am shown, and `rows:columns:` replaces all my charts with what they show.

## Implementation Notes

- Bloc keeps the array given to `addChildren:`, so my charts are added as a copy of my collection.
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
		'charts',
		'paletteSource'
	],
	#category : 'Bloc-Plotter-Chart',
	#package : 'Bloc-Plotter',
	#tag : 'Chart'
}

{ #category : 'private - demo' }
BpFigure class >> addColorBarsFirstRowTo: aFigure [
	"Add to the first row of aFigure a hexbin on a log scale and a transparent scatter plot, with their color bars."

	| hexbin scatter |
	hexbin := BpHexbin show: (BpHexbin correlatedPoints: 5000 slope: 1.2 deviation: 1 / 3) in: aFigure charts first.
	hexbin
		gridSize: 20;
		bins: #log.
	(aFigure charts first addColorBarFor: hexbin) label: 'points'.
	aFigure charts first title: 'log scale, label:'.
	scatter := aFigure charts second addArtist: (BpScatterPlot x: (1 to: 60) y: ((1 to: 60) collect: [ :each | each * 17 \\ 61 ])).
	scatter
		c: (1 to: 60);
		s: 80;
		alpha: 0.5.
	(aFigure charts second addColorBarFor: scatter) tickLocations: #( 1 20 40 60 ).
	aFigure charts second title: 'alpha: 0.5, tickLocations:'
]

{ #category : 'private - demo' }
BpFigure class >> addColorBarsSecondRowTo: aFigure [
	"Add to the second row of aFigure a hexbin colored in steps and a heatmap under points, with their color bars."

	| hexbin heatmap scatter |
	hexbin := BpHexbin show: (BpHexbin correlatedPoints: 5000 slope: 1.2 deviation: 1 / 3) in: aFigure charts third.
	hexbin
		gridSize: 20;
		bins: 4.
	(aFigure charts third addColorBarFor: hexbin)
		tickCount: 3;
		tickFormatter: [ :step | 'step ' , step printString ].
	aFigure charts third title: 'bins: 4, tickFormatter:'.
	heatmap := aFigure charts fourth heatmap: #( #( 1 2 3 ) #( 4 5 6 ) #( 7 8 9 ) ).
	heatmap colorMap: (BpInterpolatedPalette name: 'Greys' anchors: (BpSequentialPalette greys: 9) colors).
	scatter := aFigure charts fourth addArtist: (BpScatterPlot x: #( 1 2 3 ) y: #( 1 2 3 )).
	scatter
		c: #( 10 50 100 );
		s: 200;
		colorMap: BpInterpolatedPalette inferno.
	(aFigure charts fourth addColorBarFor: heatmap) label: 'cells'.
	(aFigure charts fourth addColorBarFor: scatter) label: 'points'.
	aFigure charts fourth title: 'two color bars'
]

{ #category : 'examples' }
BpFigure class >> exampleBar [
	"Show the figure of the gallery bar color demo: one bar per category, with its own color and legend label (see `BpBarPlot`)."

	<example>
	^ BpBarPlot exampleBarColors
]

{ #category : 'examples' }
BpFigure class >> exampleBoxPlot [
	"Show the six box plot variants of the gallery (see `BpBoxPlot`)."

	<example>
	^ BpBoxPlot exampleBoxPlotDemo
]

{ #category : 'examples' }
BpFigure class >> exampleColorBar [
	"Show the color bars of hexbins, scatter plots and a heatmap (see `BpColorBar`)."

	<example>
	^ self instanceColorBars show: 'color bar'
]

{ #category : 'examples' }
BpFigure class >> exampleDensityPlot [
	"Show the densities of three samples (see `BpDensityPlot`)."

	<example>
	^ self instanceDensityPlot show: 'density plot'
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
BpFigure class >> exampleHeatmap [
	"Show the figure of the gallery annotated heatmap (see `BpHeatmap`)."

	<example>
	^ self instanceHeatmap show: 'heatmap'
]

{ #category : 'examples' }
BpFigure class >> exampleHexbin [
	"Show the figure of the gallery hexagonal binned plot: 100000 points counted in hexagons (see `BpHexbin`)."

	<example>
	^ self instanceHexbinDemo show: 'hexbin'
]

{ #category : 'examples' }
BpFigure class >> exampleHistTypes [
	"Show a figure of four charts, each with a different kind of histogram (the gallery histogram_histtypes)."

	<example>
	^ self instanceHistTypes show: 'histogram_histtypes'
]

{ #category : 'examples' }
BpFigure class >> exampleInteraction [
	"Show a figure of one chart whose histogram reacts to the mouse: hover a bar to highlight it, click it to see its bin and count (see `BpHistogram`)."

	<example>
	^ BpHistogram exampleInteraction
]

{ #category : 'examples' }
BpFigure class >> exampleMultiHist [
	"Show a figure of four charts with several datasets per histogram (see `BpHistogram`)."

	<example>
	^ BpHistogram exampleMultiHist
]

{ #category : 'examples' }
BpFigure class >> exampleOptions [
	"Show a figure of two rows of three charts, larger than the default one, each with a histogram option (see `BpHistogram`)."

	<example>
	^ BpHistogram exampleOptions
]

{ #category : 'examples' }
BpFigure class >> examplePlot [
	"Show the figure of the plot type page: lines and markers drawn with format strings (see `BpLine`)."

	<example>
	^ BpLine examplePlotType
]

{ #category : 'examples' }
BpFigure class >> examplePolarBar [
	"Show the figure of the gallery bar chart on polar axis: bars of random radii and widths around a center (see `BpPolarChart`)."

	<example>
	^ self instancePolarBar show: 'polar_bar'
]

{ #category : 'examples' }
BpFigure class >> exampleRadarChart [
	"Show the figure of the gallery radar chart: the profiles of five factors in four scenarios (see `BpKiviat`)."

	<example>
	^ self instanceRadarChart show: 'radar_chart'
]

{ #category : 'examples' }
BpFigure class >> exampleScatter [
	"Show a figure of one chart with a scatter of random points of random sizes and colors (see `BpScatterPlot`)."

	<example>
	^ BpScatterPlot exampleScatter
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
	"Show the figures of the gallery stem plot: exp(sin(x)) drawn as stems, plain and styled (see `BpStemPlot`)."

	<example>
	^ BpStemPlot exampleStemPlot
]

{ #category : 'examples' }
BpFigure class >> exampleTwoByTwo [
	"Show an empty figure of two rows of two charts."

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
	| specifications figure chart |
	specifications := #( 'o' '.' 's' '^' 'v' '<' '>' 'D' 'd' 'p' 'h' 'H' '8' '*' 'P' 'X' '+' 'x' '|' '_' #( 6 1 0 ) #( 6 2 0 )
	                     '$\clubsuit$' '$\spadesuit$' '$\heartsuit$' '$\diamondsuit$' ).
	figure := self new.
	figure extent: 1000 @ 220.
	chart := figure charts first.
	specifications withIndexDo: [ :each :index |
		(chart addArtist: (BpScatterPlot x: { index } y: #( 0 )))
			s: 200;
			c: ((BpSequentialPalette greys: 9) colorAt: 9);
			marker: each ].
	chart
		title: 'Markers: o . s ^ v < > D d p h H 8 * P X + x | _ (6,1) (6,2) and the TeX card suits';
		yTickCount: 1.
	^ figure
]

{ #category : 'instances - artists' }
BpFigure class >> instanceArtistsInOneChart [
	"Two kinds of artists in the same chart: a histogram of normal samples and, above it, a scatter plot of their counts; each takes the next color of the cycle and the chart scales to cover both."

	<sampleInstance>
	| random samples chart figure histogram |
	random := Random seed: 19680801.
	samples := (1 to: 500) collect: [ :each | random nextNormal ].
	figure := self new.
	chart := figure charts first.
	histogram := (chart addArtist: (BpHistogram xValues: samples))
		             bins: 15;
		             yourself.
	(chart addArtist: (BpScatterPlot
	  x: ((1 to: 15) collect: [ :index | (histogram binEdges at: index) + (histogram binEdges at: index + 1) / 2 ])
	  y: histogram counts))
		marker: 'D';
		s: 50;
		label: 'counts'.
	chart
		title: 'BpHistogram and BpScatterPlot';
		legend;
		grid: true.
	^ figure
]

{ #category : 'instances - color bar' }
BpFigure class >> instanceColorBars [
	"Color bars of a hexbin on a log scale, a transparent scatter plot, a hexbin in steps, and two artists of the same chart."

	<sampleInstance>
	| figure |
	figure := self rows: 2 columns: 2.
	figure extent: 900 @ 800.
	self addColorBarsFirstRowTo: figure.
	self addColorBarsSecondRowTo: figure.
	^ figure
]

{ #category : 'instances - density' }
BpFigure class >> instanceDensityPlot [
	"The densities of three samples, with a legend."

	<sampleInstance>
	| figure chart |
	figure := self new.
	chart := figure charts first.
	(chart densityPlot: BpDensityPlot threeSamples) label: #( 'first' 'second' 'third' ).
	chart legend.
	^ figure
]

{ #category : 'instances - density' }
BpFigure class >> instanceDensityPlotOptions [
	"Density plots of several bandwidths, stopped at the values, horizontal, and over a histogram."

	<sampleInstance>
	| figure values plot |
	values := BpDensityPlot twoGroups.
	figure := self rows: 2 columns: 2.
	figure extent: 900 @ 700.
	#( 0.1 #scott 1 ) do: [ :each |
		plot := figure charts first densityPlot: values.
		plot
			bandwidth: each;
			fill: false;
			label: each printString ].
	figure charts first
		title: 'bandwidth:';
		legend.
	(figure charts second densityPlot: values)
		cut: 0;
		lineStyle: '--'.
	figure charts second title: 'cut: 0, lineStyle: ''--'''.
	(figure charts third densityPlot: BpDensityPlot threeSamples)
		orientation: #horizontal;
		alpha: 0.5.
	figure charts third title: 'orientation: #horizontal, alpha: 0.5'.
	(figure charts fourth addArtist: (BpHistogram xValues: values))
		bins: 25;
		density: true;
		color: ((BpSequentialPalette greys: 9) colorAt: 4).
	(figure charts fourth densityPlot: values)
		fill: false;
		lineWidth: 3;
		color: (BpQualitativePalette set1 colorAt: 1).
	figure charts fourth title: 'over a histogram'.
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
	symmetric := figure chartAtRow: 1 column: 1.
	(symmetric errorBarX: x y: y yErr: error) format: '-o'.
	symmetric title: 'variable, symmetric error'.
	asymmetric := figure chartAtRow: 2 column: 1.
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
	| figure chart x |
	figure := self new.
	chart := figure charts first.
	x := BpErrorBar arangeFrom: 0.1 to: 4 by: 0.5.
	chart
		errorBarX: x
		y: (x collect: [ :each | each negated exp ])
		xErr: 0.2
		yErr: 0.4.
	chart title: 'Simplest errorbars, 0.2 in x, 0.4 in y'.
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceErrorBarLimits [
	"Gallery: Including upper and lower limits in error bars (errorbar_limits_simple), first figure: limits on all points, on both sides, or on some points only."

	<sampleInstance>
	| figure |
	figure := self new.
	BpErrorBar addLimitSeriesTo: figure charts first.
	figure charts first legend.
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceErrorBarPlotType [
	"Plot types: errorbar(x, y, yerr, xerr), three circles with 2 point wide error bars and caps, with fixed limits and ticks."

	<sampleInstance>
	| figure chart |
	figure := self new.
	chart := figure charts first.
	(chart errorBarX: #( 2 4 6 ) y: #( 3.6 5 4.2 ) yErr: #( 0.9 1.2 0.5 ))
		format: 'o';
		lineWidth: 2;
		capSize: 6.
	chart
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
	1 to: 3 do: [ :column | BpErrorBar subsampleIn: (figure chartAtRow: 1 column: column) column: column ].
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceFillBetweenConfidenceBand [
	"Gallery: Fill the area between two lines (fill_between_demo), confidence bands: a linear fit of the data and its confidence band, half transparent."

	<sampleInstance>
	| x y band figure chart |
	x := BpFillBetween linspaceFrom: 0 to: 10 count: 11.
	y := #( 3.9 4.4 10.8 10.3 11.2 13.1 14.1 9.9 13.9 15.1 12.5 ).
	band := BpFillBetween confidenceBandOf: x and: y.
	figure := self new.
	chart := figure charts first.
	chart addArtist: ((BpLine x: x y: (band first with: band last collect: [ :low :high | low + high / 2 ]))
	 format: '-';
	 yourself).
	(chart fillBetweenX: x y1: band first y2: band last) alpha: 0.2.
	(chart addArtist: ((BpLine x: x y: y)
	  format: 'o';
	  yourself)) color: (chart palette colorAt: 6).
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
	(figure chartAtRow: 1 column: 1) fillBetweenX: x y1: y1.
	(figure chartAtRow: 1 column: 1) title: 'fill between y1 and 0'.
	(figure chartAtRow: 2 column: 1) fillBetweenX: x y1: y1 y2: 1.
	(figure chartAtRow: 2 column: 1) title: 'fill between y1 and 1'.
	(figure chartAtRow: 3 column: 1) fillBetweenX: x y1: y1 y2: y2.
	(figure chartAtRow: 3 column: 1) title: 'fill between y1 and y2'.
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceFillBetweenPlotType [
	"Plot types: fill_between(x, y1, y2), a half transparent band between two noisy lines and the line in its middle."

	<sampleInstance>
	| random x y1 y2 figure chart |
	random := Random seed: 1.
	x := BpFillBetween linspaceFrom: 0 to: 8 count: 16.
	y1 := x collect: [ :each | 3 + (4 * each / 8) + (random next * 0.5) ].
	y2 := x collect: [ :each | 1 + (2 * each / 8) + (random next * 0.5) ].
	figure := self new.
	chart := figure charts first.
	(chart fillBetweenX: x y1: y1 y2: y2)
		alpha: 0.5;
		lineWidth: 0.
	(chart addArtist: (BpLine x: x y: (y1 with: y2 collect: [ :a :b | a + b / 2 ]))) lineWidth: 2.
	chart
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
		| chart |
		chart := figure chartAtRow: 1 column: column.
		(chart fillBetweenX: x y1: y)
			step: style;
			alpha: 0.4.
		chart addArtist: ((BpLine x: x y: y)
	 format: 'o';
	 yourself).
		chart title: 'step: #' , style ].
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
	(figure chartAtRow: 1 column: 1) fillBetweenY: y x1: 0 x2: x1.
	(figure chartAtRow: 1 column: 1) title: 'between (x1, 0)'.
	(figure chartAtRow: 1 column: 2) fillBetweenY: y x1: x1 x2: 1.
	(figure chartAtRow: 1 column: 2) title: 'between (x1, 1)'.
	(figure chartAtRow: 1 column: 3) fillBetweenY: y x1: x1 x2: x2.
	(figure chartAtRow: 1 column: 3) title: 'between (x1, x2)'.
	^ figure
]

{ #category : 'instances - heatmap' }
BpFigure class >> instanceHeatmap [
	"The gallery annotated heatmap: the harvest of vegetables by farmers, with its numbers and a color bar."

	<sampleInstance>
	| figure chart heatmap |
	figure := self new.
	figure extent: 820 @ 520.
	chart := figure charts first.
	heatmap := BpHeatmap harvestIn: chart.
	heatmap showAmounts: true.
	chart title: 'Harvest of local farmers (in tonnes/year)'.
	chart addColorBarFor: heatmap.
	^ figure
]

{ #category : 'instances - heatmap' }
BpFigure class >> instanceHeatmapOptions [
	"Heatmaps with edges, a diverging color map, missing numbers, and a log scale with many cells."

	<sampleInstance>
	| figure heatmap |
	figure := self rows: 2 columns: 2.
	figure extent: 900 @ 800.
	heatmap := figure charts first heatmap: #( #( 12 4 9 ) #( 7 16 1 ) #( 3 8 14 ) ).
	heatmap
		showAmounts: true;
		colorMap: (BpInterpolatedPalette name: 'Blues' anchors: (BpSequentialPalette blues: 9) colors);
		edgeColors: ((BpSequentialPalette greys: 9) colorAt: 1);
		lineWidths: 3.
	figure charts first title: 'edgeColors:, lineWidths: 3'.
	heatmap := figure charts second heatmap: #( #( 1 0.8 -0.3 -0.7 ) #( 0.8 1 -0.1 -0.5 ) #( -0.3 -0.1 1 0.4 ) #( -0.7 -0.5 0.4 1 ) ).
	heatmap
		showAmounts: true;
		colorMap: BpHeatmap divergingMap;
		vMin: -1;
		vMax: 1.
	figure charts second title: 'vMin: -1, vMax: 1'.
	figure charts second addColorBarFor: heatmap.
	heatmap := figure charts third heatmap: #( #( 5 nil 2 ) #( nil 8 6 ) #( 1 3 nil ) ).
	heatmap
		showAmounts: true;
		amountFormatter: [ :amount | amount printString , ' kg' ].
	figure charts third title: 'nil cells, amountFormatter:'.
	heatmap := BpHeatmap wavesIn: figure charts fourth.
	heatmap
		colorMap: BpInterpolatedPalette inferno;
		scale: #log.
	figure charts fourth title: 'scale: #log'.
	figure charts fourth addColorBarFor: heatmap.
	^ figure
]

{ #category : 'instances - hexbin' }
BpFigure class >> instanceHexbinDemo [
	"Gallery: Hexagonal binned plot (hexbin_demo): 100000 points, on a linear and on a logarithmic color scale."

	<sampleInstance>
	| figure points |
	points := (BpHexbin correlatedPoints: 100000 slope: 3 deviation: 4) collect: [ :each | each + (0 @ 2) ].
	figure := self rows: 1 columns: 2.
	figure extent: 900 @ 400.
	figure charts with: #( 'Hexagon binning' 'With a log color scale' ) do: [ :chart :title |
		(BpHexbin show: points in: chart)
			gridSize: 50;
			colorMap: BpInterpolatedPalette inferno.
		chart title: title ].
	figure charts last artists first bins: #log.
	^ figure
]

{ #category : 'instances - hexbin' }
BpFigure class >> instanceHexbinOptions [
	"Hexbins with few points hidden, colors in steps, the average of a third variable, and a log axis."

	<sampleInstance>
	| figure points |
	points := BpHexbin correlatedPoints: 5000 slope: 1.2 deviation: 1 / 3.
	figure := self rows: 2 columns: 2.
	figure extent: 900 @ 800.
	(BpHexbin show: points in: figure charts first)
		gridSize: 25;
		minCount: 5.
	figure charts first title: 'minCount: 5'.
	(BpHexbin show: points in: figure charts second)
		gridSize: 25;
		bins: 4;
		edgeColors: ((BpSequentialPalette greys: 9) colorAt: 1).
	figure charts second title: 'bins: 4'.
	(BpHexbin show: points in: figure charts third)
		gridSize: 25;
		c: (points collect: [ :each | each x sin ]).
	figure charts third title: 'c: sin(x)'.
	(BpHexbin show: (points collect: [ :each | (10 raisedTo: each x) @ each y ]) in: figure charts fourth)
		gridSize: 25;
		xScale: #log.
	figure charts fourth title: 'xScale: #log'.
	^ figure
]

{ #category : 'instances - hexbin' }
BpFigure class >> instanceHexbinPlotType [
	"Plot types: hexbin(x, y, C), five thousand points around a line."

	<sampleInstance>
	| figure chart |
	figure := self new.
	chart := figure charts first.
	(BpHexbin show: (BpHexbin correlatedPoints: 5000 slope: 1.2 deviation: 1 / 3) in: chart) gridSize: 20.
	chart
		xLimits: #( -2 2 );
		yLimits: #( -3 3 ).
	^ figure
]

{ #category : 'instances - histogram' }
BpFigure class >> instanceHistTypes [
	"Gallery: Demo of the histogram function's different histtype settings (histogram_histtypes), built from the instances of `BpHistogram`."

	<sampleInstance>
	| figure barstacked |
	figure := self rows: 2 columns: 2.
	barstacked := BpChart new.
	barstacked
		addArtist: BpHistogram instanceBarStacked;
		addArtist: BpHistogram instanceBarStackedNarrow;
		title: 'barstacked'.
	figure
		chartAtRow: 1 column: 1 put: (BpChart new
			 addArtist: BpHistogram instanceStepFilled;
			 title: 'stepfilled';
			 yourself);
		chartAtRow: 1 column: 2 put: (BpChart new
			 addArtist: BpHistogram instanceStep;
			 title: 'step';
			 yourself);
		chartAtRow: 2 column: 1 put: barstacked;
		chartAtRow: 2 column: 2 put: (BpChart new
			 addArtist: BpHistogram instanceUnequalBins;
			 title: 'bar, unequal bins';
			 yourself).
	^ figure
]

{ #category : 'instances - density' }
BpFigure class >> instanceInteractiveDensity [
	"A density plot with interaction handlers on its areas: hovering an area darkens it, clicking it shows its sample in the title."

	<sampleInstance>
	| figure chart plot |
	figure := self new.
	chart := figure charts first.
	plot := chart densityPlot: BpDensityPlot threeSamples.
	chart title: 'Click an area'.
	plot
		whenPatch: BlMouseEnterEvent do: [ :event :patch | patch opacity: 0.6 ];
		whenPatch: BlMouseLeaveEvent do: [ :event :patch | patch opacity: 1 ];
		whenPatch: BlClickEvent do: [ :event :patch |
			chart title: ('Sample {1}, bandwidth {2}' format: {
				 patch dataset.
				 ((plot estimates at: patch dataset) bandwidth printShowingDecimalPlaces: 2) }) ].
	^ figure
]

{ #category : 'instances - error bar' }
BpFigure class >> instanceInteractiveErrorBars [
	"Measures with error bars: hovering a bar thickens it, clicking it shows the measure in the title."

	<sampleInstance>
	| figure chart measures errors errorBar |
	figure := self new.
	chart := figure charts first.
	chart title: 'Click an error bar'.
	measures := #( 2.1 3.4 3.0 4.6 5.2 ).
	errors := #( 0.3 0.5 0.4 0.6 0.3 ).
	errorBar := (chart errorBarX: (1 to: 5) y: measures yErr: errors)
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
				chart title: ('measure {1}: {2} ± {3}' format: {
					 patch dataset.
					 (measures at: patch dataset).
					 (errors at: patch dataset) }) ] ].
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceInteractiveFill [
	"A sine filled in the first color of the palette where it is positive and in the second where it is negative, one polygon per hump: hovering a polygon outlines it, clicking it shows its x range in the title."

	<sampleInstance>
	| x y figure chart fills |
	x := BpFillBetween linspaceFrom: 0 to: 4 * Float pi count: 200.
	y := x collect: [ :each | each sin ].
	figure := self new.
	chart := figure charts first.
	chart title: 'Click a hump'.
	fills := {
		         ((chart fillBetweenX: x y1: y)
			          where: (y collect: [ :each | each >= 0 ]);
			          interpolate: true;
			          color: (chart palette colorAt: 1);
			          yourself).
		         ((chart fillBetweenX: x y1: y)
			          where: (y collect: [ :each | each <= 0 ]);
			          interpolate: true;
			          color: (chart palette colorAt: 2);
			          yourself) }.
	fills do: [ :fill |
		fill
			whenPatch: BlMouseEnterEvent
			do: [ :event :polygon | polygon border: (BlBorder paint: ((BpSequentialPalette greys: 9) colorAt: 9) width: 2) ];
			whenPatch: BlMouseLeaveEvent do: [ :event :polygon | fill paint: polygon ];
			whenPatch: BlClickEvent do: [ :event :polygon |
				chart title: ('from x = {1} to x = {2}' format: {
					 ((polygon dataVertices collect: [ :each | each x ]) min printShowingDecimalPlaces: 2).
					 ((polygon dataVertices collect: [ :each | each x ]) max printShowingDecimalPlaces: 2) }) ] ].
	^ figure
]

{ #category : 'instances - heatmap' }
BpFigure class >> instanceInteractiveHeatmap [
	"A heatmap with interaction handlers on its cells: hovering a cell outlines it, clicking it shows its names and number in the title."

	<sampleInstance>
	| figure chart heatmap |
	figure := self new.
	figure extent: 820 @ 520.
	chart := figure charts first.
	heatmap := BpHeatmap harvestIn: chart.
	chart title: 'Click a cell'.
	heatmap
		whenPatch: BlMouseEnterEvent
		do: [ :event :cell | cell border: (BlBorder paint: (BpQualitativePalette set1 colorAt: 1) width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :cell | cell border: (BlBorder paint: cell background paint width: 1) ];
		whenPatch: BlClickEvent do: [ :event :cell |
			chart title: ('{1}, {2}: {3}' format: {
				 (heatmap rowNameAt: cell row).
				 (heatmap columnNameAt: cell column).
				 cell amount }) ].
	^ figure
]

{ #category : 'instances - hexbin' }
BpFigure class >> instanceInteractiveHexbin [
	"A hexbin with interaction handlers on its hexagons: hovering a hexagon outlines it, clicking it shows its center and number of points in the title."

	<sampleInstance>
	| figure chart hexbin |
	figure := self new.
	chart := figure charts first.
	hexbin := BpHexbin show: (BpHexbin correlatedPoints: 2000 slope: 1.2 deviation: 0.5) in: chart.
	hexbin
		gridSize: 20;
		minCount: 1.
	chart title: 'Click a hexagon'.
	hexbin
		whenPatch: BlMouseEnterEvent
		do: [ :event :hexagon | hexagon border: (BlBorder paint: (BpQualitativePalette set1 colorAt: 1) width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :hexagon | hexagon border: (BlBorder paint: hexagon background paint width: 1) ];
		whenPatch: BlClickEvent do: [ :event :hexagon |
			chart title: ('{1} points around ({2}, {3})' format: {
				 hexagon count.
				 (hexagon center x printShowingDecimalPlaces: 2).
				 (hexagon center y printShowingDecimalPlaces: 2) }) ].
	^ figure
]

{ #category : 'instances - stack plot' }
BpFigure class >> instanceInteractiveStack [
	"The world population by continent: hovering a layer outlines it, clicking it shows its continent and its last value in the title."

	<sampleInstance>
	| figure chart stack |
	figure := self instanceStackPlotWorldPopulation.
	chart := figure charts first.
	chart title: 'Click a continent'.
	stack := chart artists first.
	stack
		whenPatch: BlMouseEnterEvent do: [ :event :polygon | polygon border: (BlBorder paint: ((BpSequentialPalette greys: 9) colorAt: 9) width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :polygon | polygon border: BlBorder empty ];
		whenPatch: BlClickEvent do: [ :event :polygon |
			chart title: ('{1}: {2} billion people in 2018' format: {
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
	| figure chart edges |
	figure := self new.
	chart := figure charts first.
	chart title: 'Click a step curve'.
	edges := 0 to: 12.
	{
		('sin' -> [ :each | (each / 2) sin ]).
		('cos' -> [ :each | (each / 2) cos ]).
		('half sin' -> [ :each | (each / 2) sin / 2 ]) } do: [ :each |
			| stairs |
			stairs := (chart stairs: ((0 to: 11) collect: [ :index | each value value: index + (1 / 2) ]) edges: edges)
				          baseline: nil;
				          label: each key;
				          yourself.
			stairs
				whenPatch: BlMouseEnterEvent do: [ :event :polygon | polygon border: (BlBorder paint: polygon border paint width: 4) ];
				whenPatch: BlMouseLeaveEvent do: [ :event :polygon | stairs paint: polygon ];
				whenPatch: BlClickEvent do: [ :event :polygon | chart title: ('clicked: {1}' format: { each key }) ] ].
	chart legend.
	^ figure
]

{ #category : 'instances - violin plot' }
BpFigure class >> instanceInteractiveViolins [
	"Three violins: hovering one makes it opaque, clicking it shows its median in the title."

	<sampleInstance>
	| random figure chart violins isBody |
	random := Random seed: 3.
	figure := self new.
	chart := figure charts first.
	chart title: 'Click a violin'.
	violins := (chart violinPlot: ((1 to: 3) collect: [ :each |
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
			chart title: ('violin {1}: median {2}' format: {
				 patch dataset.
				 ((violins statistics at: patch dataset) median printShowingDecimalPlaces: 2) }) ].
	^ figure
]

{ #category : 'instances - polar' }
BpFigure class >> instancePolarArtists [
	"A line, a scatter plot, a histogram and a filled curve in polar charts: the angles are the x of the artists, the radii their y."

	<sampleInstance>
	| random figure angles |
	random := Random seed: 19680801.
	figure := self rows: 2 columns: 2 chartClass: BpPolarChart.
	figure extent: 800 @ 800.
	angles := (0 to: 360) collect: [ :each | each degreesToRadians ].
	(figure chartAtRow: 1 column: 1) addArtist: (BpLine x: angles y: (angles collect: [ :each | 1 + (4 * each) cos ]));
		title: 'plotX:y:'.
	BpPolarChart showPointsIn: (figure chartAtRow: 1 column: 2) random: random.
	BpPolarChart showHistogramIn: (figure chartAtRow: 2 column: 1) random: random.
	((figure chartAtRow: 2 column: 2) fillBetweenX: angles y1: (angles collect: [ :each | 2 + (3 * each) sin ])) alpha: 0.5.
	(figure chartAtRow: 2 column: 2) title: 'fillBetweenX:y1:'.
	^ figure
]

{ #category : 'instances - polar' }
BpFigure class >> instancePolarBar [
	"Gallery: Bar chart on polar axis (polar_bar): twenty bars of random radii and widths, colored by their radius through viridis."

	<sampleInstance>
	| random count radii figure |
	random := Random seed: 19680801.
	count := 20.
	radii := (1 to: count) collect: [ :each | 10 * random next ].
	figure := self rows: 1 columns: 1 chartClass: BpPolarChart.
	(figure charts first barXValues: ((0 to: count - 1) collect: [ :each | Float twoPi * each / count ]) heightValues: radii)
		width: ((1 to: count) collect: [ :each | Float pi / 4 * random next ]);
		color: (radii collect: [ :each | BpInterpolatedPalette viridis colorAt: each / 10 ]);
		alpha: 0.5.
	^ figure
]

{ #category : 'instances - polar' }
BpFigure class >> instanceRadarChart [
	"Gallery: Radar chart (aka spider or star chart) (radar_chart): the profiles of five factors in four scenarios."

	<sampleInstance>
	| figure |
	figure := self rows: 2 columns: 2 chartClass: BpKiviat.
	figure extent: 1100 @ 900.
	figure charts with: BpKiviat factorProfiles do: [ :chart :profile |
		BpKiviat showFactors: profile value in: chart.
		chart title: profile key ].
	figure charts first legend.
	^ figure
]

{ #category : 'instances - fill between' }
BpFigure class >> instanceSelectiveFill [
	"Gallery: Fill the area between two lines (fill_between_demo), selectively filling horizontal regions: where y1 > y2 in the first color of the palette, where y1 < y2 in the second, without and with interpolation at the crossing."

	<sampleInstance>
	| x y1 y2 figure |
	x := #( 0 1 2 3 ).
	y1 := #( 0.8 0.8 0.2 0.2 ).
	y2 := #( 0 0 1 1 ).
	figure := self rows: 2 columns: 1.
	#( false true ) withIndexDo: [ :interpolation :row |
		| chart |
		chart := figure chartAtRow: row column: 1.
		chart title: 'interpolation=' , (interpolation
			 ifTrue: [ 'True' ]
			 ifFalse: [ 'False' ]).
		chart addArtist: ((BpLine x: x y: y1)
	 format: 'o--';
	 yourself).
		chart addArtist: ((BpLine x: x y: y2)
	 format: 'o--';
	 yourself).
		(chart fillBetweenX: x y1: y1 y2: y2)
			where: (y1 with: y2 collect: [ :a :b | a > b ]);
			color: (chart palette colorAt: 1);
			alpha: 0.3;
			interpolate: interpolation.
		(chart fillBetweenX: x y1: y1 y2: y2)
			where: (y1 with: y2 collect: [ :a :b | a < b ]);
			color: (chart palette colorAt: 2);
			alpha: 0.3;
			interpolate: interpolation ].
	^ figure
]

{ #category : 'instances - violin plot' }
BpFigure class >> instanceSplitViolins [
	"Two groups compared on each side of the same positions: the low halves on the left, the high halves on the right."

	<sampleInstance>
	| random figure chart |
	random := Random seed: 7.
	figure := self new.
	chart := figure charts first.
	(chart violinPlot: ((1 to: 4) collect: [ :each |
		  BpViolinPlot
			  normalSamples: 150
			  mean: each
			  deviation: 1
			  random: random ]))
		side: #low;
		showExtrema: false;
		showMedians: true;
		label: 'before'.
	(chart violinPlot: ((1 to: 4) collect: [ :each |
		  BpViolinPlot
			  normalSamples: 150
			  mean: each + 1
			  deviation: 0.6
			  random: random ]))
		side: #high;
		showExtrema: false;
		showMedians: true;
		label: 'after'.
	chart
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
		| chart |
		chart := figure charts at: index.
		(chart stackPlotX: x ys: layers) baseline: each.
		chart title: 'baseline: #' , each ].
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
	(figure charts first stackPlotX: x ys: ((1 to: 3) collect: [ :each | BpStackPlot gaussianMixtureOver: x random: random ]))
		baseline: #wiggle.
	^ figure
]

{ #category : 'instances - stack plot' }
BpFigure class >> instanceStackPlotType [
	"Plot types: stackplot(x, y), three layers over x = 0, 2, 4, 6, 8 with fixed limits and ticks."

	<sampleInstance>
	| figure chart |
	figure := self new.
	chart := figure charts first.
	chart stackPlotX: (BpStackPlot arangeFrom: 0 to: 10 by: 2) ys: #( #( 1 1.25 2 2.75 3 ) #( 1 1 1 1 1 ) #( 2 1 2 1 2 ) ).
	chart
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
	| population figure chart |
	population := {
		              ('Africa' -> #( 0.228 0.284 0.365 0.477 0.631 0.814 1.044 1.275 )).
		              ('the Americas' -> #( 0.340 0.425 0.519 0.619 0.727 0.840 0.943 1.006 )).
		              ('Asia' -> #( 1.394 1.686 2.120 2.625 3.202 3.714 4.169 4.560 )).
		              ('Europe' -> #( 0.220 0.253 0.276 0.295 0.310 0.303 0.294 0.293 )).
		              ('Oceania' -> #( 0.012 0.015 0.019 0.022 0.026 0.031 0.036 0.039 )) }.
	figure := self new.
	chart := figure charts first.
	(chart stackPlotX: #( 1950 1960 1970 1980 1990 2000 2010 2018 ) ys: (population collect: [ :each | each value ]))
		label: (population collect: [ :each | each key ]);
		alpha: 0.8.
	chart
		legend;
		title: 'World population'.
	^ figure
]

{ #category : 'instances - stairs' }
BpFigure class >> instanceStairsDemo [
	"Gallery: Stairs Demo (stairs_demo), first figure: step histograms with a modified baseline or none, filled and horizontal steps, and stairs added to their chart as an artist."

	<sampleInstance>
	| figure chart |
	figure := self rows: 3 columns: 1.
	figure extent: 600 @ 900.
	BpStairs stepHistogramsIn: (figure chartAtRow: 1 column: 1).
	BpStairs filledStepsIn: (figure chartAtRow: 2 column: 1).
	chart := figure chartAtRow: 3 column: 1.
	chart addArtist: (BpStairs new
		 values: #( 1 2 3 2 1 ) edges: (1 to: 6);
		 label: 'Artist added to the chart';
		 yourself).
	chart
		xLimits: #( 0 7 );
		yLimits: #( -1 5 );
		title: 'BpStairs artist'.
	figure charts do: [ :each | each legend ].
	^ figure
]

{ #category : 'instances - stairs' }
BpFigure class >> instanceStairsPlotType [
	"Plot types: stairs(values), eight steps 2.5 points wide with fixed limits and ticks."

	<sampleInstance>
	| figure chart |
	figure := self new.
	chart := figure charts first.
	(chart stairs: #( 4.8 5.5 3.5 4.6 6.5 6.6 2.6 3.0 )) lineWidth: 2.5.
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'instances' }
BpFigure class >> instanceTwoByTwo [
	"Answer a figure of two rows of two charts, each with a title, ready to receive plots."

	<sampleInstance>
	| figure |
	figure := self rows: 2 columns: 2.
	figure charts withIndexDo: [ :chart :index | chart title: 'chart ' , index printString ].
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
			customViolinsIn: (figure chartAtRow: 1 column: column)
			data: data
			number: number
			horizontal: false.
		BpViolinPlot
			customViolinsIn: (figure chartAtRow: 2 column: column)
			data: data
			number: number
			horizontal: true ].
	^ figure
]

{ #category : 'instances - violin plot' }
BpFigure class >> instanceViolinPlotType [
	"Plot types: violinplot(D), three violins 2 wide at 2, 4 and 6, without lines, nearly opaque, with fixed limits and ticks."

	<sampleInstance>
	| random figure chart |
	random := Random seed: 10.
	figure := self new.
	chart := figure charts first.
	(chart
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
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7).
	^ figure
]

{ #category : 'instance creation' }
BpFigure class >> rows: aRowCount columns: aColumnCount [
	"Answer a figure with a grid of charts."

	^ self new
		  rows: aRowCount columns: aColumnCount;
		  yourself
]

{ #category : 'instance creation' }
BpFigure class >> rows: aRowCount columns: aColumnCount chartClass: aChartClass [
	"Answer a figure with a grid of charts that are instances of aChartClass, `BpChart` or one of its subclasses."

	^ self new
		  rows: aRowCount columns: aColumnCount chartClass: aChartClass;
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
BpFigure >> chartAtRow: aRowIndex column: aColumnIndex [
	"Answer the chart in a row and a column, both counted from 1."

	^ charts at: columns * (aRowIndex - 1) + aColumnIndex
]

{ #category : 'accessing' }
BpFigure >> chartAtRow: aRowIndex column: aColumnIndex put: aChart [
	"Replace the chart in a row and a column, both counted from 1, by aChart, and give it my palette when it is unique."

	| index |
	index := columns * (aRowIndex - 1) + aColumnIndex.
	self replaceChild: (charts at: index) with: aChart.
	charts at: index put: aChart.
	paletteSource givePaletteTo: aChart
]

{ #category : 'configuring' }
BpFigure >> chartPersonalPalette [
	"Let each of my charts have its own palette. The charts keep the one they have."

	paletteSource := BpPersonalPalette new
]

{ #category : 'accessing' }
BpFigure >> charts [
	"Answer my charts, row by row."

	^ charts
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
	paletteSource := BpPersonalPalette new.
	self
		background: Color white;
		padding: (BlInsets all: 6);
		extent: 640 @ 480.
	self rows: 1 columns: 1
]

{ #category : 'accessing' }
BpFigure >> palette [
	"Answer the palette of all my charts. Raise an error when each chart has its own."

	^ paletteSource palette
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
	"Replace my charts by a grid of aRowCount by aColumnCount new charts."

	self rows: aRowCount columns: aColumnCount chartClass: BpChart
]

{ #category : 'accessing' }
BpFigure >> rows: aRowCount columns: aColumnCount chartClass: aChartClass [
	"Replace my charts by a grid of aRowCount by aColumnCount new instances of aChartClass, `BpChart` or one of its subclasses."

	rows := aRowCount.
	columns := aColumnCount.
	self removeChildren.
	self layout: (BlGridLayout horizontal
		 columnCount: aColumnCount;
		 cellSpacing: 4;
		 yourself).
	charts := (1 to: aRowCount * aColumnCount) collect: [ :each | aChartClass new ].
	charts do: [ :each | paletteSource givePaletteTo: each ].
	self addChildren: charts copy
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

{ #category : 'configuring' }
BpFigure >> uniquePalette: anEnumeratedPalette [
	"Take the colors of all my charts from anEnumeratedPalette, the ones I get later too."

	paletteSource := BpUniquePalette on: anEnumeratedPalette.
	charts do: [ :each | paletteSource givePaletteTo: each ]
]
