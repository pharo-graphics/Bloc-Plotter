"
I am the area between two curves, added by `BpAxes>>fillBetweenX:y1:y2:` and `BpAxes>>fillBetweenY:x1:x2:`. Both curves share their x values; `y1` and `y2` give one value per x, or one for all (a horizontal line, 0 by default). I fill one closed `BpPolygonPatch` per region: `where:` selects the x values to fill and splits the area into separate regions, `interpolate:` ends the regions where the curves cross, and `step:` draws the curves as steps.

## Examples

```
BpFillBetween scriptPlotType.
BpFillBetween scriptFillBetweenDemo.
BpFillBetween scriptSelectiveFill.
BpFillBetween scriptConfidenceBand.
BpFillBetween scriptFillBetweenX.
BpFillBetween scriptSteps.
BpFillBetween scriptInteraction.
BpFillBetween exampleArea
```

## Design Rationale

- I compute my polygons as follows: for each run of true values of `where`, the polygon starts at the first x on `y2`, goes along `y1`, comes back along `y2`; with `interpolate:` its two ends are the points where `y1 - y2` changes sign, found by linear interpolation; `step:` turns each run into steps (#pre, #post, #mid) before.
- I keep the vocabulary of `BpAxes>>fillBetweenX:y1:y2:` whatever my orientation: `x` is the independent axis, `y1` and `y2` the dependent one. `BpAxes>>fillBetweenY:x1:x2:` maps its arguments on them.
- Without color, the fill takes the next color of the cycle and has no outline; `color:` sets both the fill and the outline, `faceColor:` only the fill, `edgeColor:` only the outline; `alpha:` makes both transparent.
- Like bars, my polygons are drawn below the grid.

## Usage

1. `BpAxes>>fillBetweenX:y1:`, `BpAxes>>fillBetweenX:y1:y2:` and `BpAxes>>fillBetweenY:x1:x2:` create me with my data (`x:y1:y2:`) and add me to the axes (see `BpArtist`), which give me one color of their cycle.
2. My axes read my polygons (`patches`) for autoscaling and my `legendEntries` (a filled rectangle).

## Implementation Notes

- I have one slot and setter per argument, hence many slots.
- Not supported yet: hatches, masked or NaN values.
- I take a color of the cycle even when `color:` or `faceColor:` is given, because my axes give it to me before I am configured.

## Invariants and Assumptions

- `y1`, `y2` and `where`, when they are collections, have the size of `x`; `x:y1:y2:` changes the data at once.
"
Class {
	#name : 'BpFillBetween',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'y1',
		'y2',
		'where',
		'interpolate',
		'step',
		'orientation',
		'color',
		'faceColor',
		'edgeColor',
		'lineWidth'
	],
	#category : 'Bloc-Plotter-Fill',
	#package : 'Bloc-Plotter',
	#tag : 'Fill'
}

{ #category : 'private - demo' }
BpFillBetween class >> confidenceBandOf: someXs and: someYs [
	"Answer the lower and upper curves of the confidence band of the least squares line fitting (someXs, someYs): the fit plus or minus std(x) * sqrt(1/n + (x - mean)^2 / sum((x - mean)^2))."

	| n meanX meanY centered sumSquares slope intercept deviation |
	n := someXs size.
	meanX := someXs sum / n.
	meanY := someYs sum / n.
	centered := someXs collect: [ :each | each - meanX ].
	sumSquares := (centered collect: [ :each | each squared ]) sum.
	slope := (centered with: someYs collect: [ :dx :each | dx * (each - meanY) ]) sum / sumSquares.
	intercept := meanY - (slope * meanX).
	deviation := (sumSquares / n) sqrt.
	^ #( -1 1 ) collect: [ :sign |
		  someXs
			  with: centered
			  collect: [ :each :dx | slope * each + intercept + (sign * deviation * (1 / n + (dx squared / sumSquares)) sqrt) ] ]
]

{ #category : 'examples' }
BpFillBetween class >> exampleArea [
	"Answer the area under a sine between 0 and pi, in new axes."

	<sampleInstance>
	| x |
	x := self linspaceFrom: 0 to: Float pi count: 50.
	^ (BpAxes new
		   extent: 400 @ 300;
		   yourself) fillBetweenX: x y1: (x collect: [ :each | each sin ])
]

{ #category : 'examples' }
BpFillBetween class >> exampleConfidenceBand [
	"Gallery: Fill the area between two lines (fill_between_demo), confidence bands: a linear fit of the data and its confidence band, half transparent."

	<sampleInstance>
	| x y band figure axes |
	x := self linspaceFrom: 0 to: 10 count: 11.
	y := #( 3.9 4.4 10.8 10.3 11.2 13.1 14.1 9.9 13.9 15.1 12.5 ).
	band := self confidenceBandOf: x and: y.
	figure := BpFigure new.
	axes := figure axes first.
	axes plotX: x y: (band first with: band last collect: [ :low :high | low + high / 2 ]) format: '-'.
	(axes fillBetweenX: x y1: band first y2: band last) alpha: 0.2.
	(axes plotX: x y: y format: 'o') color: 'tab:brown'.
	^ figure
]

{ #category : 'examples' }
BpFillBetween class >> exampleFillBetweenDemo [
	"Gallery: Fill the area between two lines (fill_between_demo), basic usage: between y1 and 0, y1 and 1, y1 and y2."

	<sampleInstance>
	| x y1 y2 figure |
	x := self arangeFrom: 0.0 to: 2 by: 0.01.
	y1 := x collect: [ :each | (2 * Float pi * each) sin ].
	y2 := x collect: [ :each | 0.8 * (4 * Float pi * each) sin ].
	figure := BpFigure rows: 3 columns: 1.
	figure extent: 600 @ 600.
	(figure axesAtRow: 1 column: 1) fillBetweenX: x y1: y1.
	(figure axesAtRow: 1 column: 1) title: 'fill between y1 and 0'.
	(figure axesAtRow: 2 column: 1) fillBetweenX: x y1: y1 y2: 1.
	(figure axesAtRow: 2 column: 1) title: 'fill between y1 and 1'.
	(figure axesAtRow: 3 column: 1) fillBetweenX: x y1: y1 y2: y2.
	(figure axesAtRow: 3 column: 1) title: 'fill between y1 and y2'.
	^ figure
]

{ #category : 'examples' }
BpFillBetween class >> exampleFillBetweenX [
	"Gallery: Fill the area between two vertical lines (fill_betweenx_demo): between (x1, 0), (x1, 1) and (x1, x2) along y."

	<sampleInstance>
	| y x1 x2 figure |
	y := self arangeFrom: 0.0 to: 2 by: 0.01.
	x1 := y collect: [ :each | (2 * Float pi * each) sin ].
	x2 := y collect: [ :each | 1.2 * (4 * Float pi * each) sin ].
	figure := BpFigure rows: 1 columns: 3.
	figure extent: 600 @ 600.
	(figure axesAtRow: 1 column: 1) fillBetweenY: y x1: 0 x2: x1.
	(figure axesAtRow: 1 column: 1) title: 'between (x1, 0)'.
	(figure axesAtRow: 1 column: 2) fillBetweenY: y x1: x1 x2: 1.
	(figure axesAtRow: 1 column: 2) title: 'between (x1, 1)'.
	(figure axesAtRow: 1 column: 3) fillBetweenY: y x1: x1 x2: x2.
	(figure axesAtRow: 1 column: 3) title: 'between (x1, x2)'.
	^ figure
]

{ #category : 'examples' }
BpFillBetween class >> exampleInteractiveFill [
	"A sine filled in C0 where it is positive and in C1 where it is negative, one polygon per hump: hovering a polygon outlines it, clicking it shows its x range in the title."

	<sampleInstance>
	| x y figure axes fills |
	x := self linspaceFrom: 0 to: 4 * Float pi count: 200.
	y := x collect: [ :each | each sin ].
	figure := BpFigure new.
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

{ #category : 'examples' }
BpFillBetween class >> examplePlotType [
	"Plot types: fill_between(x, y1, y2), a half transparent band between two noisy lines and the line in its middle."

	<sampleInstance>
	| random x y1 y2 figure axes |
	random := Random seed: 1.
	x := self linspaceFrom: 0 to: 8 count: 16.
	y1 := x collect: [ :each | 3 + (4 * each / 8) + (random next * 0.5) ].
	y2 := x collect: [ :each | 1 + (2 * each / 8) + (random next * 0.5) ].
	figure := BpFigure new.
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

{ #category : 'examples' }
BpFillBetween class >> exampleSelectiveFill [
	"Gallery: Fill the area between two lines (fill_between_demo), selectively filling horizontal regions: where y1 > y2 in C0, where y1 < y2 in C1, without and with interpolation at the crossing."

	<sampleInstance>
	| x y1 y2 figure |
	x := #( 0 1 2 3 ).
	y1 := #( 0.8 0.8 0.2 0.2 ).
	y2 := #( 0 0 1 1 ).
	figure := BpFigure rows: 2 columns: 1.
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

{ #category : 'examples' }
BpFillBetween class >> exampleSteps [
	"The three step styles of a fill (step: #pre, #post and #mid), with the data points marked."

	<sampleInstance>
	| x y figure |
	x := 1 to: 8.
	y := #( 2 4 3 6 5 7 4 6 ).
	figure := BpFigure rows: 1 columns: 3.
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

{ #category : 'script' }
BpFillBetween class >> scriptConfidenceBand [
	"Reproduce the confidence band figure of the gallery 'Fill the area between two lines'."

	<example>
	^ self exampleConfidenceBand show: 'fill_between confidence band'
]

{ #category : 'script' }
BpFillBetween class >> scriptFillBetweenDemo [
	"Reproduce the basic usage figure of the gallery 'Fill the area between two lines'."

	<example>
	^ self exampleFillBetweenDemo show: 'fill_between_demo'
]

{ #category : 'script' }
BpFillBetween class >> scriptFillBetweenX [
	"Reproduce the gallery 'Fill the area between two vertical lines' (`BpAxes>>fillBetweenY:x1:x2:`)."

	<example>
	^ self exampleFillBetweenX show: 'fill_betweenx_demo'
]

{ #category : 'script' }
BpFillBetween class >> scriptInteraction [
	"Interaction handlers on filled regions: hover a hump to outline it, click it to see its x range."

	<example>
	^ self exampleInteractiveFill show: 'Fill interaction'
]

{ #category : 'script' }
BpFillBetween class >> scriptPlotType [
	"Reproduce the plot type fill_between(x, y1, y2)."

	<example>
	^ self examplePlotType show: 'fill_between(x, y1, y2)'
]

{ #category : 'script' }
BpFillBetween class >> scriptSelectiveFill [
	"Reproduce the selective filling figure of the gallery 'Fill the area between two lines', without and with interpolation."

	<example>
	^ self exampleSelectiveFill show: 'fill_between where'
]

{ #category : 'script' }
BpFillBetween class >> scriptSteps [
	"Show the three step styles of a fill."

	<example>
	^ self exampleSteps show: 'fill_between step'
]

{ #category : 'accessing - style' }
BpFillBetween >> color [

	^ color
]

{ #category : 'accessing - style' }
BpFillBetween >> color: aColorOrName [
	"Set the color of the fill and of its outline."

	color := aColorOrName.
	self refresh
]

{ #category : 'private - computing' }
BpFillBetween >> compute [
	"Check that y1, y2 and where have one value per x."

	{
		(#y1 -> y1).
		(#y2 -> y2).
		(#where -> where) } do: [ :each |
			((self isMany: each value) and: [ each value size ~= x size ]) ifTrue: [
				^ self error: ('{1} has {2} values for {3} x values' format: {
					   each key.
					   each value size.
					   x size }) ] ]
]

{ #category : 'private - computing' }
BpFillBetween >> crossingBetween: anIndex and: anotherIndex tops: someTops bottoms: someBottoms [
	"Answer the point of the top curve where top - bottom is zero between two neighbor indices, by linear interpolation clamped to them."

	| xs root |
	xs := {
		      (x at: anIndex).
		      (x at: anotherIndex) }.
	root := self
		        linearValueAt: 0
		        positions: {
			        ((someTops at: anIndex) - (someBottoms at: anIndex)).
			        ((someTops at: anotherIndex) - (someBottoms at: anotherIndex)) }
		        values: xs.
	^ root @ (self linearValueAt: root positions: xs values: {
		   (someTops at: anIndex).
		   (someTops at: anotherIndex) })
]

{ #category : 'accessing - style' }
BpFillBetween >> edgeColor [

	^ edgeColor
]

{ #category : 'accessing - style' }
BpFillBetween >> edgeColor: aColorOrName [
	"Set the color of the outline only. The fill has no outline by default."

	edgeColor := aColorOrName.
	self refresh
]

{ #category : 'accessing - style' }
BpFillBetween >> faceColor [

	^ faceColor
]

{ #category : 'accessing - style' }
BpFillBetween >> faceColor: aColorOrName [
	"Set the color of the fill only; 'none' leaves it empty."

	faceColor := aColorOrName.
	self refresh
]

{ #category : 'initialization' }
BpFillBetween >> initialize [

	super initialize.
	x := #(  ).
	y1 := #(  ).
	y2 := 0.
	interpolate := false.
	orientation := #vertical.
	lineWidth := 1
]

{ #category : 'accessing - options' }
BpFillBetween >> interpolate [

	^ interpolate
]

{ #category : 'accessing - options' }
BpFillBetween >> interpolate: aBoolean [
	"When true, each region selected by where ends where y1 and y2 cross, instead of on its last selected x."

	interpolate := aBoolean.
	self refresh
]

{ #category : 'accessing - options' }
BpFillBetween >> isHorizontal [

	^ orientation = #horizontal
]

{ #category : 'axes' }
BpFillBetween >> legendEntries [
	"Answer my label with a rectangle filled and outlined as my polygons."

	(label isNil or: [ patches isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> (BlElement new
		    extent: 20 @ 10;
		    in: [ :swatch | self paint: swatch ];
		    yourself)) }
]

{ #category : 'accessing - style' }
BpFillBetween >> lineWidth [

	^ lineWidth
]

{ #category : 'accessing - style' }
BpFillBetween >> lineWidth: aNumber [
	"Set the width of the outline in points (1 by default); 0 removes it."

	lineWidth := aNumber.
	self refresh
]

{ #category : 'private - computing' }
BpFillBetween >> linearValueAt: aNumber positions: twoPositions values: twoValues [
	"Answer the value at aNumber of the line through (twoPositions, twoValues), clamped to the values at its ends, as numpy interp."

	| low high slope |
	low := 1.
	high := 2.
	twoPositions first > twoPositions last ifTrue: [
		low := 2.
		high := 1 ].
	aNumber <= (twoPositions at: low) ifTrue: [ ^ twoValues at: low ].
	aNumber >= (twoPositions at: high) ifTrue: [ ^ twoValues at: high ].
	slope := (twoValues at: high) - (twoValues at: low) / ((twoPositions at: high) - (twoPositions at: low)).
	^ (twoValues at: low) + (slope * (aNumber - (twoPositions at: low)))
]

{ #category : 'private - computing' }
BpFillBetween >> newPatches [
	"Answer one closed polygon per region."

	| tops bottoms |
	tops := self valuesOf: y1.
	bottoms := self valuesOf: y2.
	^ self regions collect: [ :each | self newPolygonThrough: (self verticesOf: each tops: tops bottoms: bottoms) ] as: Array
]

{ #category : 'private - patches' }
BpFillBetween >> newPolygonThrough: somePoints [
	"Answer a closed polygon through somePoints, given as (x @ y) of `BpAxes>>fillBetweenX:y1:y2:`, styled and with my handlers."

	| polygon |
	polygon := BpPolygonPatch new
		           artist: self;
		           dataset: 1;
		           closed: true;
		           dataVertices: (somePoints collect: [ :each | self oriented: each ]);
		           yourself.
	self paint: polygon.
	patchHandlers do: [ :each | self addHandler: each to: polygon ].
	^ polygon
]

{ #category : 'accessing - options' }
BpFillBetween >> orientation [

	^ orientation
]

{ #category : 'accessing - options' }
BpFillBetween >> orientation: aSymbol [
	"Fill between curves of y over x (#vertical, `BpAxes>>fillBetweenX:y1:y2:`, the default) or of x over y (#horizontal, `BpAxes>>fillBetweenY:x1:x2:`)."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - patches' }
BpFillBetween >> oriented: aPoint [
	"Answer aPoint, given as (x @ y) of `BpAxes>>fillBetweenX:y1:y2:`, in data coordinates: swapped for `BpAxes>>fillBetweenY:x1:x2:`."

	^ self isHorizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'private - style' }
BpFillBetween >> paint: anElement [
	"Give anElement my fill and outline: color sets both, faceColor and edgeColor one each; no outline by default."

	| edge |
	anElement background: (self paintOf: (faceColor ifNil: [ color ifNil: [ defaultColors first ] ])).
	edge := edgeColor ifNil: [ color ].
	(edge isNil or: [ lineWidth isZero ]) ifTrue: [ ^ self ].
	anElement border: (BlBorder paint: (self paintOf: edge) width: lineWidth * self class pixelsPerPoint)
]

{ #category : 'private - computing' }
BpFillBetween >> regions [
	"Answer the runs of consecutive indices whose where value is true, as intervals."

	| flags runs start |
	flags := where ifNil: [ Array new: x size withAll: true ] ifNotNil: [ where asArray ].
	runs := OrderedCollection new.
	start := nil.
	flags withIndexDo: [ :each :index |
		each
			ifTrue: [ start ifNil: [ start := index ] ]
			ifFalse: [
				start ifNotNil: [
					runs add: (start to: index - 1).
					start := nil ] ] ].
	start ifNotNil: [ runs add: (start to: flags size) ].
	^ runs
]

{ #category : 'accessing - options' }
BpFillBetween >> step [

	^ step
]

{ #category : 'accessing - options' }
BpFillBetween >> step: aSymbolOrNil [
	"Draw the curves as steps: #pre (each value holds before its x), #post (after its x), #mid (around its x), or nil for straight lines (the default)."

	(aSymbolOrNil isNil or: [ #( #pre #post #mid ) includes: aSymbolOrNil ]) ifFalse: [
		^ self error: 'Unknown step: ' , aSymbolOrNil printString ].
	step := aSymbolOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpFillBetween >> steppedPositions: someXs [
	"Answer the x values of the vertices of steps through someXs: x0 x0 x1 x1 ... for #pre, x0 x1 x1 x2 ... for #post, and for #mid x0, then twice each middle, then the last x."

	| result |
	result := OrderedCollection new.
	step = #mid ifTrue: [
		result add: someXs first.
		1 to: someXs size - 1 do: [ :index |
			| middle |
			middle := (someXs at: index) + (someXs at: index + 1) / 2.
			result
				add: middle;
				add: middle ].
		result add: someXs last.
		^ result asArray ].
	1 to: someXs size - 1 do: [ :index |
		result
			add: (someXs at: index);
			add: (someXs at: (step = #pre
				  ifTrue: [ index ]
				  ifFalse: [ index + 1 ])) ].
	result add: someXs last.
	^ result asArray
]

{ #category : 'private - computing' }
BpFillBetween >> steppedValues: someValues [
	"Answer the values of a curve at the vertices of its steps, matching steppedPositions: (y0 y1 y1 y2 ... for #pre, y0 y0 y1 y1 ... for #post, each value twice for #mid)."

	| result |
	result := OrderedCollection new.
	step = #mid ifTrue: [
		someValues do: [ :each |
			result
				add: each;
				add: each ].
		^ result asArray ].
	1 to: someValues size - 1 do: [ :index |
		result
			add: (someValues at: index);
			add: (someValues at: (step = #pre
				  ifTrue: [ index + 1 ]
				  ifFalse: [ index ])) ].
	result add: someValues last.
	^ result asArray
]

{ #category : 'private - computing' }
BpFillBetween >> valuesOf: aValueOrCollection [
	"Answer one value per x: aValueOrCollection itself, or one value repeated."

	^ (1 to: x size) collect: [ :index | self setting: aValueOrCollection at: index ]
]

{ #category : 'private - computing' }
BpFillBetween >> verticesOf: anInterval tops: someTops bottoms: someBottoms [
	"Answer the vertices of the polygon of a region: its start on the bottom curve (or the crossing when interpolating), along the top curve, its end, and back along the bottom curve."

	| xs tops bottoms start end |
	xs := anInterval collect: [ :index | x at: index ].
	tops := anInterval collect: [ :index | someTops at: index ].
	bottoms := anInterval collect: [ :index | someBottoms at: index ].
	step ifNotNil: [
		xs := self steppedPositions: xs.
		tops := self steppedValues: tops.
		bottoms := self steppedValues: bottoms ].
	interpolate
		ifTrue: [
			start := self
				         crossingBetween: (anInterval first - 1 max: 1)
				         and: anInterval first
				         tops: someTops
				         bottoms: someBottoms.
			end := self
				       crossingBetween: anInterval last
				       and: (anInterval last + 1 min: x size)
				       tops: someTops
				       bottoms: someBottoms ]
		ifFalse: [
			start := xs first @ bottoms first.
			end := xs last @ bottoms last ].
	^ { start } , (xs with: tops collect: [ :eachX :each | eachX @ each ]) , { end }
	  , (xs reversed with: bottoms reversed collect: [ :eachX :each | eachX @ each ])
]

{ #category : 'accessing - options' }
BpFillBetween >> where [

	^ where
]

{ #category : 'accessing - options' }
BpFillBetween >> where: aCollectionOfBooleansOrNil [
	"Fill only at the x values whose boolean is true; each run of true values is a separate region. nil fills everywhere."

	where := aCollectionOfBooleansOrNil.
	self refresh
]

{ #category : 'accessing - data' }
BpFillBetween >> x [

	^ x
]

{ #category : 'accessing - data' }
BpFillBetween >> x: aCollection y1: aCollectionOrNumber y2: anotherCollectionOrNumber [
	"Set the x values and the two curves to fill between: one value per x, or one for all."

	x := aCollection asArray.
	y1 := aCollectionOrNumber.
	y2 := anotherCollectionOrNumber.
	self refresh
]

{ #category : 'accessing - data' }
BpFillBetween >> y1 [

	^ y1
]

{ #category : 'accessing - data' }
BpFillBetween >> y2 [

	^ y2
]
