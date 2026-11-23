"
I am a box plot of one or several datasets, the artist of matplotlib `Axes.boxplot`: for each dataset, a box from the first to the third quartile crossed by the median, whiskers to the most extreme data within 1.5 interquartile ranges, caps at their ends, and the fliers beyond them as markers. I get the numbers from `BpBoxStatistics` and draw them with `BpPolygonPatch` lines and boxes and `BpMarkerPatch` fliers and means.

## Examples

```
BpBoxPlot examplePlotType
```

```
BpBoxPlot scriptBoxPlotDemo
```

## Design Rationale

- My settings are the matplotlib keyword arguments in camelCase: `notch:`, `whiskers:` (a factor of the interquartile range or a pair of percentiles), `positions:`, `widths:`, `capWidths:`, `orientation:` (`#vertical` or `#horizontal`, matplotlib `vert`), `flierSymbol:` (matplotlib `sym`, a format such as `'gD'`, `''` hides the fliers), `patchArtist:`, `showMeans:`, `meanLine:`, `showFliers:`, `showCaps:`, `showBox:`, `tickLabels:`.
- Styles are dictionaries over defaults, as the matplotlib `boxprops`, `medianprops`, `whiskerprops`, `capprops`, `flierprops` and `meanprops`: keys such as `#color`, `#faceColor`, `#edgeColor`, `#lineWidth`, `#lineStyle`, `#marker`, `#markerSize`. The defaults are the matplotlib ones (black box and whiskers, median in `'C1'`, mean as a `'C2'` triangle). The color `'none'` is transparent.
- I keep the patches of each part apart (`parts` at `#boxes`, `#medians`, `#whiskers`, `#caps`, `#fliers`, `#means`), the dictionary matplotlib `boxplot` answers, and draw them in that layered order: whiskers and caps under the boxes, medians and means over them.
- I work in (position @ value) and swap the coordinates once, in `oriented:`, so horizontal boxes need no other code.
- As matplotlib `manage_ticks`, I put a tick at each position (`managedTicksOn:`) and require half a unit around the extreme positions (`requiredValuesOn:`), which autoscaling does not go past. Ticks fixed with `xTicks:` win.
- I do not use the color cycle (`colorCount` is 0) and I am drawn above the grid.

## Usage

1. `BpAxes>>boxPlot:` creates me with a collection of numbers (one box) or a collection of such collections (one box per collection).
2. My setters rebuild me: `compute` asks `BpBoxStatistics` for the statistics of each dataset, `newPatches` builds the parts.
3. `statistics` answers them, one per dataset; each patch knows its `dataset` index, so a handler given to `whenPatch:do:` finds the box it belongs to.

## Implementation Notes

- The notched box is a ten-vertex polygon narrowed to half its width at the median, between `confidenceLow` and `confidenceHigh`.
- Default widths follow matplotlib: 0.15 times the span of the positions, clipped between 0.15 and 0.5.

## Invariants and Assumptions

- Each dataset has at least one number. `positions:` and per-dataset settings have one entry per dataset.
"
Class {
	#name : 'BpBoxPlot',
	#superclass : 'BpArtist',
	#instVars : [
		'datasets',
		'statistics',
		'positions',
		'widths',
		'capWidths',
		'whiskers',
		'notch',
		'orientation',
		'flierSymbol',
		'patchArtist',
		'showMeans',
		'meanLine',
		'showFliers',
		'showCaps',
		'showBox',
		'boxProps',
		'medianProps',
		'whiskerProps',
		'capProps',
		'flierProps',
		'meanProps',
		'tickLabels',
		'parts'
	],
	#category : 'Bloc-Plotter-Box',
	#package : 'Bloc-Plotter',
	#tag : 'Box'
}

{ #category : 'constants' }
BpBoxPlot class >> defaultBoxProps [
	"Answer the style of the boxes, as the matplotlib rcParams boxplot.boxprops (the face is the patch color, used when the boxes are filled)."

	^ {
		  (#color -> 'black').
		  (#faceColor -> 'C0').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultCapProps [

	^ {
		  (#color -> 'black').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultFlierProps [
	"Answer the style of the fliers, as the matplotlib rcParams boxplot.flierprops: unfilled black circles."

	^ {
		  (#marker -> 'o').
		  (#markerFaceColor -> 'none').
		  (#markerEdgeColor -> 'black').
		  (#markerSize -> 6).
		  (#markerEdgeWidth -> 1) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultMeanProps [
	"Answer the style of the means, as the matplotlib rcParams boxplot.meanprops: green triangles, or a dashed green line."

	^ {
		  (#marker -> '^').
		  (#markerFaceColor -> 'C2').
		  (#markerEdgeColor -> 'C2').
		  (#markerSize -> 6).
		  (#markerEdgeWidth -> 1).
		  (#color -> 'C2').
		  (#lineWidth -> 1).
		  (#lineStyle -> #dashed) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultMedianProps [

	^ {
		  (#color -> 'C1').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultWhiskerProps [

	^ {
		  (#color -> 'black').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'examples' }
BpBoxPlot class >> exampleBoxPlotDemo [
	"Answer the first figure of the matplotlib gallery Boxplots (statistics/boxplot_demo): the same data drawn as a basic, a notched, a horizontal box plot, with other flier symbols, without fliers and with shorter whiskers."

	<sampleInstance>
	| random data figure settings |
	random := Random seed: 19680801.
	data := ((1 to: 50) collect: [ :each | random next * 100 ]) , (Array new: 25 withAll: 50)
	        , ((1 to: 10) collect: [ :each | random next * 100 + 100 ]) , ((1 to: 10) collect: [ :each | random next * -100 ]).
	figure := BpFigure rows: 2 columns: 3.
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

{ #category : 'examples' }
BpBoxPlot class >> exampleInteractiveBoxPlot [
	"Answer a figure of three filled boxes: hovering a part outlines it in red, clicking a part shows the statistics of its box in the title."

	<sampleInstance>
	| figure axes boxPlot names |
	names := #( 'A' 'B' 'C' ).
	figure := BpFigure new.
	axes := figure axes first.
	boxPlot := (axes boxPlot: (self exampleThreeBoxes statistics collect: [ :each | each values ]))
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

{ #category : 'examples' }
BpBoxPlot class >> examplePlotType [
	"Answer the figure of the plot type page of matplotlib (plot_types/stats/boxplot_plot): three filled boxes at 2, 4 and 6 without fliers, with white medians and edges."

	<sampleInstance>
	| random columns figure axes |
	random := Random seed: 10.
	columns := #( #( 3 1.25 ) #( 5 1 ) #( 4 1.25 ) ) collect: [ :meanAndDeviation |
		           (1 to: 100) collect: [ :each | random nextNormalMean: meanAndDeviation first deviation: meanAndDeviation last ] ].
	figure := BpFigure new.
	axes := figure axes first.
	(axes boxPlot: columns)
		positions: #( 2 4 6 );
		widths: 1.5;
		patchArtist: true;
		showFliers: false;
		medianProps: {
			(#color -> 'white').
			(#lineWidth -> 0.5) } asDictionary;
		boxProps: {
			(#faceColor -> 'C0').
			(#edgeColor -> 'white').
			(#lineWidth -> 0.5) } asDictionary;
		whiskerProps: {
			(#color -> 'C0').
			(#lineWidth -> 1.5) } asDictionary;
		capProps: {
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

{ #category : 'examples' }
BpBoxPlot class >> exampleThreeBoxes [
	"Answer a box plot of three normal samples."

	<sampleInstance>
	| random |
	random := Random seed: 10.
	^ self new
		  x: (#( 3 5 4 ) collect: [ :mean | (1 to: 100) collect: [ :each | random nextNormalMean: mean deviation: 1 ] ]);
		  yourself
]

{ #category : 'script' }
BpBoxPlot class >> scriptBoxPlotDemo [
	"Show the six variants of the matplotlib gallery Boxplots: basic, notched, other flier symbols, no fliers, horizontal, shorter whiskers."

	<example>
	^ self exampleBoxPlotDemo show: 'boxplot_demo'
]

{ #category : 'script' }
BpBoxPlot class >> scriptInteraction [
	"Show three boxes reacting to the mouse: hovering outlines a part, clicking shows the statistics of its box."

	<example>
	^ self exampleInteractiveBoxPlot show: 'boxplot interaction'
]

{ #category : 'script' }
BpBoxPlot class >> scriptPlotType [
	"Show the figure of the box plot type page of matplotlib."

	<example>
	^ self examplePlotType show: 'boxplot'
]

{ #category : 'private - computing' }
BpBoxPlot >> addPartsOf: aStatistics at: aPosition width: aWidth dataset: anIndex [

	| half capHalf medianHalf |
	half := aWidth / 2.
	capHalf := (capWidths ifNil: [ aWidth / 2 ] ifNotNil: [ self setting: capWidths at: anIndex ]) / 2.
	medianHalf := notch
		              ifTrue: [ half / 2 ]
		              ifFalse: [ half ].
	(parts at: #whiskers)
		add: (self
			 newLine: {
				 (aPosition @ aStatistics q1).
				 (aPosition @ aStatistics whiskerLow) }
			 props: (self props: whiskerProps defaults: self class defaultWhiskerProps)
			 dataset: anIndex);
		add: (self
			 newLine: {
				 (aPosition @ aStatistics q3).
				 (aPosition @ aStatistics whiskerHigh) }
			 props: (self props: whiskerProps defaults: self class defaultWhiskerProps)
			 dataset: anIndex).
	showCaps ifTrue: [
		(parts at: #caps)
			add: (self
				 newLine: {
					 (aPosition - capHalf @ aStatistics whiskerLow).
					 (aPosition + capHalf @ aStatistics whiskerLow) }
				 props: (self props: capProps defaults: self class defaultCapProps)
				 dataset: anIndex);
			add: (self
				 newLine: {
					 (aPosition - capHalf @ aStatistics whiskerHigh).
					 (aPosition + capHalf @ aStatistics whiskerHigh) }
				 props: (self props: capProps defaults: self class defaultCapProps)
				 dataset: anIndex) ].
	showBox ifTrue: [
		(parts at: #boxes) add: (self
			 newBoxOf: aStatistics
			 at: aPosition
			 half: half
			 dataset: anIndex) ].
	(parts at: #medians) add: (self
		 newLine: {
			 (aPosition - medianHalf @ aStatistics median).
			 (aPosition + medianHalf @ aStatistics median) }
		 props: (self props: medianProps defaults: self class defaultMedianProps)
		 dataset: anIndex).
	showMeans ifTrue: [
		(parts at: #means) add: (self
			 newMeanOf: aStatistics
			 at: aPosition
			 half: half
			 dataset: anIndex) ].
	self hasFliers ifTrue: [
		(parts at: #fliers) addAll:
			(aStatistics fliers collect: [ :each | self newMarkerAt: aPosition @ each props: self flierStyle dataset: anIndex ]) ]
]

{ #category : 'accessing' }
BpBoxPlot >> boxProps: aDictionary [
	"Set the style of the boxes: #color or #edgeColor, #faceColor, #lineWidth (points), #lineStyle."

	boxProps := aDictionary.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> capProps: aDictionary [
	"Set the style of the caps: #color, #lineWidth (points), #lineStyle."

	capProps := aDictionary.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> capWidths: aNumberOrCollection [
	"Set the width of the caps in data units (half the width of the boxes by default)."

	capWidths := aNumberOrCollection.
	self refresh
]

{ #category : 'axes' }
BpBoxPlot >> colorCount [
	"Answer 0: box plots are drawn in the colors of their props, not with the color cycle."

	^ 0
]

{ #category : 'private - computing' }
BpBoxPlot >> compute [

	statistics := datasets collect: [ :each | BpBoxStatistics of: each whiskers: whiskers ]
]

{ #category : 'accessing' }
BpBoxPlot >> flierProps: aDictionary [
	"Set the style of the fliers: #marker, #markerFaceColor, #markerEdgeColor, #markerSize and #markerEdgeWidth (points)."

	flierProps := aDictionary.
	self refresh
]

{ #category : 'private - computing' }
BpBoxPlot >> flierStyle [
	"Answer the style of the fliers: my flier props, then the marker and color of my flier symbol, which colors both the face and the edge as in matplotlib."

	| style symbol |
	style := self props: flierProps defaults: self class defaultFlierProps.
	flierSymbol ifNil: [ ^ style ].
	symbol := BpLine formatPartsOf: flierSymbol.
	symbol at: #marker ifPresent: [ :each | style at: #marker put: each ].
	symbol at: #color ifPresent: [ :each |
		style
			at: #markerFaceColor put: each;
			at: #markerEdgeColor put: each ].
	^ style
]

{ #category : 'accessing' }
BpBoxPlot >> flierSymbol: aString [
	"Set the marker and color of the fliers with a matplotlib format string such as 'gD' or 'rs' (matplotlib sym); '' hides the fliers."

	flierSymbol := aString.
	self refresh
]

{ #category : 'private - computing' }
BpBoxPlot >> hasFliers [

	^ showFliers and: [ flierSymbol ~= '' ]
]

{ #category : 'initialization' }
BpBoxPlot >> initialize [

	super initialize.
	datasets := #(  ).
	statistics := #(  ).
	whiskers := BpBoxStatistics defaultWhiskers.
	notch := false.
	orientation := #vertical.
	patchArtist := false.
	showMeans := false.
	meanLine := false.
	showFliers := true.
	showCaps := true.
	showBox := true.
	boxProps := Dictionary new.
	medianProps := Dictionary new.
	whiskerProps := Dictionary new.
	capProps := Dictionary new.
	flierProps := Dictionary new.
	meanProps := Dictionary new.
	parts := Dictionary new
]

{ #category : 'axes' }
BpBoxPlot >> isAboveGrid [

	^ true
]

{ #category : 'accessing' }
BpBoxPlot >> isHorizontal [

	^ orientation = #horizontal
]

{ #category : 'axes' }
BpBoxPlot >> legendEntries [
	"Answer my label with a filled box when my boxes are filled, otherwise with my median line, as matplotlib."

	(label isNil or: [ statistics isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> self newSwatch) }
]

{ #category : 'axes' }
BpBoxPlot >> managedTicksOn: anAxis [
	"Answer a tick at each of my positions on my position axis, labeled by my tick labels or the position, as matplotlib manage_ticks."

	| labels |
	(anAxis ~= self positionAxis or: [ datasets isEmpty ]) ifTrue: [ ^ nil ].
	labels := tickLabels ifNil: [ BpTickLocator labelsFor: self positions ].
	^ self positions with: labels asArray collect: [ :position :text | position -> text asString ]
]

{ #category : 'accessing' }
BpBoxPlot >> meanLine: aBoolean [
	"Show the means as dashed lines across the boxes instead of markers (when showMeans: true)."

	meanLine := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> meanProps: aDictionary [
	"Set the style of the means: the marker keys of flierProps:, or #color, #lineWidth and #lineStyle for mean lines."

	meanProps := aDictionary.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> medianProps: aDictionary [
	"Set the style of the medians: #color, #lineWidth (points), #lineStyle."

	medianProps := aDictionary.
	self refresh
]

{ #category : 'private - computing' }
BpBoxPlot >> newBoxOf: aStatistics at: aPosition half: aHalfWidth dataset: anIndex [

	| left right inner points style box |
	left := aPosition - aHalfWidth.
	right := aPosition + aHalfWidth.
	inner := aHalfWidth / 2.
	points := notch
		          ifTrue: [
			          {
				          (left @ aStatistics q1).
				          (right @ aStatistics q1).
				          (right @ aStatistics confidenceLow).
				          (aPosition + inner @ aStatistics median).
				          (right @ aStatistics confidenceHigh).
				          (right @ aStatistics q3).
				          (left @ aStatistics q3).
				          (left @ aStatistics confidenceHigh).
				          (aPosition - inner @ aStatistics median).
				          (left @ aStatistics confidenceLow) } ]
		          ifFalse: [
			          {
				          (left @ aStatistics q1).
				          (right @ aStatistics q1).
				          (right @ aStatistics q3).
				          (left @ aStatistics q3) } ].
	style := self props: boxProps defaults: self class defaultBoxProps.
	box := self newPolygon: points closed: true dataset: anIndex.
	box
		background: (patchArtist
			 ifTrue: [ self paintOf: (style at: #faceColor) ]
			 ifFalse: [ Color transparent ]);
		border: (self
			 strokeColor: (self paintOf: (style at: #edgeColor ifAbsent: [ style at: #color ]))
			 width: (style at: #lineWidth)
			 style: (self class lineStyleOf: (style at: #lineStyle))).
	^ box
]

{ #category : 'private - computing' }
BpBoxPlot >> newLine: somePoints props: aStyle dataset: anIndex [

	| line |
	line := self newPolygon: somePoints closed: false dataset: anIndex.
	line
		background: Color transparent;
		border: (self
			 strokeColor: (self paintOf: (aStyle at: #color))
			 width: (aStyle at: #lineWidth)
			 style: (self class lineStyleOf: (aStyle at: #lineStyle))).
	^ line
]

{ #category : 'private - computing' }
BpBoxPlot >> newMarkerAt: aPoint props: aStyle dataset: anIndex [

	| marker patch |
	marker := BpMarker on: (aStyle at: #marker).
	patch := BpMarkerPatch new
		         artist: self;
		         dataset: anIndex;
		         index: anIndex;
		         dataPoint: (self oriented: aPoint);
		         area: (aStyle at: #markerSize) squared;
		         marker: marker;
		         yourself.
	patch updateShape.
	patch
		background: (marker isFilled
			 ifTrue: [ self paintOf: (aStyle at: #markerFaceColor) ]
			 ifFalse: [ Color transparent ]);
		border:
			(BlBorder paint: (self paintOf: (aStyle at: #markerEdgeColor)) width: (aStyle at: #markerEdgeWidth) * self class pixelsPerPoint).
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'private - computing' }
BpBoxPlot >> newMeanOf: aStatistics at: aPosition half: aHalfWidth dataset: anIndex [

	| style |
	style := self props: meanProps defaults: self class defaultMeanProps.
	^ meanLine
		  ifTrue: [
			  self
				  newLine: {
					  (aPosition - aHalfWidth @ aStatistics mean).
					  (aPosition + aHalfWidth @ aStatistics mean) }
				  props: style
				  dataset: anIndex ]
		  ifFalse: [ self newMarkerAt: aPosition @ aStatistics mean props: style dataset: anIndex ]
]

{ #category : 'private - computing' }
BpBoxPlot >> newPatches [
	"Build the parts of each box, then answer them in drawing order: whiskers and caps below the boxes, medians and means above them, fliers last."

	| roles positionList widthList |
	roles := #( #whiskers #caps #boxes #medians #means #fliers ).
	parts := Dictionary new.
	roles do: [ :each | parts at: each put: OrderedCollection new ].
	positionList := self positions.
	widthList := self widths.
	statistics withIndexDo: [ :stats :index |
		self
			addPartsOf: stats
			at: (positionList at: index)
			width: (widthList at: index)
			dataset: index ].
	roles do: [ :each | parts at: each put: (parts at: each) asArray ].
	^ roles flatCollect: [ :each | parts at: each ]
]

{ #category : 'private - computing' }
BpBoxPlot >> newPolygon: somePoints closed: aBoolean dataset: anIndex [
	"Answer a patch through somePoints, given as (position @ value)."

	| patch |
	patch := BpPolygonPatch new
		         artist: self;
		         dataset: anIndex;
		         closed: aBoolean;
		         dataVertices: (somePoints collect: [ :each | self oriented: each ]);
		         yourself.
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'axes' }
BpBoxPlot >> newSwatch [

	| style |
	patchArtist ifTrue: [
		style := self props: boxProps defaults: self class defaultBoxProps.
		^ BlElement new
			  extent: 20 @ 10;
			  background: (self paintOf: (style at: #faceColor));
			  border: (BlBorder
				   paint: (self paintOf: (style at: #edgeColor ifAbsent: [ style at: #color ]))
				   width: (style at: #lineWidth) * self class pixelsPerPoint);
			  yourself ].
	style := self props: medianProps defaults: self class defaultMedianProps.
	^ BlElement new
		  geometry: (BlLineGeometry from: 0 @ 5 to: 20 @ 5);
		  border: (self
			   strokeColor: (self paintOf: (style at: #color))
			   width: (style at: #lineWidth)
			   style: (self class lineStyleOf: (style at: #lineStyle)));
		  extent: 20 @ 10;
		  yourself
]

{ #category : 'accessing' }
BpBoxPlot >> notch: aBoolean [
	"Draw notched boxes, whose notches show the confidence interval of the median."

	notch := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> orientation: aSymbol [
	"Set the orientation of the boxes: #vertical (the default) or #horizontal."

	(#( #vertical #horizontal ) includes: aSymbol asSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol asSymbol.
	self refresh
]

{ #category : 'private - computing' }
BpBoxPlot >> oriented: aPoint [
	"Answer aPoint, given as (position @ value), in data coordinates: swapped for horizontal boxes."

	^ self isHorizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'accessing' }
BpBoxPlot >> parts [
	"Answer my patches by role, as the dictionary answered by matplotlib boxplot: #boxes, #medians, #whiskers, #caps, #fliers and #means."

	^ parts
]

{ #category : 'accessing' }
BpBoxPlot >> patchArtist: aBoolean [
	"Fill the boxes (with the face color of the box props, the first color of the cycle by default) instead of drawing only their outline."

	patchArtist := aBoolean.
	self refresh
]

{ #category : 'axes' }
BpBoxPlot >> positionAxis [

	^ self isHorizontal
		  ifTrue: [ #y ]
		  ifFalse: [ #x ]
]

{ #category : 'accessing' }
BpBoxPlot >> positions [

	^ positions ifNil: [ (1 to: datasets size) asArray ]
]

{ #category : 'accessing' }
BpBoxPlot >> positions: aCollectionOfNumbers [
	"Set where the boxes are on the position axis, one per box (1, 2, 3, ... by default)."

	aCollectionOfNumbers size = datasets size ifFalse: [ ^ self error: 'One position per box is needed' ].
	positions := aCollectionOfNumbers asArray.
	self refresh
]

{ #category : 'private - computing' }
BpBoxPlot >> props: aDictionary defaults: someDefaults [
	"Answer someDefaults overridden by aDictionary."

	^ someDefaults copy
		  addAll: aDictionary;
		  yourself
]

{ #category : 'axes' }
BpBoxPlot >> requiredValuesOn: anAxis [
	"Answer half a unit around my extreme positions on my position axis, so that even a single box looks right, as matplotlib."

	(anAxis ~= self positionAxis or: [ datasets isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ {
		  (self positions min - 0.5).
		  (self positions max + 0.5) }
]

{ #category : 'accessing' }
BpBoxPlot >> showBox: aBoolean [

	showBox := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> showCaps: aBoolean [

	showCaps := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> showFliers: aBoolean [

	showFliers := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> showMeans: aBoolean [

	showMeans := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> statistics [
	"Answer the statistics of each box (`BpBoxStatistics`)."

	^ statistics
]

{ #category : 'axes' }
BpBoxPlot >> stickyValuesOn: anAxis [
	"Answer the values my required ones on my position axis: autoscaling adds no margin beyond them."

	^ self requiredValuesOn: anAxis
]

{ #category : 'accessing' }
BpBoxPlot >> tickLabels: aCollectionOfStrings [
	"Set the labels of the ticks at the positions of the boxes (the positions by default)."

	tickLabels := aCollectionOfStrings.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> whiskerProps: aDictionary [
	"Set the style of the whiskers: #color, #lineWidth (points), #lineStyle."

	whiskerProps := aDictionary.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> whiskers: aNumberOrPair [
	"Set how far the whiskers reach (matplotlib whis): a number of interquartile ranges from the box (1.5 by default), or the two percentiles where they end."

	whiskers := aNumberOrPair.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> widths [
	"Answer the width of each box: the given ones, or 0.15 times the distance between the extreme positions, kept between 0.15 and 0.5, as matplotlib."

	| default |
	widths ifNotNil: [ ^ (1 to: datasets size) collect: [ :index | self setting: widths at: index ] ].
	default := self positions ifEmpty: [ 0.5 ] ifNotEmpty: [ :all | (all max - all min * 0.15 max: 0.15) min: 0.5 ].
	^ Array new: datasets size withAll: default
]

{ #category : 'accessing' }
BpBoxPlot >> widths: aNumberOrCollection [
	"Set the width of the boxes in data units, for all boxes or one per box."

	widths := aNumberOrCollection.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> x: aCollection [
	"Set the data: a collection of numbers for one box, or one collection of numbers per box."

	datasets := (aCollection isNotEmpty and: [ aCollection first isNumber ])
		            ifTrue: [ { aCollection asArray } ]
		            ifFalse: [ aCollection collect: [ :each | each asArray ] as: Array ].
	self refresh
]
