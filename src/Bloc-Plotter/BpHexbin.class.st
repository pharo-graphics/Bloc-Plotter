"
I am a hexbin of a `BpChart`: I cover the points with a grid of hexagons (`BpHexagonGrid`) and color each `BpHexagonPatch` by the number of points it holds. It shows the density of points too many to be seen apart in a scatter plot. Given a third number per point (`c:`), a hexagon shows these numbers reduced to one, their average by default.

## Examples

```
BpHexbin examplePlotType.
BpHexbin exampleHexbinDemo.
BpHexbin exampleOptions.
BpHexbin exampleInteraction
```

## Design Rationale

- `gridSize:`, `region:`, `minCount:`, `reduction:`, `xScale:` and `yScale:` change the hexagons; `bins:`, `colorMap:`, `vMin:`, `vMax:`, `edgeColors:`, `lineWidths:` and `alpha:` only their colors and edges, and do not count the points again.
- The hexagons without points are shown, with the first color of the color map. `minCount: 1` hides them. They are always hidden with `c:`, having no number to show, and transparent with `bins: #log`, 0 having no logarithm.
- `bins:` with an integer or a collection of edges colors by steps: the amounts between the same two edges have the same color.
- The limits of the chart follow my region, without margins; the hexagons on its sides are cut by the plot area.
- On a log scale the hexagons are regular in the logarithms of the data.

## Usage

1. `BpHexbin class>>x:y:` creates me with my points, and `BpChart>>addArtist:` adds me to a chart (see `BpArtist`).
2. `BpChart>>addColorBarFor:` tells my counts with a `BpColorBar`.
3. My patches answer their `center`, `count` and `amount`, which interaction handlers given to `whenPatch:do:` use. `counts` and `amounts` hold the ones of the whole grid.

## Implementation Notes

- My amounts are set to nil when they must be computed again (`rebin`).
- Not supported yet: the marginal densities along the axes, and color scales other than linear and logarithmic.

## Invariants and Assumptions

- x, y and c have the same size, and a log scale needs positive numbers: an error is raised otherwise.
- The points out of `region:` are ignored.
"
Class {
	#name : 'BpHexbin',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'y',
		'c',
		'gridSize',
		'bins',
		'region',
		'xScale',
		'yScale',
		'minCount',
		'reduction',
		'colorScale',
		'edgeColors',
		'lineWidths',
		'grid',
		'counts',
		'amounts'
	],
	#category : 'Bloc-Plotter-Hexbin',
	#package : 'Bloc-Plotter',
	#tag : 'Hexbin'
}

{ #category : 'private - demo' }
BpHexbin class >> correlatedPoints: anInteger slope: aSlope deviation: aNumber [
	"Answer anInteger random points around a line through the origin: x is normal, and y is off the line by a normal amount."

	| random |
	random := Random seed: 19680801.
	^ (1 to: anInteger) collect: [ :each |
		  | x |
		  x := random nextNormalMean: 0 deviation: 1.
		  x @ (aSlope * x + (random nextNormalMean: 0 deviation: aNumber)) ]
]

{ #category : 'private - demo' }
BpHexbin class >> demoPoints [
	"Answer the 100000 points of the gallery hexbin demo, around a line of slope 3 shifted up by 2."

	^ (self correlatedPoints: 100000 slope: 3 deviation: 4) collect: [ :each | each + (0 @ 2) ]
]

{ #category : 'examples' }
BpHexbin class >> exampleHexbinDemo [
	"Reproduce the gallery 'Hexagonal binned plot': 100000 points, on a linear and on a logarithmic color scale."

	<example>
	| figure |
	figure := BpFigure rows: 1 columns: 2.
	figure extent: 900 @ 400.
	figure
		chartAtRow: 1 column: 1 put: (BpChart new
			 addArtist: self instanceLinearColors;
			 title: 'Hexagon binning';
			 yourself);
		chartAtRow: 1 column: 2 put: (BpChart new
			 addArtist: self instanceLogColors;
			 title: 'With a log color scale';
			 yourself).
	^ figure show: 'hexbin_demo'
]

{ #category : 'examples' }
BpHexbin class >> exampleInteraction [
	"Interaction handlers on the hexagons: hover a hexagon to outline it, click it to see its center and number of points in the title."

	<example>
	| figure chart hexbin |
	figure := BpFigure new.
	chart := BpChart new.
	chart title: 'Click a hexagon'.
	hexbin := chart addArtist: self instanceClickable.
	hexbin
		whenPatch: BlMouseEnterEvent
		do: [ :event :hexagon | hexagon border: (BlBorder paint: (BpQualitativePalette set1 colorAt: 1) width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :hexagon | hexagon border: (BlBorder paint: hexagon background paint width: 1) ];
		whenPatch: BlClickEvent do: [ :event :hexagon |
			chart title: ('{1} points around ({2}, {3})' format: {
				 hexagon count.
				 (hexagon center x printShowingDecimalPlaces: 2).
				 (hexagon center y printShowingDecimalPlaces: 2) }) ].
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Hexbin interaction'
]

{ #category : 'examples' }
BpHexbin class >> exampleOptions [
	"Show hexbins with few points hidden, colors in steps, the average of a third variable, and a log axis."

	<example>
	| figure |
	figure := BpFigure rows: 2 columns: 2.
	figure extent: 900 @ 800.
	figure
		chartAtRow: 1 column: 1 put: (BpChart new
			 addArtist: self instanceMinCount;
			 title: 'minCount: 5';
			 yourself);
		chartAtRow: 1 column: 2 put: (BpChart new
			 addArtist: self instanceFourBins;
			 title: 'bins: 4';
			 yourself);
		chartAtRow: 2 column: 1 put: (BpChart new
			 addArtist: self instanceAverageOfSine;
			 title: 'c: sin(x)';
			 yourself);
		chartAtRow: 2 column: 2 put: (BpChart new
			 addArtist: self instanceLogXAxis;
			 title: 'xScale: #log';
			 yourself).
	^ figure show: 'Hexbin options'
]

{ #category : 'examples' }
BpHexbin class >> examplePlotType [
	"Reproduce the plot type hexbin(x, y, C): five thousand points in a chart of fixed limits."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart
		addArtist: self instanceFiveThousandPoints;
		xLimits: #( -2 2 );
		yLimits: #( -3 3 ).
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'hexbin(x, y, C)'
]

{ #category : 'private - demo' }
BpHexbin class >> infernoOf: aCollectionOfPoints [
	"Answer a hexbin of aCollectionOfPoints of 50 hexagons across, colored by the inferno map."

	^ (self ofPoints: aCollectionOfPoints)
		  gridSize: 50;
		  colorMap: BpInterpolatedPalette inferno;
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceAverageOfSine [
	"Answer a hexbin colored by the average of sin(x) over the points of each hexagon (see `BpHexbin>>c:`)."

	<sampleInstance>
	| points |
	points := self optionPoints.
	^ (self ofPoints: points)
		  gridSize: 25;
		  c: (points collect: [ :each | each x sin ]);
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceClickable [
	"Answer a hexbin of two thousand points, 20 hexagons across, hiding the empty ones."

	<sampleInstance>
	^ (self ofPoints: (self correlatedPoints: 2000 slope: 1.2 deviation: 0.5))
		  gridSize: 20;
		  minCount: 1;
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceCorrelatedPoints [
	"Answer a hexbin of five hundred points around a line."

	<sampleInstance>
	^ (self ofPoints: (self correlatedPoints: 500 slope: 1.2 deviation: 0.5))
		  gridSize: 15;
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceFiveThousandPoints [
	"Plot types: hexbin(x, y, C), five thousand points around a line, 20 hexagons across."

	<sampleInstance>
	^ (self ofPoints: self optionPoints)
		  gridSize: 20;
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceFourBins [
	"Answer a hexbin whose colors go in four steps, with dark outlines (see `BpHexbin>>bins:`)."

	<sampleInstance>
	^ (self ofPoints: self optionPoints)
		  gridSize: 25;
		  bins: 4;
		  edgeColors: ((BpSequentialPalette greys: 9) colorAt: 1);
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceLinearColors [
	"Gallery: Hexagonal binned plot (hexbin_demo), first chart: 100000 points in hexagons colored on a linear scale."

	<sampleInstance>
	^ self infernoOf: self demoPoints
]

{ #category : 'instances' }
BpHexbin class >> instanceLogColors [
	"Gallery: Hexagonal binned plot (hexbin_demo), second chart: the same points colored on a logarithmic scale (bins: #log, see `BpHexbin>>bins:`)."

	<sampleInstance>
	^ (self infernoOf: self demoPoints)
		  bins: #log;
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceLogXAxis [
	"Answer a hexbin whose hexagons are regular on a log x axis."

	<sampleInstance>
	^ (self ofPoints: (self optionPoints collect: [ :each | (10 raisedTo: each x) @ each y ]))
		  gridSize: 25;
		  xScale: #log;
		  yourself
]

{ #category : 'instances' }
BpHexbin class >> instanceMinCount [
	"Answer a hexbin hiding the hexagons of fewer than five points (see `BpHexbin>>minCount:`)."

	<sampleInstance>
	^ (self ofPoints: self optionPoints)
		  gridSize: 25;
		  minCount: 5;
		  yourself
]

{ #category : 'private - demo' }
BpHexbin class >> ofPoints: aCollectionOfPoints [
	"Answer a hexbin of aCollectionOfPoints."

	^ self x: (aCollectionOfPoints collect: [ :each | each x ]) y: (aCollectionOfPoints collect: [ :each | each y ])
]

{ #category : 'private - demo' }
BpHexbin class >> optionPoints [
	"Answer the 5000 points of the hexbin option demos, around a line of slope 1.2."

	^ self correlatedPoints: 5000 slope: 1.2 deviation: 1 / 3
]

{ #category : 'instance creation' }
BpHexbin class >> x: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	aCollectionOfNumbers size = anotherCollectionOfNumbers size ifFalse: [ ^ self error: 'x and y must be the same size' ].
	^ self new
		  setX: aCollectionOfNumbers y: anotherCollectionOfNumbers;
		  yourself
]

{ #category : 'accessing - results' }
BpHexbin >> amounts [
	"Answer the number shown by each hexagon of my grid, nil for the hidden ones."

	^ amounts
]

{ #category : 'private - computing' }
BpHexbin >> bin [
	"Compute my grid, the points of each hexagon and what it shows."

	| indexes |
	grid := self newGrid.
	counts := Array new: grid size withAll: 0.
	indexes := x with: y collect: [ :eachX :eachY | grid indexOf: (self scaled: eachX @ eachY) ].
	indexes do: [ :each | each isZero ifFalse: [ counts at: each put: (counts at: each) + 1 ] ].
	amounts := c
		           ifNil: [ counts collect: [ :each | each >= (minCount ifNil: [ 0 ]) ifTrue: [ each ] ] ]
		           ifNotNil: [ self reducedValuesAt: indexes ]
]

{ #category : 'private - computing' }
BpHexbin >> binEdgesOf: aCollectionOfNumbers [
	"Answer the numbers where the color changes, nil when it changes with each number."

	| low high |
	(bins isNil or: [ bins = #log ]) ifTrue: [ ^ nil ].
	(bins isCollection or: [ aCollectionOfNumbers isEmpty ]) ifTrue: [ ^ bins ].
	low := aCollectionOfNumbers min.
	high := aCollectionOfNumbers max.
	^ (0 to: bins - 2) collect: [ :each | low + (high - low * (each / (bins - 1))) ]
]

{ #category : 'accessing - options' }
BpHexbin >> bins: anObject [
	"Set how the amounts are turned into colors: nil along the color map, #log by their order of magnitude, an integer in so many steps of equal width, a collection in the steps between its numbers."

	bins := anObject.
	colorScale scale: (bins = #log
		 ifTrue: [ #log ]
		 ifFalse: [ #linear ]).
	self refresh
]

{ #category : 'accessing - options' }
BpHexbin >> c: aCollectionOfNumbersOrNil [
	"Set a number per point: each hexagon shows its numbers reduced to one (see reduction:) instead of its number of points."

	(aCollectionOfNumbersOrNil isNil or: [ aCollectionOfNumbersOrNil size = x size ]) ifFalse: [
		^ self error: 'c must be the same size as x and y' ].
	c := aCollectionOfNumbersOrNil.
	self rebin
]

{ #category : 'private - computing' }
BpHexbin >> check: aCollectionOfNumbers scale: aSymbol [

	(#( #linear #log ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown scale: ' , aSymbol printString ].
	(aSymbol = #log and: [ aCollectionOfNumbers anySatisfy: [ :each | each <= 0 ] ]) ifTrue: [
		self error: 'A log scale needs positive numbers' ]
]

{ #category : 'axes' }
BpHexbin >> colorCount [
	"My colors come from my color map."

	^ 0
]

{ #category : 'accessing - options' }
BpHexbin >> colorMap: aPaletteOrBlock [
	"Set what maps the amounts to colors: a `BpInterpolatedPalette`, or a block from a fraction between 0 and 1 to a color."

	colorScale colorMap: aPaletteOrBlock.
	self refresh
]

{ #category : 'axes' }
BpHexbin >> colorScale [
	"Answer what maps my amounts, or their steps, to colors."

	^ colorScale
]

{ #category : 'private - computing' }
BpHexbin >> compute [
	"Bin the points again when the data or the grid changed, and fit my colors to the amounts."

	amounts ifNil: [ self bin ].
	colorScale fitTo: (self levelsOf: (amounts select: [ :each | each isNotNil ]))
]

{ #category : 'accessing - results' }
BpHexbin >> counts [
	"Answer the number of points in each hexagon of my grid."

	^ counts
]

{ #category : 'private - computing' }
BpHexbin >> dataPointFor: aPoint [
	"Answer the data coordinates of aPoint of my grid."

	^ (self unscale: aPoint x by: xScale) @ (self unscale: aPoint y by: yScale)
]

{ #category : 'private - computing' }
BpHexbin >> dataRegion [
	"Answer the rectangle of my points, as scaled. Equal values get a region around them."

	| xEnds yEnds |
	x ifEmpty: [ ^ 0 @ 0 corner: 1 @ 1 ].
	xEnds := self widened: (self scale: x min by: xScale) to: (self scale: x max by: xScale).
	yEnds := self widened: (self scale: y min by: yScale) to: (self scale: y max by: yScale).
	^ xEnds first @ yEnds first corner: xEnds last @ yEnds last
]

{ #category : 'accessing - options' }
BpHexbin >> edgeColors: aColorOrNil [
	"Set the edge color of the hexagons. Without it (nil) the edge has the color of the hexagon; `Color transparent` draws no edge."

	edgeColors := aColorOrNil.
	self refresh
]

{ #category : 'accessing - results' }
BpHexbin >> grid [
	"Answer my grid, in the logarithms of the data on a log scale."

	^ grid
]

{ #category : 'accessing - options' }
BpHexbin >> gridSize: anIntegerOrPoint [
	"Set the number of hexagons in a row, their height making them regular in a square region, or the number of them in a row and in a column."

	gridSize := anIntegerOrPoint.
	self rebin
]

{ #category : 'initialization' }
BpHexbin >> initialize [

	super initialize.
	x := #(  ).
	y := #(  ).
	gridSize := 100.
	xScale := #linear.
	yScale := #linear.
	reduction := [ :values | values average ].
	colorScale := BpColorScale new.
	lineWidths := 1
]

{ #category : 'private - computing' }
BpHexbin >> levelOf: aNumber among: aCollectionOfEdges [
	"Answer the step of aNumber: how many of aCollectionOfEdges are below it."

	^ aCollectionOfEdges count: [ :each | each < aNumber ]
]

{ #category : 'private - computing' }
BpHexbin >> levelsOf: aCollectionOfNumbers [
	"Answer what the colors of aCollectionOfNumbers, all the amounts shown, are taken from: the numbers themselves, or their steps."

	^ (self binEdgesOf: aCollectionOfNumbers)
		  ifNil: [ aCollectionOfNumbers ]
		  ifNotNil: [ :edges | aCollectionOfNumbers collect: [ :each | self levelOf: each among: edges ] ]
]

{ #category : 'accessing - options' }
BpHexbin >> lineWidths: aNumber [
	"Set the width of the edges in points (1 by default)."

	lineWidths := aNumber.
	self refresh
]

{ #category : 'axes' }
BpHexbin >> logAxes [

	^ (xScale = #log
		   ifTrue: [ #( #x ) ]
		   ifFalse: [ #(  ) ]) , (yScale = #log
		   ifTrue: [ #( #y ) ]
		   ifFalse: [ #(  ) ])
]

{ #category : 'accessing - options' }
BpHexbin >> minCount: anIntegerOrNil [
	"Show only the hexagons of at least anIntegerOrNil points. With nil the hexagons without points are shown too, unless c: was given."

	minCount := anIntegerOrNil.
	self rebin
]

{ #category : 'private - computing' }
BpHexbin >> newGrid [

	| columns rows |
	columns := gridSize isPoint
		           ifTrue: [ gridSize x ]
		           ifFalse: [ gridSize ].
	rows := gridSize isPoint
		        ifTrue: [ gridSize y ]
		        ifFalse: [ (gridSize / 3 sqrt) truncated max: 1 ].
	^ BpHexagonGrid
		  region: (region ifNil: [ self dataRegion ] ifNotNil: [ (self scaled: region origin) corner: (self scaled: region corner) ])
		  columns: columns
		  rows: rows
]

{ #category : 'private - computing' }
BpHexbin >> newHexagonAt: anIndex level: aNumber [
	"Answer the patch of the hexagon at anIndex, whose color is the one of aNumber."

	| patch |
	patch := BpHexagonPatch new
		         artist: self;
		         center: (self dataPointFor: (grid centerAt: anIndex));
		         count: (counts at: anIndex);
		         amount: (amounts at: anIndex);
		         dataVertices: ((grid cornersAt: anIndex) collect: [ :each | self dataPointFor: each ]);
		         yourself.
	self paint: patch with: (colorScale colorFor: aNumber).
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'private - computing' }
BpHexbin >> newPatches [

	| shown levels |
	shown := (1 to: grid size) select: [ :each | (amounts at: each) isNotNil ].
	levels := self levelsOf: (shown collect: [ :each | amounts at: each ]).
	^ shown with: levels collect: [ :index :level | self newHexagonAt: index level: level ]
]

{ #category : 'private - style' }
BpHexbin >> paint: aPatch with: aColor [

	| edge |
	edge := edgeColors ifNil: [ aColor ].
	aPatch
		background: (self colorOf: aColor);
		border: (BlBorder paint: (self colorOf: edge) width: lineWidths * self class pixelsPerPoint)
]

{ #category : 'private - computing' }
BpHexbin >> rebin [

	amounts := nil.
	self refresh
]

{ #category : 'private - computing' }
BpHexbin >> reducedValuesAt: aCollectionOfIndexes [
	"Answer the numbers of c: of each hexagon reduced to one, nil for the hexagons with too few points. aCollectionOfIndexes holds the hexagon of each point."

	| groups least |
	groups := (1 to: grid size) collect: [ :each | OrderedCollection new ].
	aCollectionOfIndexes with: c do: [ :index :value | index isZero ifFalse: [ (groups at: index) add: value ] ].
	least := (minCount ifNil: [ 1 ]) max: 1.
	^ groups collect: [ :each | each size >= least ifTrue: [ reduction value: each ] ]
]

{ #category : 'accessing - options' }
BpHexbin >> reduction: aBlock [
	"Set the block answering the amount of a hexagon from the numbers of c: of its points (their average by default)."

	reduction := aBlock.
	self rebin
]

{ #category : 'accessing - options' }
BpHexbin >> region: aRectangleOrNil [
	"Set the region covered by the hexagons, in data coordinates; the points out of it are ignored. Nil takes the one of the data."

	region := aRectangleOrNil.
	self rebin
]

{ #category : 'axes' }
BpHexbin >> requiredValuesOn: anAxis [
	"Answer the ends of my region."

	| first last |
	first := self dataPointFor: (grid centerAt: 1).
	last := self dataPointFor: (grid centerAt: grid lastIndexOfRegion).
	^ anAxis = #x
		  ifTrue: [
			  {
				  first x.
				  last x } ]
		  ifFalse: [
			  {
				  first y.
				  last y } ]
]

{ #category : 'private - computing' }
BpHexbin >> scale: aNumber by: aSymbol [

	^ aSymbol = #log
		  ifTrue: [ aNumber log: 10 ]
		  ifFalse: [ aNumber ]
]

{ #category : 'private - computing' }
BpHexbin >> scaled: aPoint [

	^ (self scale: aPoint x by: xScale) @ (self scale: aPoint y by: yScale)
]

{ #category : 'initialization' }
BpHexbin >> setX: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	x := aCollectionOfNumbers asArray.
	y := anotherCollectionOfNumbers asArray.
	self rebin
]

{ #category : 'axes' }
BpHexbin >> showsNumbersByColors [

	^ true
]

{ #category : 'axes' }
BpHexbin >> stickyValuesOn: anAxis [

	^ self requiredValuesOn: anAxis
]

{ #category : 'private - computing' }
BpHexbin >> unscale: aNumber by: aSymbol [

	^ aSymbol = #log
		  ifTrue: [ 10 raisedTo: aNumber ]
		  ifFalse: [ aNumber ]
]

{ #category : 'accessing - options' }
BpHexbin >> vMax: aNumberOrNil [
	"Set the amount mapped to the end of the color map (the largest one by default)."

	colorScale vMax: aNumberOrNil.
	self refresh
]

{ #category : 'accessing - options' }
BpHexbin >> vMin: aNumberOrNil [
	"Set the amount mapped to the start of the color map (the smallest one by default)."

	colorScale vMin: aNumberOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpHexbin >> widened: aLow to: aHigh [
	"Answer aLow and aHigh, moved apart by a tenth when they are equal."

	aHigh - aLow > (1.0e-15 * (aLow abs max: aHigh abs)) ifTrue: [
		^ {
			  aLow.
			  aHigh } ].
	aLow isZero ifTrue: [ ^ #( -0.1 0.1 ) ].
	^ {
		  (aLow - (aLow abs * 0.1)).
		  (aHigh + (aHigh abs * 0.1)) }
]

{ #category : 'accessing - options' }
BpHexbin >> xScale: aSymbol [
	"Set the scale of x, #linear or #log, for my hexagons and my chart."

	self check: x scale: aSymbol.
	xScale := aSymbol.
	self rebin
]

{ #category : 'accessing - options' }
BpHexbin >> yScale: aSymbol [
	"Set the scale of y, #linear or #log, for my hexagons and my chart."

	self check: y scale: aSymbol.
	yScale := aSymbol.
	self rebin
]
