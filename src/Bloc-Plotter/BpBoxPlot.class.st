"
I am a box plot of one or several datasets, added by `BpAxes>>boxPlot:`: for each dataset, a box from the first to the third quartile crossed by the median, whiskers to the most extreme data within 1.5 interquartile ranges, caps at their ends, and the fliers beyond them as markers. I get the numbers from `BpBoxStatistics` and draw them with `BpPolygonPatch` lines and boxes and `BpMarkerPatch` fliers and means.

## Examples

```
BpBoxPlot exampleBoxPlotDemo.
BpBoxPlot exampleInteraction.
BpBoxPlot examplePlotType
```

## Design Rationale

- My settings are `notch:`, `whiskers:` (a factor of the interquartile range or a pair of percentiles), `positions:`, `widths:`, `capWidths:`, `orientation:` (`#vertical` or `#horizontal`), `flierSymbol:` (a format such as `'gD'`, `''` hides the fliers), `patchArtist:`, `showMeans:`, `meanLine:`, `showFliers:`, `showCaps:`, `showBox:`, `tickLabels:`.
- Styles are dictionaries over defaults (`boxProperties:`, `medianProperties:`, `whiskerProperties:`, `capProperties:`, `flierProperties:` and `meanProperties:`): keys such as `#color`, `#faceColor`, `#edgeColor`, `#lineWidth`, `#lineStyle`, `#marker`, `#markerSize`. The defaults are a black box and whiskers, median in `'C1'`, mean as a `'C2'` triangle. The color `'none'` is transparent.
- I keep the patches of each part apart (`parts` at `#boxes`, `#medians`, `#whiskers`, `#caps`, `#fliers`, `#means`) and draw them in that layered order: whiskers and caps under the boxes, medians and means over them.
- I work in (position @ value) and swap the coordinates once, in `oriented:`, so horizontal boxes need no other code.
- I put a tick at each position (`managedTicksOn:`) and require half a unit around the extreme positions (`requiredValuesOn:`), which autoscaling does not go past. Ticks fixed with `xTicks:` win.
- I do not use the color cycle (`colorCount` is 0) and I am drawn above the grid.

## Usage

1. `BpAxes>>boxPlot:` creates me with a collection of numbers (one box) or a collection of such collections (one box per collection).
2. My setters rebuild me: `compute` asks `BpBoxStatistics` for the statistics of each dataset, `newPatches` builds the parts.
3. `statistics` answers them, one per dataset; each patch knows its `dataset` index, so a handler given to `whenPatch:do:` finds the box it belongs to.

## Implementation Notes

- The notched box is a ten-vertex polygon narrowed to half its width at the median, between `confidenceLow` and `confidenceHigh`.
- Default widths are 0.15 times the span of the positions, clipped between 0.15 and 0.5.

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
		'tickLabels',
		'parts',
		'meanProperties',
		'medianProperties',
		'flierProperties',
		'capProperties',
		'boxProperties',
		'whiskerProperties'
	],
	#category : 'Bloc-Plotter-Box',
	#package : 'Bloc-Plotter',
	#tag : 'Box'
}

{ #category : 'constants' }
BpBoxPlot class >> defaultBoxProperties [
	"Answer the style of the boxes (the face is the patch color, used when the boxes are filled)."

	^ {
		  (#color -> 'black').
		  (#faceColor -> 'C0').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultCapProperties [

	^ {
		  (#color -> 'black').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultFlierProperties [
	"Answer the style of the fliers: unfilled black circles."

	^ {
		  (#marker -> 'o').
		  (#markerFaceColor -> 'none').
		  (#markerEdgeColor -> 'black').
		  (#markerSize -> 6).
		  (#markerEdgeWidth -> 1) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultMeanProperties [
	"Answer the style of the means: green triangles, or a dashed green line."

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
BpBoxPlot class >> defaultMedianProperties [

	^ {
		  (#color -> 'C1').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'constants' }
BpBoxPlot class >> defaultWhiskerProperties [

	^ {
		  (#color -> 'black').
		  (#lineWidth -> 1).
		  (#lineStyle -> #solid) } asDictionary
]

{ #category : 'examples' }
BpBoxPlot class >> exampleBoxPlotDemo [
	"Show the six variants of the gallery Boxplots: basic, notched, other flier symbols, no fliers, horizontal, shorter whiskers."

	<example>
	^ BpFigure instanceBoxPlotDemo show: 'boxplot_demo'
]

{ #category : 'examples' }
BpBoxPlot class >> exampleInteraction [
	"Show three boxes reacting to the mouse: hovering outlines a part, clicking shows the statistics of its box."

	<example>
	^ BpFigure instanceInteractiveBoxPlot show: 'boxplot interaction'
]

{ #category : 'examples' }
BpBoxPlot class >> examplePlotType [
	"Show the figure of the box plot type page."

	<example>
	^ BpFigure instanceBoxPlotType show: 'boxplot'
]

{ #category : 'instances' }
BpBoxPlot class >> instanceThreeBoxes [
	"Answer a box plot of three normal samples."

	<sampleInstance>
	| random |
	random := Random seed: 10.
	^ self new
		  x: (#( 3 5 4 ) collect: [ :mean | (1 to: 100) collect: [ :each | random nextNormalMean: mean deviation: 1 ] ]);
		  yourself
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
			 properties: (self properties: whiskerProperties defaults: self class defaultWhiskerProperties)
			 dataset: anIndex);
		add: (self
			 newLine: {
				 (aPosition @ aStatistics q3).
				 (aPosition @ aStatistics whiskerHigh) }
			 properties: (self properties: whiskerProperties defaults: self class defaultWhiskerProperties)
			 dataset: anIndex).
	showCaps ifTrue: [
		(parts at: #caps)
			add: (self
				 newLine: {
					 (aPosition - capHalf @ aStatistics whiskerLow).
					 (aPosition + capHalf @ aStatistics whiskerLow) }
				 properties: (self properties: capProperties defaults: self class defaultCapProperties)
				 dataset: anIndex);
			add: (self
				 newLine: {
					 (aPosition - capHalf @ aStatistics whiskerHigh).
					 (aPosition + capHalf @ aStatistics whiskerHigh) }
				 properties: (self properties: capProperties defaults: self class defaultCapProperties)
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
		 properties: (self properties: medianProperties defaults: self class defaultMedianProperties)
		 dataset: anIndex).
	showMeans ifTrue: [
		(parts at: #means) add: (self
			 newMeanOf: aStatistics
			 at: aPosition
			 half: half
			 dataset: anIndex) ].
	self hasFliers ifTrue: [
		(parts at: #fliers) addAll:
			(aStatistics fliers collect: [ :each | self newMarkerAt: aPosition @ each properties: self flierStyle dataset: anIndex ]) ]
]

{ #category : 'accessing' }
BpBoxPlot >> boxProperties: aDictionary [
	"Set the style of the boxes: #color or #edgeColor, #faceColor, #lineWidth (points), #lineStyle."

	boxProperties := aDictionary.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> capProperties: aDictionary [
	"Set the style of the caps: #color, #lineWidth (points), #lineStyle."

	capProperties := aDictionary.
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
	"Answer 0: box plots are drawn in the colors of their properties, not with the color cycle."

	^ 0
]

{ #category : 'private - computing' }
BpBoxPlot >> compute [

	statistics := datasets collect: [ :each | BpBoxStatistics of: each whiskers: whiskers ]
]

{ #category : 'accessing' }
BpBoxPlot >> flierProperties: aDictionary [
	"Set the style of the fliers: #marker, #markerFaceColor, #markerEdgeColor, #markerSize and #markerEdgeWidth (points)."

	flierProperties := aDictionary.
	self refresh
]

{ #category : 'private - computing' }
BpBoxPlot >> flierStyle [
	"Answer the style of the fliers: my flier properties, then the marker and color of my flier symbol, which colors both the face and the edge."

	| style symbol |
	style := self properties: flierProperties defaults: self class defaultFlierProperties.
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
	"Set the marker and color of the fliers with a format string such as 'gD' or 'rs' (see `BpLine>>format:`); '' hides the fliers."

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
	boxProperties := Dictionary new.
	medianProperties := Dictionary new.
	whiskerProperties := Dictionary new.
	capProperties := Dictionary new.
	flierProperties := Dictionary new.
	meanProperties := Dictionary new.
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
	"Answer my label with a filled box when my boxes are filled, otherwise with my median line."

	(label isNil or: [ statistics isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> self newSwatch) }
]

{ #category : 'axes' }
BpBoxPlot >> managedTicksOn: anAxis [
	"Answer a tick at each of my positions on my position axis, labeled by my tick labels or the position."

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
BpBoxPlot >> meanProperties: aDictionary [
	"Set the style of the means: the marker keys of flierProperties:, or #color, #lineWidth and #lineStyle for mean lines."

	meanProperties := aDictionary.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> medianProperties: aDictionary [
	"Set the style of the medians: #color, #lineWidth (points), #lineStyle."

	medianProperties := aDictionary.
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
	style := self properties: boxProperties defaults: self class defaultBoxProperties.
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
BpBoxPlot >> newLine: somePoints properties: aStyle dataset: anIndex [

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
BpBoxPlot >> newMarkerAt: aPoint properties: aStyle dataset: anIndex [

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
	style := self properties: meanProperties defaults: self class defaultMeanProperties.
	^ meanLine
		  ifTrue: [
			  self
				  newLine: {
					  (aPosition - aHalfWidth @ aStatistics mean).
					  (aPosition + aHalfWidth @ aStatistics mean) }
				  properties: style
				  dataset: anIndex ]
		  ifFalse: [ self newMarkerAt: aPosition @ aStatistics mean properties: style dataset: anIndex ]
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
		style := self properties: boxProperties defaults: self class defaultBoxProperties.
		^ BlElement new
			  extent: 20 @ 10;
			  background: (self paintOf: (style at: #faceColor));
			  border: (BlBorder
				   paint: (self paintOf: (style at: #edgeColor ifAbsent: [ style at: #color ]))
				   width: (style at: #lineWidth) * self class pixelsPerPoint);
			  yourself ].
	style := self properties: medianProperties defaults: self class defaultMedianProperties.
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
	"Answer my patches by role: #boxes, #medians, #whiskers, #caps, #fliers and #means."

	^ parts
]

{ #category : 'accessing' }
BpBoxPlot >> patchArtist: aBoolean [
	"Fill the boxes (with the face color of the box properties, the first color of the cycle by default) instead of drawing only their outline."

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
BpBoxPlot >> properties: aDictionary defaults: someDefaults [
	"Answer someDefaults overridden by aDictionary."

	^ someDefaults copy
		  addAll: aDictionary;
		  yourself
]

{ #category : 'axes' }
BpBoxPlot >> requiredValuesOn: anAxis [
	"Answer half a unit around my extreme positions on my position axis, so that even a single box looks right."

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
BpBoxPlot >> whiskerProperties: aDictionary [
	"Set the style of the whiskers: #color, #lineWidth (points), #lineStyle."

	whiskerProperties := aDictionary.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> whiskers: aNumberOrPair [
	"Set how far the whiskers reach: a number of interquartile ranges from the box (1.5 by default), or the two percentiles where they end."

	whiskers := aNumberOrPair.
	self refresh
]

{ #category : 'accessing' }
BpBoxPlot >> widths [
	"Answer the width of each box: the given ones, or 0.15 times the distance between the extreme positions, kept between 0.15 and 0.5."

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
