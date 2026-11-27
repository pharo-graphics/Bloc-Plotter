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
	hexbin := aFigure charts first addArtist: ((BpHexbin ofPoints: BpHexbin optionPoints)
		           gridSize: 20;
		           bins: #log;
		           yourself).
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
	hexbin := aFigure charts third addArtist: ((BpHexbin ofPoints: BpHexbin optionPoints)
		           gridSize: 20;
		           bins: 4;
		           yourself).
	(aFigure charts third addColorBarFor: hexbin)
		tickCount: 3;
		tickFormatter: [ :step | 'step ' , step printString ].
	aFigure charts third title: 'bins: 4, tickFormatter:'.
	heatmap := aFigure charts fourth addArtist: ((BpHeatmap matrix: #( #( 1 2 3 ) #( 4 5 6 ) #( 7 8 9 ) ))
		            colorMap: (BpInterpolatedPalette name: 'Greys' anchors: (BpSequentialPalette greys: 9) colors);
		            yourself).
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
	^ BpDensityPlot exampleThreeSamples
]

{ #category : 'examples' }
BpFigure class >> exampleErrorBar [
	"Show the figure of the gallery error bar limits: upper and lower limits on all or some points (see `BpErrorBar`)."

	<example>
	^ BpErrorBar exampleLimits
]

{ #category : 'examples' }
BpFigure class >> exampleFillBetween [
	"Show the figure of the gallery fill_between demo: the area between a curve and 0, a curve and 1, and two curves (see `BpFillBetween`)."

	<example>
	^ BpFillBetween exampleFillBetweenDemo
]

{ #category : 'examples' }
BpFigure class >> exampleHeatmap [
	"Show the figure of the gallery annotated heatmap (see `BpHeatmap`)."

	<example>
	^ BpHeatmap exampleAnnotated
]

{ #category : 'examples' }
BpFigure class >> exampleHexbin [
	"Show the figure of the gallery hexagonal binned plot: 100000 points counted in hexagons (see `BpHexbin`)."

	<example>
	^ BpHexbin exampleHexbinDemo
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
	^ BpStackPlot exampleWorldPopulation
]

{ #category : 'examples' }
BpFigure class >> exampleStairs [
	"Show the figure of the gallery stairs demo: step histograms, filled and horizontal steps (see `BpStairs`)."

	<example>
	^ BpStairs exampleStairsDemo
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
	^ BpViolinPlot exampleViolinPlotBasics
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

{ #category : 'instances - polar' }
BpFigure class >> instancePolarArtists [
	"A line, a scatter plot, a histogram and a filled curve in polar charts: the angles are the x of the artists, the radii their y."

	<sampleInstance>
	| random figure angles |
	random := Random seed: 19680801.
	figure := self rows: 2 columns: 2 chartClass: BpPolarChart.
	figure extent: 800 @ 800.
	angles := (0 to: 360) collect: [ :each | each degreesToRadians ].
	(figure chartAtRow: 1 column: 1)
		addArtist: (BpLine x: angles y: (angles collect: [ :each | 1 + (4 * each) cos ]));
		title: 'BpLine'.
	BpPolarChart showPointsIn: (figure chartAtRow: 1 column: 2) random: random.
	BpPolarChart showHistogramIn: (figure chartAtRow: 2 column: 1) random: random.
	((figure chartAtRow: 2 column: 2) addArtist: (BpFillBetween x: angles y1: (angles collect: [ :each | 2 + (3 * each) sin ])))
		alpha: 0.5.
	(figure chartAtRow: 2 column: 2) title: 'BpFillBetween'.
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

{ #category : 'instances' }
BpFigure class >> instanceTwoByTwo [
	"Answer a figure of two rows of two charts, each with a title, ready to receive plots."

	<sampleInstance>
	| figure |
	figure := self rows: 2 columns: 2.
	figure charts withIndexDo: [ :chart :index | chart title: 'chart ' , index printString ].
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
