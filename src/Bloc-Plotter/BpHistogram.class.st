"
I am a histogram, added by `BpChart>>hist:`. I bin one or several datasets with a `BpHistogramBinning`, compute the values of the bins (density, stacking, cumulative sums), and build the patches that draw them: bars (`BpRectanglePatch`) or outlines (`BpPolygonPatch`). `whenPatch:do:` adds an interaction handler to all my patches.

## Examples

```
BpHistogram exampleHistTypes.
BpHistogram exampleMultiHist.
BpHistogram exampleMultiHistStyles.
BpHistogram exampleHist.
BpHistogram exampleOptions.
BpHistogram exampleInteraction
```

## Design Rationale

- My settings take symbols (`histType: #stepfilled`, `bins: #auto`, `lineStyle: #dashed`). The results are `counts`, `binEdges` and `patches`.
- The datasets share their edges; stacked values are running sums, normalized together when density is true; without `relativeWidth:`, side by side bars take 0.8 of their bin; an unfilled step is drawn with the color of its dataset, not with `faceColor:`.
- I have one slot and setter per option, hence many slots and methods.

## Usage

1. `BpChart>>hist:` creates me with the data (`x:`) and adds me to the chart (see `BpArtist`), which takes one color of its palette per dataset (`colorCount`).
2. My chart reads my `stickyValuesOn:` (the bottoms of the bins) and `logAxes` (the value axis when `log:` is true).

- The style setters take one value or one per dataset.

## Implementation Notes

- Not supported yet: hatches, the data keyword, the `stone` bin strategy.
"
Class {
	#name : 'BpHistogram',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'datasets',
		'bins',
		'range',
		'density',
		'weights',
		'cumulative',
		'bottom',
		'align',
		'orientation',
		'log',
		'color',
		'stacked',
		'fill',
		'edges',
		'tops',
		'lineWidth',
		'edgeColor',
		'relativeWidth',
		'lineStyle',
		'histType',
		'faceColor'
	],
	#category : 'Bloc-Plotter-Histogram',
	#package : 'Bloc-Plotter',
	#tag : 'Histogram'
}

{ #category : 'constants' }
BpHistogram class >> dashArrays [
	"Answer the dash pattern of each line style (#solid '-', #dashed '--', #dotted ':', #dashdot '-.')."

	^ Dictionary new
		  at: #solid put: #(  );
		  at: #dashed put: #( 6 3 );
		  at: #dotted put: #( 1.5 2.5 );
		  at: #dashdot put: #( 6 2.5 1.5 2.5 );
		  yourself
]

{ #category : 'examples' }
BpHistogram class >> exampleHist [
	"Reproduce the two first figures of the gallery 'Histograms': two distributions, then bars colored by height and a density with percent labels."

	<example>
	BpFigure instanceHistogramTwoDistributions show: 'hist: two distributions'.
	^ BpFigure instanceHistogramColorByHeight show: 'hist: color by height'
]

{ #category : 'examples' }
BpHistogram class >> exampleHistTypes [
	"Reproduce the gallery 'Demo of the histogram function''s different histtype settings': stepfilled, step, barstacked and bars on unequal bins."

	<example>
	^ BpFigure instanceHistTypes show: 'histogram_histtypes'
]

{ #category : 'examples' }
BpHistogram class >> exampleInteraction [
	"Interaction handlers on the bars of a histogram: hover a bar to highlight it, click it to see its bin and count."

	<example>
	^ BpFigure instanceInteractiveHistogram show: 'Histogram interaction'
]

{ #category : 'examples' }
BpHistogram class >> exampleMultiHist [
	"Reproduce the gallery 'Plot multiple data sets as histograms': bars with a legend, stacked bars, stacked unfilled steps, and datasets of different sizes."

	<example>
	^ BpFigure instanceMultiHist show: 'histogram_multihist'
]

{ #category : 'examples' }
BpHistogram class >> exampleMultiHistStyles [
	"Reproduce the second part of the gallery 'Plot multiple data sets as histograms': one edge color, face color, line width or line style per dataset."

	<example>
	^ BpFigure instanceMultiHistStyles show: 'histogram_multihist styles'
]

{ #category : 'examples' }
BpHistogram class >> exampleOptions [
	"Show the other options of `BpHistogram`: cumulative, orientation, log, align, bottom, bin strategies, range and weights."

	<example>
	^ BpFigure instanceHistogramOptions show: 'hist options'
]

{ #category : 'constants' }
BpHistogram class >> histTypes [

	^ #( #bar #barstacked #step #stepfilled )
]

{ #category : 'instances' }
BpHistogram class >> instanceStepFilled [
	"Answer a filled step histogram of 100 normal samples, in a new chart."

	<sampleInstance>
	| random |
	random := Random seed: 19680801.
	^ ((BpChart new
		    extent: 400 @ 300;
		    yourself) hist: ((1 to: 100) collect: [ :each | random nextNormalMean: 200 deviation: 25 ]))
		  bins: 20;
		  histType: #stepfilled;
		  yourself
]

{ #category : 'private - computing' }
BpHistogram >> accumulate: aRow [
	"Answer the running sums of aRow, from the last bin when cumulative is negative. Densities are first multiplied by the bin widths, so that the last sum is 1."

	| values sum sums |
	values := density
		          ifTrue: [ aRow with: self binWidths collect: [ :value :width | value * width ] ]
		          ifFalse: [ aRow ].
	self accumulatesBackward ifTrue: [ values := values reversed ].
	sum := 0.
	sums := values collect: [ :each | sum := sum + each ].
	^ self accumulatesBackward
		  ifTrue: [ sums reversed ]
		  ifFalse: [ sums ]
]

{ #category : 'private - computing' }
BpHistogram >> accumulatesBackward [

	^ cumulative isNumber and: [ cumulative < 0 ]
]

{ #category : 'accessing - options' }
BpHistogram >> align [

	^ align
]

{ #category : 'accessing - options' }
BpHistogram >> align: aSymbol [
	"Set where bars are centered: #left (on the left edge of their bin), #mid (in the middle) or #right (on the right edge)."

	align := aSymbol.
	self refresh
]

{ #category : 'private - patches' }
BpHistogram >> alignOffsetFor: aBinWidth [

	^ align = #mid
		  ifTrue: [ aBinWidth / 2 ]
		  ifFalse: [
			  align = #right
				  ifTrue: [ aBinWidth ]
				  ifFalse: [ 0 ] ]
]

{ #category : 'axes' }
BpHistogram >> allPatches [

	^ patches flatCollect: [ :each | each ]
]

{ #category : 'private - computing' }
BpHistogram >> allWeights [

	weights ifNil: [ ^ nil ].
	^ (1 to: datasets size) flatCollect: [ :index | self weightsAt: index ]
]

{ #category : 'accessing - style' }
BpHistogram >> alpha [

	^ alpha
]

{ #category : 'private - patches' }
BpHistogram >> barGeometry [
	"Answer, per bin, the width of the bars (#widths), the shift from one dataset to the next (#steps, 0 when stacked) and the offset of the center of the first bar from the left edge (#offsets)."

	| count ratio totals widths steps offsets |
	count := datasets size.
	ratio := self barWidthRatio.
	totals := self binWidths.
	(histType = #bar and: [ self isStacked not ])
		ifTrue: [
			widths := totals collect: [ :each | ratio * each / count ].
			steps := widths.
			offsets := totals collect: [ :each | -0.5 * ratio * each * (1 - (1 / count)) ] ]
		ifFalse: [
			widths := totals collect: [ :each | ratio * each ].
			steps := totals collect: [ :each | 0 ].
			offsets := totals collect: [ :each | 0 ] ].
	^ Dictionary new
		  at: #widths put: widths;
		  at: #steps put: steps;
		  at: #offsets put: (offsets with: totals collect: [ :offset :each | offset + (self alignOffsetFor: each) ]);
		  yourself
]

{ #category : 'private - patches' }
BpHistogram >> barWidthRatio [
	"Answer the part of its bin a bar group takes: my relative width, or 0.8 for several datasets side by side, 1 otherwise."

	relativeWidth ifNotNil: [ ^ relativeWidth min: 1 max: 0 ].
	^ (datasets size > 1 and: [ self isStacked not ])
		  ifTrue: [ 0.8 ]
		  ifFalse: [ 1 ]
]

{ #category : 'accessing - results' }
BpHistogram >> binEdges [
	"Answer the edges of the bins, shared by all datasets."

	^ edges
]

{ #category : 'private - computing' }
BpHistogram >> binWidths [

	^ (1 to: edges size - 1) collect: [ :index | (edges at: index + 1) - (edges at: index) ]
]

{ #category : 'accessing - options' }
BpHistogram >> bins [

	^ bins
]

{ #category : 'accessing - options' }
BpHistogram >> bins: anIntegerOrEdgesOrStrategy [
	"Set the bins: a number of equal bins (10 by default), the edges, or a strategy name (#auto, #fd, #doane, #scott, #rice, #sturges, #sqrt). See BpHistogramBinning."

	bins := anIntegerOrEdgesOrStrategy.
	self refresh
]

{ #category : 'accessing - options' }
BpHistogram >> bottom [

	^ bottom
]

{ #category : 'accessing - options' }
BpHistogram >> bottom: aNumberOrCollection [
	"Set where the bars start: one value, or one value per bin."

	bottom := aNumberOrCollection.
	self refresh
]

{ #category : 'private - computing' }
BpHistogram >> bottomValues [
	"Answer where the patches start, one value per bin."

	bottom ifNil: [ ^ Array new: edges size - 1 withAll: 0 ].
	bottom isNumber ifTrue: [ ^ Array new: edges size - 1 withAll: bottom ].
	^ bottom asArray
]

{ #category : 'accessing - style' }
BpHistogram >> color [

	^ color
]

{ #category : 'accessing - style' }
BpHistogram >> color: aColorOrCollection [
	"Set the color of the datasets: one color, or one per dataset. Without it, the datasets take the next colors of the palette of my chart."

	color := aColorOrCollection.
	self refresh
]

{ #category : 'private - style' }
BpHistogram >> colorAt: aDatasetIndex [

	^ (self setting: color at: aDatasetIndex) ifNil: [ defaultColors at: aDatasetIndex - 1 \\ defaultColors size + 1 ]
]

{ #category : 'axes' }
BpHistogram >> colorCount [
	"Answer one color of the palette per dataset."

	^ datasets size
]

{ #category : 'private - computing' }
BpHistogram >> compute [
	"Compute the bin edges and the values of the bins (tops): counts of each dataset, normalized per dataset when not stacked, summed then normalized together when stacked, accumulated when cumulative."

	datasets ifEmpty: [
		edges := #(  ).
		tops := #(  ).
		^ self ].
	edges := (BpHistogramBinning bins: bins)
		         range: range;
		         edgesFor: (datasets flatCollect: [ :each | each ]) weights: self allWeights.
	tops := datasets withIndexCollect: [ :each :index | BpHistogramBinning countsOf: each weights: (self weightsAt: index) in: edges ].
	(density and: [ self isStacked not ]) ifTrue: [ tops := tops collect: [ :each | BpHistogramBinning density: each in: edges ] ].
	self isStacked ifTrue: [
		tops := self runningSumsOf: tops.
		density ifTrue: [ tops := self stackedDensityOf: tops ] ].
	self isCumulative ifTrue: [ tops := tops collect: [ :each | self accumulate: each ] ]
]

{ #category : 'accessing - results' }
BpHistogram >> counts [
	"Answer the values of the bins: an array for one dataset, an array of arrays for several. Stacked datasets answer their running sums."

	^ self isSingleDataset
		  ifTrue: [ tops ifEmpty: [ #(  ) ] ifNotEmpty: [ tops first ] ]
		  ifFalse: [ tops ]
]

{ #category : 'accessing - options' }
BpHistogram >> cumulative [

	^ cumulative
]

{ #category : 'accessing - options' }
BpHistogram >> cumulative: aBooleanOrNumber [
	"When true, each bin also counts the bins before it; a negative number accumulates from the last bin."

	cumulative := aBooleanOrNumber.
	self refresh
]

{ #category : 'accessing - data' }
BpHistogram >> datasets [

	^ datasets
]

{ #category : 'accessing - options' }
BpHistogram >> density [

	^ density
]

{ #category : 'accessing - options' }
BpHistogram >> density: aBoolean [
	"When true, show a probability density: each bin is divided by the total count and by its width, so that the area is 1."

	density := aBoolean.
	self refresh
]

{ #category : 'accessing - style' }
BpHistogram >> edgeColor [

	^ edgeColor
]

{ #category : 'accessing - style' }
BpHistogram >> edgeColor: aColorOrCollection [
	"Set the outline color of the patches, one or one per dataset. Bars have no outline by default."

	edgeColor := aColorOrCollection.
	self refresh
]

{ #category : 'private - style' }
BpHistogram >> edgeColorAt: aDatasetIndex [
	"Answer the outline color of a dataset, nil for none: steps are outlined with their color, bars only when edgeColor: is given."

	^ (self setting: edgeColor at: aDatasetIndex) ifNil: [ histType = #step ifTrue: [ self colorAt: aDatasetIndex ] ]
]

{ #category : 'accessing - style' }
BpHistogram >> faceColor [

	^ faceColor
]

{ #category : 'accessing - style' }
BpHistogram >> faceColor: aColorOrCollection [
	"Set the fill color of the patches, one or one per dataset, instead of their color."

	faceColor := aColorOrCollection.
	self refresh
]

{ #category : 'private - style' }
BpHistogram >> faceColorAt: aDatasetIndex [
	"Answer the fill color of a dataset, nil when not filled. An unfilled step ignores faceColor:."

	self isFilled ifFalse: [ ^ nil ].
	^ (self setting: faceColor at: aDatasetIndex) ifNil: [ self colorAt: aDatasetIndex ]
]

{ #category : 'accessing - style' }
BpHistogram >> fill [

	^ fill
]

{ #category : 'accessing - style' }
BpHistogram >> fill: aBooleanOrNil [
	"Set whether the patches are filled. By default steps are not filled, the other types are."

	fill := aBooleanOrNil.
	self refresh
]

{ #category : 'accessing - options' }
BpHistogram >> histType [

	^ histType
]

{ #category : 'accessing - options' }
BpHistogram >> histType: aSymbol [
	"Set how the histogram is drawn: #bar (side by side bars), #barstacked (stacked bars), #step (an outline) or #stepfilled (a filled outline)."

	(self class histTypes includes: aSymbol) ifFalse: [ ^ self error: 'Unknown histtype: ' , aSymbol printString ].
	histType := aSymbol.
	self refresh
]

{ #category : 'initialization' }
BpHistogram >> initialize [

	super initialize.
	datasets := #(  ).
	bins := 10.
	density := false.
	cumulative := false.
	histType := #bar.
	align := #mid.
	orientation := #vertical.
	log := false.
	stacked := false.
	lineWidth := 1.
	lineStyle := #solid.
	edges := #(  ).
	tops := #(  )
]

{ #category : 'private - computing' }
BpHistogram >> isCumulative [

	^ cumulative isNumber
		  ifTrue: [ cumulative ~= 0 ]
		  ifFalse: [ cumulative ]
]

{ #category : 'private - style' }
BpHistogram >> isFilled [
	"Answer whether my patches are filled: as asked by fill, otherwise all types but #step."

	^ fill ifNil: [ histType ~= #step ]
]

{ #category : 'accessing - options' }
BpHistogram >> isHorizontal [

	^ orientation = #horizontal
]

{ #category : 'accessing - data' }
BpHistogram >> isSingleDataset [
	"Answer whether x is one collection of numbers rather than a collection of datasets."

	^ x isNil or: [ x isEmpty or: [ x first isNumber ] ]
]

{ #category : 'accessing - options' }
BpHistogram >> isStacked [

	^ stacked or: [ histType = #barstacked ]
]

{ #category : 'accessing - style' }
BpHistogram >> label [

	^ label
]

{ #category : 'private - style' }
BpHistogram >> labelAt: aDatasetIndex [

	^ self setting: label at: aDatasetIndex
]

{ #category : 'axes' }
BpHistogram >> legendEntries [
	"Answer, for each dataset with a label, its label and a swatch drawn like its patches."

	tops ifEmpty: [ ^ #(  ) ].
	^ (1 to: datasets size)
	select: [ :index | (self labelAt: index) isNotNil ]
	thenCollect: [ :index | (self labelAt: index) asString -> (self newSwatchFor: index) ]
]

{ #category : 'accessing - style' }
BpHistogram >> lineStyle [

	^ lineStyle
]

{ #category : 'accessing - style' }
BpHistogram >> lineStyle: aSymbolOrCollection [
	"Set the style of the outlines, one or one per dataset: #solid, #dashed, #dotted or #dashdot."

	lineStyle := aSymbolOrCollection.
	self refresh
]

{ #category : 'accessing - style' }
BpHistogram >> lineWidth [

	^ lineWidth
]

{ #category : 'accessing - style' }
BpHistogram >> lineWidth: aNumberOrCollection [
	"Set the width of the outlines in points (1 by default), one or one per dataset."

	lineWidth := aNumberOrCollection.
	self refresh
]

{ #category : 'accessing - options' }
BpHistogram >> log [

	^ log
]

{ #category : 'accessing - options' }
BpHistogram >> log: aBoolean [
	"When true, the value axis of my chart uses a log scale."

	log := aBoolean.
	self refresh
]

{ #category : 'axes' }
BpHistogram >> logAxes [
	"With log true, my value axis is on a log scale."

	log ifFalse: [ ^ #(  ) ].
	^ self isHorizontal
		  ifTrue: [ #( #x ) ]
		  ifFalse: [ #( #y ) ]
]

{ #category : 'private - patches' }
BpHistogram >> newBarAt: aBinIndex dataset: aDatasetIndex amount: aNumber bounds: aRectangle [

	| bar |
	bar := BpRectanglePatch new
		       artist: self;
		       dataset: aDatasetIndex;
		       bin: aBinIndex;
		       amount: aNumber;
		       dataBounds: aRectangle;
		       yourself.
	self style: bar.
	^ bar
]

{ #category : 'private - patches' }
BpHistogram >> newBars [
	"Answer the bars of each dataset: side by side in each bin for #bar, on top of each other when stacked."

	| geometry bottoms |
	geometry := self barGeometry.
	bottoms := self bottomValues.
	^ tops withIndexCollect: [ :row :datasetIndex |
		  | bars |
		  bars := row withIndexCollect: [ :top :binIndex |
			          | center half height |
			          center := (edges at: binIndex) + ((geometry at: #offsets) at: binIndex)
			                    + (datasetIndex - 1 * ((geometry at: #steps) at: binIndex)).
			          half := ((geometry at: #widths) at: binIndex) / 2.
			          height := self isStacked
				                    ifTrue: [ top - (bottoms at: binIndex) ]
				                    ifFalse: [ top ].
			          self
				          newBarAt: binIndex
				          dataset: datasetIndex
				          amount: height
				          bounds: (Rectangle encompassing: {
					           (self oriented: center - half @ (bottoms at: binIndex)).
					           (self oriented: center + half @ ((bottoms at: binIndex) + height)) }) ].
		  self isStacked ifTrue: [ bottoms := row copy ].
		  bars ]
]

{ #category : 'private - computing' }
BpHistogram >> newPatches [
	"Answer, for each dataset, the patches drawing it: one bar per bin, or one outline."

	tops ifEmpty: [ ^ #(  ) ].
	^ (#( #bar #barstacked ) includes: histType)
		  ifTrue: [ self newBars ]
		  ifFalse: [ self newSteps ]
]

{ #category : 'private - patches' }
BpHistogram >> newStepFor: aDatasetIndex top: aTopRow base: aBaseRow shift: aNumber [

	| points step |
	points := OrderedCollection new.
	points add: edges first @ aBaseRow first.
	aTopRow withIndexDo: [ :each :index |
		points
			add: (edges at: index) @ each;
			add: (edges at: index + 1) @ each ].
	points add: edges last @ aBaseRow last.
	self isFilled ifTrue: [
		aBaseRow size to: 1 by: -1 do: [ :index |
			points
				add: (edges at: index + 1) @ (aBaseRow at: index);
				add: (edges at: index) @ (aBaseRow at: index) ] ].
	step := BpPolygonPatch new
		        artist: self;
		        dataset: aDatasetIndex;
		        closed: self isFilled;
		        dataVertices: (points collect: [ :each | self oriented: each x + aNumber @ each y ]);
		        yourself.
	self style: step.
	^ step
]

{ #category : 'private - patches' }
BpHistogram >> newSteps [
	"Answer one outline per dataset: it starts and ends on its base (the bottom, or the previous dataset when stacked)."

	| shift bottoms base |
	shift := align = #left
		         ifTrue: [ edges second - edges first / -2 ]
		         ifFalse: [
			         align = #right
				         ifTrue: [ edges second - edges first / 2 ]
				         ifFalse: [ 0 ] ].
	bottoms := self bottomValues.
	base := bottoms.
	^ tops withIndexCollect: [ :row :datasetIndex |
		  | top step |
		  top := row with: bottoms collect: [ :value :each | value + each ].
		  step := self
			          newStepFor: datasetIndex
			          top: top
			          base: base
			          shift: shift.
		  self isStacked ifTrue: [ base := top ].
		  { step } ]
]

{ #category : 'axes' }
BpHistogram >> newSwatchFor: aDatasetIndex [

	| swatch |
	swatch := BlElement new
		          extent: 20 @ 10;
		          yourself.
	self paint: swatch dataset: aDatasetIndex.
	^ swatch
]

{ #category : 'accessing - options' }
BpHistogram >> orientation [

	^ orientation
]

{ #category : 'accessing - options' }
BpHistogram >> orientation: aSymbol [
	"Set #vertical bars (the default) or #horizontal ones."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - patches' }
BpHistogram >> oriented: aPoint [
	"Answer aPoint, given as (bin position @ value), in data coordinates: swapped for horizontal histograms."

	^ self isHorizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'private - style' }
BpHistogram >> paint: anElement dataset: aDatasetIndex [
	"Give anElement the fill, outline and opacity of a dataset."

	| face edge |
	face := self faceColorAt: aDatasetIndex.
	edge := self edgeColorAt: aDatasetIndex.
	anElement background: (face ifNil: [ Color transparent ]).
	edge ifNotNil: [
		anElement border: (BlBorder builder
			 paint: edge;
			 width: (self setting: lineWidth at: aDatasetIndex) * self class pixelsPerPoint;
			 dashArray: (self class dashArrays at: (self setting: lineStyle at: aDatasetIndex));
			 build) ].
	alpha ifNotNil: [ anElement opacity: alpha ]
]

{ #category : 'accessing' }
BpHistogram >> patches [
	"Answer the patches drawing the histogram: for one dataset its patches, for several an array of them per dataset."

	^ self isSingleDataset
		  ifTrue: [ patches ifEmpty: [ #(  ) ] ifNotEmpty: [ patches first ] ]
		  ifFalse: [ patches ]
]

{ #category : 'accessing - options' }
BpHistogram >> range [

	^ range
]

{ #category : 'accessing - options' }
BpHistogram >> range: aCollectionOrNil [
	"Set the lower and upper values covered by the bins; values outside are ignored."

	range := aCollectionOrNil.
	self refresh
]

{ #category : 'accessing - options' }
BpHistogram >> relativeWidth [

	^ relativeWidth
]

{ #category : 'accessing - options' }
BpHistogram >> relativeWidth: aNumberOrNil [
	"Set the width of the bars as a fraction of their bin. Without it, bars fill their bin, or 0.8 of it when several datasets are side by side."

	relativeWidth := aNumberOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpHistogram >> runningSumsOf: aCollectionOfRows [

	| sum |
	sum := nil.
	^ aCollectionOfRows collect: [ :each | sum := sum ifNil: [ each copy ] ifNotNil: [ sum with: each collect: [ :a :b | a + b ] ] ]
]

{ #category : 'accessing - options' }
BpHistogram >> stacked [

	^ stacked
]

{ #category : 'accessing - options' }
BpHistogram >> stacked: aBoolean [
	"When true, the datasets are drawn on top of each other."

	stacked := aBoolean.
	self refresh
]

{ #category : 'private - computing' }
BpHistogram >> stackedDensityOf: aCollectionOfRows [
	"Normalize stacked rows so that the area of their sum (the last row) is 1."

	| total widths |
	total := aCollectionOfRows last inject: 0 into: [ :sum :each | sum + each ].
	total = 0 ifTrue: [ ^ aCollectionOfRows ].
	widths := self binWidths.
	^ aCollectionOfRows collect: [ :row | row with: widths collect: [ :value :width | value / width / total ] ]
]

{ #category : 'axes' }
BpHistogram >> stickyValuesOn: anAxis [
	"Answer the values autoscaling margins must not go past on anAxis: the bottoms of the bins on the value axis."

	^ anAxis = #y = self isHorizontal not
		  ifTrue: [ self bottomValues asSet asArray ]
		  ifFalse: [ #(  ) ]
]

{ #category : 'private - style' }
BpHistogram >> style: aPatch [
	"Give aPatch the look and the interaction handlers of its dataset."

	self paint: aPatch dataset: aPatch dataset.
	patchHandlers do: [ :each | self addHandler: each to: aPatch ]
]

{ #category : 'accessing - data' }
BpHistogram >> weights [

	^ weights
]

{ #category : 'accessing - data' }
BpHistogram >> weights: aCollectionOrNil [
	"Set a weight for each value, shaped as x: each value counts for its weight instead of 1."

	weights := aCollectionOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpHistogram >> weightsAt: anIndex [

	weights ifNil: [ ^ nil ].
	^ self isSingleDataset
		  ifTrue: [ weights ]
		  ifFalse: [ weights at: anIndex ]
]

{ #category : 'accessing - data' }
BpHistogram >> x [

	^ x
]

{ #category : 'accessing - data' }
BpHistogram >> x: aCollection [
	"Set the data: a collection of numbers, or a collection of such collections (one dataset each, of any size)."

	x := aCollection.
	datasets := (aCollection isEmpty or: [ aCollection first isNumber ])
		            ifTrue: [ { aCollection asArray } ]
		            ifFalse: [ aCollection asArray collect: [ :each | each asArray ] ].
	self refresh
]
