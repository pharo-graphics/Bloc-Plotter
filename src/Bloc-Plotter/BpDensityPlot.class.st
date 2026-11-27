"
I am a density plot of a `BpChart`: I draw the estimated density of one or several datasets (`BpKernelDensity`) as curves over filled areas. Unlike a histogram, I have no bins to choose, but a `bandwidth:`.

## Examples

```
BpDensityPlot exampleThreeSamples.
BpDensityPlot exampleOptions.
BpDensityPlot exampleInteraction
```

## Design Rationale

- A curve goes beyond its values by three times the width of the kernel (`cut:`), where it is nearly 0. `cut: 0` stops it at the values, as the body of a violin (`BpViolinPlot`).
- The curves are drawn above all the areas. `alpha:` is the one of the areas (0.3 by default), which overlap.
- A single `label:` is the one of the first dataset; give one per dataset otherwise.

## Usage

1. `BpDensityPlot class>>of:` creates me with my datasets, and `BpChart>>addArtist:` adds me to a chart, as `BpDensityPlot class>>exampleOptions` does with three curves of different bandwidths (see `BpArtist`).
2. My patches answer their `dataset`, which interaction handlers given to `whenPatch:do:` use. `estimates` and `curves` answer my results.

## Invariants and Assumptions

- Each dataset holds at least two different numbers: an error is raised otherwise.
"
Class {
	#name : 'BpDensityPlot',
	#superclass : 'BpArtist',
	#instVars : [
		'datasets',
		'bandwidth',
		'points',
		'cut',
		'fill',
		'color',
		'lineWidth',
		'lineStyle',
		'orientation',
		'estimates',
		'curves'
	],
	#category : 'Bloc-Plotter-Density',
	#package : 'Bloc-Plotter',
	#tag : 'Density'
}

{ #category : 'examples' }
BpDensityPlot class >> exampleInteraction [
	"Interaction handlers on the areas: hover an area to darken it, click it to see its sample and its bandwidth in the title."

	<example>
	| figure chart plot |
	figure := BpFigure new.
	chart := BpChart new.
	plot := chart addArtist: self instanceThreeSamples.
	chart title: 'Click an area'.
	plot
		whenPatch: BlMouseEnterEvent do: [ :event :patch | patch opacity: 0.6 ];
		whenPatch: BlMouseLeaveEvent do: [ :event :patch | patch opacity: 1 ];
		whenPatch: BlClickEvent do: [ :event :patch |
			chart title: ('Sample {1}, bandwidth {2}' format: {
				 patch dataset.
				 ((plot estimates at: patch dataset) bandwidth printShowingDecimalPlaces: 2) }) ].
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Density plot interaction'
]

{ #category : 'examples' }
BpDensityPlot class >> exampleOptions [
	"Show density plots of several bandwidths, stopped at the values, horizontal, and over a histogram."

	<example>
	| figure |
	figure := BpFigure rows: 2 columns: 2.
	figure extent: 900 @ 700.
	figure
		chartAtRow: 1 column: 1 put: (BpChart new
			 addArtist: self instanceNarrowBandwidth;
			 addArtist: self instanceScottBandwidth;
			 addArtist: self instanceWideBandwidth;
			 title: 'bandwidth:';
			 legend;
			 yourself);
		chartAtRow: 1 column: 2 put: (BpChart new
			 addArtist: self instanceCutAtTheValues;
			 title: 'cut: 0, lineStyle: ''--''';
			 yourself);
		chartAtRow: 2 column: 1 put: (BpChart new
			 addArtist: self instanceHorizontal;
			 title: 'orientation: #horizontal, alpha: 0.5';
			 yourself);
		chartAtRow: 2 column: 2 put: (BpChart new
			 addArtist: ((BpHistogram xValues: self twoGroups)
				  bins: 25;
				  density: true;
				  color: ((BpSequentialPalette greys: 9) colorAt: 4);
				  yourself);
			 addArtist: self instanceOverAHistogram;
			 title: 'over a histogram';
			 yourself).
	^ figure show: 'Density plot options'
]

{ #category : 'examples' }
BpDensityPlot class >> exampleThreeSamples [
	"Show the densities of three samples in one chart, with a legend."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart
		addArtist: self instanceThreeSamples;
		legend.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Density plot'
]

{ #category : 'instances' }
BpDensityPlot class >> instanceCutAtTheValues [
	"Answer the density of the two groups stopped at the extreme values (cut: 0) and drawn with a dashed line (see `BpDensityPlot>>cut:`)."

	<sampleInstance>
	^ (self of: self twoGroups)
		  cut: 0;
		  lineStyle: '--';
		  yourself
]

{ #category : 'instances' }
BpDensityPlot class >> instanceHorizontal [
	"Answer the densities of three samples along the y axis, half transparent (see `BpDensityPlot>>orientation:`)."

	<sampleInstance>
	^ (self of: self threeSamples)
		  orientation: #horizontal;
		  alpha: 0.5;
		  yourself
]

{ #category : 'instances' }
BpDensityPlot class >> instanceNarrowBandwidth [
	"Answer the unfilled density of the two groups with a narrow bandwidth (0.1), which follows the values closely (see `BpDensityPlot>>bandwidth:`)."

	<sampleInstance>
	^ self twoGroupsCurveWithBandwidth: 0.1
]

{ #category : 'instances' }
BpDensityPlot class >> instanceOverAHistogram [
	"Answer the density of the two groups as a thick unfilled curve of the first color of set1, to be drawn over a histogram of the same values."

	<sampleInstance>
	^ (self of: self twoGroups)
		  fill: false;
		  lineWidth: 3;
		  color: (BpQualitativePalette set1 colorAt: 1);
		  yourself
]

{ #category : 'instances' }
BpDensityPlot class >> instanceScottBandwidth [
	"Answer the unfilled density of the two groups with the bandwidth of Scott's rule, the default one."

	<sampleInstance>
	^ self twoGroupsCurveWithBandwidth: #scott
]

{ #category : 'instances' }
BpDensityPlot class >> instanceThreeSamples [
	"Answer the densities of three samples of different means and deviations, labeled first, second and third."

	<sampleInstance>
	^ (self of: self threeSamples)
		  label: #( 'first' 'second' 'third' );
		  yourself
]

{ #category : 'instances' }
BpDensityPlot class >> instanceTwoGroups [
	"Answer the density plot of numbers in two groups."

	<sampleInstance>
	^ self of: self twoGroups
]

{ #category : 'instances' }
BpDensityPlot class >> instanceWideBandwidth [
	"Answer the unfilled density of the two groups with a wide bandwidth (1), which merges the groups."

	<sampleInstance>
	^ self twoGroupsCurveWithBandwidth: 1
]

{ #category : 'private - demo' }
BpDensityPlot class >> normals: anInteger mean: aNumber deviation: anotherNumber seed: aSeed [
	"Answer anInteger normal random numbers, always the same ones for aSeed."

	| random |
	random := Random seed: aSeed.
	^ (1 to: anInteger) collect: [ :each | random nextNormalMean: aNumber deviation: anotherNumber ]
]

{ #category : 'instance creation' }
BpDensityPlot class >> of: aCollection [
	"Answer a density plot of aCollection: numbers, or one collection of numbers per dataset."

	^ self new
		  setDatasets: aCollection;
		  yourself
]

{ #category : 'private - demo' }
BpDensityPlot class >> threeSamples [
	"Answer three samples of different means and deviations."

	^ {
		  (self
			   normals: 200
			   mean: 0
			   deviation: 1
			   seed: 1).
		  (self
			   normals: 150
			   mean: 2
			   deviation: 0.7
			   seed: 2).
		  (self
			   normals: 100
			   mean: 3.5
			   deviation: 1.5
			   seed: 3) }
]

{ #category : 'private - demo' }
BpDensityPlot class >> twoGroups [
	"Answer two hundred numbers in two groups, around 0 and around 4."

	^ (self
		   normals: 120
		   mean: 0
		   deviation: 1
		   seed: 1) , (self
		   normals: 80
		   mean: 4
		   deviation: 0.8
		   seed: 2)
]

{ #category : 'private - demo' }
BpDensityPlot class >> twoGroupsCurveWithBandwidth: aNumberOrSymbol [
	"Answer the unfilled density of the two groups with the bandwidth aNumberOrSymbol, labeled with it."

	^ (self of: self twoGroups)
		  bandwidth: aNumberOrSymbol;
		  fill: false;
		  label: aNumberOrSymbol printString;
		  yourself
]

{ #category : 'private - style' }
BpDensityPlot >> areaColorAt: anIndex [
	"Answer the color of an area, made transparent by my alpha (0.3 by default)."

	^ (self colorAt: anIndex) alpha: (alpha ifNil: [ 0.3 ])
]

{ #category : 'accessing - options' }
BpDensityPlot >> bandwidth: aSymbolOrNumber [
	"Set the width of the kernel: #scott (the default), #silverman, or a number multiplying the standard deviation of the data. A smaller one shows more details (see `BpKernelDensity`)."

	bandwidth := aSymbolOrNumber.
	self refresh
]

{ #category : 'accessing - options' }
BpDensityPlot >> color: aColorOrCollection [
	"Set the color of the curves and of their areas: one for all or one per dataset."

	color := aColorOrCollection.
	self refresh
]

{ #category : 'private - style' }
BpDensityPlot >> colorAt: anIndex [
	"Answer the color of a dataset: my color, or the one my chart gave it."

	color ifNotNil: [ ^ self setting: color at: anIndex ].
	^ defaultColors at: anIndex - 1 \\ defaultColors size + 1
]

{ #category : 'axes' }
BpDensityPlot >> colorCount [
	"Answer one color of the palette per dataset."

	^ datasets size
]

{ #category : 'private - computing' }
BpDensityPlot >> compute [

	estimates := datasets collect: [ :each | BpKernelDensity of: each bandwidth: bandwidth ].
	curves := datasets with: estimates collect: [ :values :estimate | self curveOf: values estimate: estimate ]
]

{ #category : 'private - computing' }
BpDensityPlot >> curveOf: aCollectionOfNumbers estimate: aKernelDensity [

	| margin |
	margin := cut * aKernelDensity bandwidth.
	^ (BpArtist linspaceFrom: aCollectionOfNumbers min - margin to: aCollectionOfNumbers max + margin count: points) collect: [ :each |
		  each @ (aKernelDensity densityAt: each) ]
]

{ #category : 'accessing - results' }
BpDensityPlot >> curves [
	"Answer the points of each curve, as value @ density."

	^ curves
]

{ #category : 'accessing - options' }
BpDensityPlot >> cut: aNumber [
	"Set how far each curve goes beyond its smallest and largest values, in widths of the kernel: 3 by default, where it is nearly 0; 0 stops it at the values."

	cut := aNumber.
	self refresh
]

{ #category : 'accessing - results' }
BpDensityPlot >> estimates [
	"Answer the `BpKernelDensity` of each dataset."

	^ estimates
]

{ #category : 'accessing - options' }
BpDensityPlot >> fill: aBoolean [
	"Fill or not the area under each curve (true by default)."

	fill := aBoolean.
	self refresh
]

{ #category : 'initialization' }
BpDensityPlot >> initialize [

	super initialize.
	datasets := #(  ).
	estimates := #(  ).
	curves := #(  ).
	bandwidth := #scott.
	points := 200.
	cut := 3.
	fill := true.
	lineWidth := 1.5.
	lineStyle := #solid.
	orientation := #vertical
]

{ #category : 'axes' }
BpDensityPlot >> labelAt: anIndex [
	"Answer the label of a dataset, nil without one. A single label is the one of the first dataset."

	(self isMany: label) ifTrue: [ ^ label at: anIndex ].
	^ anIndex = 1
		  ifTrue: [ label ]
		  ifFalse: [ nil ]
]

{ #category : 'axes' }
BpDensityPlot >> legendEntries [
	"Answer, for each dataset with a label, its label and a rectangle painted as its area and its curve."

	^ (1 to: curves size) select: [ :index | (self labelAt: index) isNotNil ] thenCollect: [ :index |
		  (self labelAt: index) asString -> (BlElement new
			   extent: 20 @ 10;
			   in: [ :swatch | self paintSwatch: swatch dataset: index ];
			   yourself) ]
]

{ #category : 'accessing - options' }
BpDensityPlot >> lineStyle: aSymbolOrString [
	"Set the line style of the curves: #solid (the default), #dashed, #dashdot, #dotted, or a string such as '--'."

	lineStyle := self class lineStyleOf: aSymbolOrString.
	self refresh
]

{ #category : 'accessing - options' }
BpDensityPlot >> lineWidth: aNumberOfPoints [
	"Set the width of the curves in points (1.5 by default)."

	lineWidth := aNumberOfPoints.
	self refresh
]

{ #category : 'private - computing' }
BpDensityPlot >> newAreaAt: anIndex [

	| area curve |
	curve := curves at: anIndex.
	area := self newPolygonThrough: { (curve first x @ 0) } , curve , { (curve last x @ 0) } closed: true dataset: anIndex.
	area background: (self areaColorAt: anIndex).
	^ area
]

{ #category : 'private - computing' }
BpDensityPlot >> newCurveAt: anIndex [

	| curve |
	curve := self newPolygonThrough: (curves at: anIndex) closed: false dataset: anIndex.
	curve border: (self strokeColor: (self colorAt: anIndex) width: lineWidth style: lineStyle).
	^ curve
]

{ #category : 'private - computing' }
BpDensityPlot >> newPatches [
	"Answer the areas, then the curves above them."

	| areas |
	areas := fill
		         ifTrue: [ (1 to: curves size) collect: [ :each | self newAreaAt: each ] ]
		         ifFalse: [ #(  ) ].
	^ areas , ((1 to: curves size) collect: [ :each | self newCurveAt: each ])
]

{ #category : 'private - computing' }
BpDensityPlot >> newPolygonThrough: somePoints closed: aBoolean dataset: anIndex [
	"Answer a polygon through somePoints, given as value @ density, with my handlers."

	| polygon |
	polygon := BpPolygonPatch new
		           artist: self;
		           dataset: anIndex;
		           closed: aBoolean;
		           dataVertices: (somePoints collect: [ :each | self oriented: each ]);
		           yourself.
	patchHandlers do: [ :each | self addHandler: each to: polygon ].
	^ polygon
]

{ #category : 'accessing - options' }
BpDensityPlot >> orientation: aSymbol [
	"Set #vertical (the default), the densities being on the y axis, or #horizontal, the densities being on the x axis."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - computing' }
BpDensityPlot >> oriented: aPoint [
	"Answer aPoint, given as value @ density, in data coordinates."

	^ orientation = #horizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'private - style' }
BpDensityPlot >> paintSwatch: anElement dataset: anIndex [

	fill ifTrue: [ anElement background: (self areaColorAt: anIndex) ].
	anElement border: (self strokeColor: (self colorAt: anIndex) width: lineWidth style: lineStyle)
]

{ #category : 'accessing - options' }
BpDensityPlot >> points: anInteger [
	"Set at how many points each density is estimated (200 by default)."

	points := anInteger.
	self refresh
]

{ #category : 'initialization' }
BpDensityPlot >> setDatasets: aCollection [

	datasets := (aCollection isEmpty or: [ aCollection first isNumber ])
		            ifTrue: [ { aCollection asArray } ]
		            ifFalse: [ aCollection collect: [ :each | each asArray ] as: Array ].
	self refresh
]

{ #category : 'axes' }
BpDensityPlot >> stickyValuesOn: anAxis [
	"Answer 0 on the axis of the densities: the areas stand on it."

	^ anAxis = #x = (orientation = #horizontal)
		  ifTrue: [ #( 0 ) ]
		  ifFalse: [ #(  ) ]
]
