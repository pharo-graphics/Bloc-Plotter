"
I am the area between two curves of a `BpChart`. Both curves share their x values; `y1` and `y2` give one value per x, or one for all (a horizontal line, 0 by default). I fill one closed `BpPolygonPatch` per region: `where:` selects the x values to fill and splits the area into separate regions, `interpolate:` ends the regions where the curves cross, and `step:` draws the curves as steps.

## Examples

```
BpFillBetween examplePlotType.
BpFillBetween exampleFillBetweenDemo.
BpFillBetween exampleSelectiveFill.
BpFillBetween exampleConfidenceBand.
BpFillBetween exampleFillBetweenX.
BpFillBetween exampleSteps.
BpFillBetween exampleInteraction
```

## Design Rationale

- I compute my polygons as follows: for each run of true values of `where`, the polygon starts at the first x on `y2`, goes along `y1`, comes back along `y2`; with `interpolate:` its two ends are the points where `y1 - y2` changes sign, found by linear interpolation; `step:` turns each run into steps (#pre, #post, #mid) before.
- I keep the vocabulary of `BpFillBetween class>>x:y1:y2:` whatever my orientation: `x` is the independent axis, `y1` and `y2` the dependent one. `BpFillBetween class>>y:x1:x2:` maps its arguments on them.
- Without color, the fill takes the next color of the palette of my chart and has no outline; `color:` sets both the fill and the outline, `faceColor:` only the fill, `edgeColor:` only the outline; `alpha:` makes both transparent.
- Like bars, my polygons are drawn below the grid.

## Usage

1. `BpFillBetween class>>x:y1:` (down to 0), `BpFillBetween class>>x:y1:y2:`, and their horizontal counterparts `BpFillBetween class>>y:x1:` and `BpFillBetween class>>y:x1:x2:` create me with my data, and `BpChart>>addArtist:` adds me to a chart (see `BpArtist`), which gives me one color of its palette.
2. My chart reads my polygons (`patches`) for autoscaling and my `legendEntries` (a filled rectangle).

## Implementation Notes

- I have one slot and setter per argument, hence many slots.
- Not supported yet: hatches, masked or NaN values.
- I take a color of the palette even when `color:` or `faceColor:` is given, because my chart gives it to me before I am configured.

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

{ #category : 'private - demo' }
BpFillBetween class >> confidenceX [
	"Answer the x of the confidence band demo: 0 to 10."

	^ self linspaceFrom: 0 to: 10 count: 11
]

{ #category : 'private - demo' }
BpFillBetween class >> confidenceY [
	"Answer the measures of the confidence band demo, one per x."

	^ #( 3.9 4.4 10.8 10.3 11.2 13.1 14.1 9.9 13.9 15.1 12.5 )
]

{ #category : 'private - demo' }
BpFillBetween class >> demoX [
	"Answer the x of the basic usage demo: 0 to 2 by 0.01."

	^ self arangeFrom: 0.0 to: 2 by: 0.01
]

{ #category : 'private - demo' }
BpFillBetween class >> demoY1 [
	"Answer the first curve of the basic usage demo, a sine of period 1."

	^ self demoX collect: [ :each | (2 * Float pi * each) sin ]
]

{ #category : 'private - demo' }
BpFillBetween class >> demoY2 [
	"Answer the second curve of the basic usage demo, a sine of period 0.5 and amplitude 0.8."

	^ self demoX collect: [ :each | 0.8 * (4 * Float pi * each) sin ]
]

{ #category : 'examples' }
BpFillBetween class >> exampleConfidenceBand [
	"Reproduce the confidence band figure of the gallery 'Fill the area between two lines': the linear fit of the measures, its confidence band and the measures."

	<example>
	| figure chart band |
	band := self confidenceBandOf: self confidenceX and: self confidenceY.
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: ((BpLine x: self confidenceX y: (band first with: band last collect: [ :low :high | low + high / 2 ]))
		 format: '-';
		 yourself).
	chart addArtist: self instanceConfidenceBand.
	(chart addArtist: ((BpLine x: self confidenceX y: self confidenceY)
		  format: 'o';
		  yourself)) color: (chart palette colorAt: 6).
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'fill_between confidence band'
]

{ #category : 'examples' }
BpFillBetween class >> exampleFillBetweenDemo [
	"Reproduce the basic usage figure of the gallery 'Fill the area between two lines': between y1 and 0, y1 and 1, y1 and y2."

	<example>
	| figure |
	figure := BpFigure rows: 3 columns: 1.
	figure extent: 600 @ 600.
	figure
		chartAtRow: 1 column: 1 put: (BpChart new
			 addArtist: self instanceDownToZero;
			 title: 'fill between y1 and 0';
			 yourself);
		chartAtRow: 2 column: 1 put: (BpChart new
			 addArtist: self instanceUpToOne;
			 title: 'fill between y1 and 1';
			 yourself);
		chartAtRow: 3 column: 1 put: (BpChart new
			 addArtist: self instanceBetweenTwoCurves;
			 title: 'fill between y1 and y2';
			 yourself).
	^ figure show: 'fill_between_demo'
]

{ #category : 'examples' }
BpFillBetween class >> exampleFillBetweenX [
	"Reproduce the gallery 'Fill the area between two vertical lines' (`BpFillBetween class>>y:x1:x2:`): between (x1, 0), (x1, 1) and (x1, x2) along y."

	<example>
	| figure |
	figure := BpFigure rows: 1 columns: 3.
	figure extent: 600 @ 600.
	figure
		chartAtRow: 1 column: 1 put: (BpChart new
			 addArtist: self instanceHorizontalFromZero;
			 title: 'between (x1, 0)';
			 yourself);
		chartAtRow: 1 column: 2 put: (BpChart new
			 addArtist: self instanceHorizontalToOne;
			 title: 'between (x1, 1)';
			 yourself);
		chartAtRow: 1 column: 3 put: (BpChart new
			 addArtist: self instanceHorizontalBetweenTwoCurves;
			 title: 'between (x1, x2)';
			 yourself).
	^ figure show: 'fill_betweenx_demo'
]

{ #category : 'examples' }
BpFillBetween class >> exampleInteraction [
	"Interaction handlers on filled regions: hover a hump to outline it, click it to see its x range in the title."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart title: 'Click a hump'.
	{
		self instancePositiveHumps.
		self instanceNegativeHumps } do: [ :fill |
			chart addArtist: fill.
			fill
				whenPatch: BlMouseEnterEvent
				do: [ :event :polygon | polygon border: (BlBorder paint: ((BpSequentialPalette greys: 9) colorAt: 9) width: 2) ];
				whenPatch: BlMouseLeaveEvent do: [ :event :polygon | fill paint: polygon ];
				whenPatch: BlClickEvent do: [ :event :polygon |
					chart title: ('from x = {1} to x = {2}' format: {
						 ((polygon dataVertices collect: [ :each | each x ]) min printShowingDecimalPlaces: 2).
						 ((polygon dataVertices collect: [ :each | each x ]) max printShowingDecimalPlaces: 2) }) ] ].
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Fill interaction'
]

{ #category : 'examples' }
BpFillBetween class >> examplePlotType [
	"Reproduce the plot type fill_between(x, y1, y2): a band between two noisy lines and the line in its middle, in a chart of fixed limits and ticks, with a grid."

	<example>
	| figure chart curves |
	curves := self noisyBandCurves.
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: self instanceNoisyBand.
	(chart addArtist: (BpLine x: curves first y: (curves second with: curves third collect: [ :a :b | a + b / 2 ]))) lineWidth: 2.
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'fill_between(x, y1, y2)'
]

{ #category : 'examples' }
BpFillBetween class >> exampleSelectiveFill [
	"Reproduce the selective filling figure of the gallery 'Fill the area between two lines': where y1 > y2 in the first color of the palette, where y1 < y2 in the second, without and with interpolation at the crossing."

	<example>
	| figure |
	figure := BpFigure rows: 2 columns: 1.
	{
		('interpolation=False' -> {
			 self instanceWhereFirstIsHigher.
			 self instanceWhereFirstIsLower }).
		('interpolation=True' -> {
			 self instanceWhereFirstIsHigherInterpolated.
			 self instanceWhereFirstIsLowerInterpolated }) } withIndexDo: [ :each :row |
			| chart |
			chart := BpChart new.
			chart title: each key.
			{
				self selectiveY1.
				self selectiveY2 } do: [ :y |
					chart addArtist: ((BpLine x: self selectiveX y: y)
						 format: 'o--';
						 yourself) ].
			each value do: [ :fill | chart addArtist: fill ].
			figure chartAtRow: row column: 1 put: chart ].
	^ figure show: 'fill_between where'
]

{ #category : 'examples' }
BpFillBetween class >> exampleSteps [
	"Show the three step styles of a fill (step: #pre, #post and #mid), with the data points marked."

	<example>
	| figure |
	figure := BpFigure rows: 1 columns: 3.
	figure extent: 900 @ 320.
	{
		('step: #pre' -> self instanceStepPre).
		('step: #post' -> self instanceStepPost).
		('step: #mid' -> self instanceStepMid) } withIndexDo: [ :each :column |
			| chart |
			chart := BpChart new.
			chart addArtist: each value.
			chart addArtist: ((BpLine x: self stepDemoX y: self stepDemoY)
				 format: 'o';
				 yourself).
			chart title: each key.
			figure chartAtRow: 1 column: column put: chart ].
	^ figure show: 'fill_between step'
]

{ #category : 'private - demo' }
BpFillBetween class >> humpsWhere: aBlock colorAt: anIndex [
	"Answer the fill of a sine down to 0 where aBlock answers true for its values, interpolated at the crossings, in the color anIndex of the default palette: one polygon per hump."

	| y |
	y := self humpsX collect: [ :each | each sin ].
	^ (self x: self humpsX y1: y)
		  where: (y collect: aBlock);
		  interpolate: true;
		  color: (BpPalette default colorAt: anIndex);
		  yourself
]

{ #category : 'private - demo' }
BpFillBetween class >> humpsX [
	"Answer the x of the interaction demo: 200 points over two periods of a sine."

	^ self linspaceFrom: 0 to: 4 * Float pi count: 200
]

{ #category : 'instances' }
BpFillBetween class >> instanceArea [
	"Answer the area under a sine between 0 and pi."

	<sampleInstance>
	| x |
	x := self linspaceFrom: 0 to: Float pi count: 50.
	^ self x: x y1: (x collect: [ :each | each sin ])
]

{ #category : 'instances' }
BpFillBetween class >> instanceBetweenTwoCurves [
	"Gallery: Fill the area between two lines (fill_between_demo), basic usage: the area between two sines."

	<sampleInstance>
	^ self x: self demoX y1: self demoY1 y2: self demoY2
]

{ #category : 'instances' }
BpFillBetween class >> instanceConfidenceBand [
	"Gallery: Fill the area between two lines (fill_between_demo), confidence bands: the confidence band of the linear fit of the measures, mostly transparent."

	<sampleInstance>
	| band |
	band := self confidenceBandOf: self confidenceX and: self confidenceY.
	^ (self x: self confidenceX y1: band first y2: band last)
		  alpha: 0.2;
		  yourself
]

{ #category : 'instances' }
BpFillBetween class >> instanceDownToZero [
	"Gallery: Fill the area between two lines (fill_between_demo), basic usage: the area between a sine and 0."

	<sampleInstance>
	^ self x: self demoX y1: self demoY1
]

{ #category : 'instances' }
BpFillBetween class >> instanceHorizontalBetweenTwoCurves [
	"Gallery: Fill the area between two vertical lines (fill_betweenx_demo): the area between two sines along y, the second of amplitude 1.2."

	<sampleInstance>
	^ self y: self demoX x1: self demoY1 x2: (self demoX collect: [ :each | 1.2 * (4 * Float pi * each) sin ])
]

{ #category : 'instances' }
BpFillBetween class >> instanceHorizontalFromZero [
	"Gallery: Fill the area between two vertical lines (fill_betweenx_demo): the area between 0 and a sine along y."

	<sampleInstance>
	^ self y: self demoX x1: 0 x2: self demoY1
]

{ #category : 'instances' }
BpFillBetween class >> instanceHorizontalToOne [
	"Gallery: Fill the area between two vertical lines (fill_betweenx_demo): the area between a sine along y and 1."

	<sampleInstance>
	^ self y: self demoX x1: self demoY1 x2: 1
]

{ #category : 'instances' }
BpFillBetween class >> instanceNegativeHumps [
	"Answer a sine filled up to 0 where it is negative, one polygon per hump, in the second color of the palette."

	<sampleInstance>
	^ self humpsWhere: [ :each | each <= 0 ] colorAt: 2
]

{ #category : 'instances' }
BpFillBetween class >> instanceNoisyBand [
	"Plot types: fill_between(x, y1, y2), a half transparent band without outline between two noisy lines."

	<sampleInstance>
	| curves |
	curves := self noisyBandCurves.
	^ (self x: curves first y1: curves second y2: curves third)
		  alpha: 0.5;
		  lineWidth: 0;
		  yourself
]

{ #category : 'instances' }
BpFillBetween class >> instancePositiveHumps [
	"Answer a sine filled down to 0 where it is positive, one polygon per hump, in the first color of the palette."

	<sampleInstance>
	^ self humpsWhere: [ :each | each >= 0 ] colorAt: 1
]

{ #category : 'instances' }
BpFillBetween class >> instanceStepMid [
	"Answer a fill whose steps change halfway between the x (step: #mid)."

	<sampleInstance>
	^ self stepFill: #mid
]

{ #category : 'instances' }
BpFillBetween class >> instanceStepPost [
	"Answer a fill whose steps hold each value after its x (step: #post)."

	<sampleInstance>
	^ self stepFill: #post
]

{ #category : 'instances' }
BpFillBetween class >> instanceStepPre [
	"Answer a fill whose steps hold each value before its x (step: #pre, see `BpFillBetween>>step:`)."

	<sampleInstance>
	^ self stepFill: #pre
]

{ #category : 'instances' }
BpFillBetween class >> instanceUpToOne [
	"Gallery: Fill the area between two lines (fill_between_demo), basic usage: the area between a sine and 1."

	<sampleInstance>
	^ self x: self demoX y1: self demoY1 y2: 1
]

{ #category : 'instances' }
BpFillBetween class >> instanceWhereFirstIsHigher [
	"Gallery: Fill the area between two lines (fill_between_demo), selective filling, first chart: the region where y1 > y2, in the first color of the palette, ending at the last x selected (see `BpFillBetween>>where:`)."

	<sampleInstance>
	^ self selectiveFillWhere: [ :a :b | a > b ] colorAt: 1 interpolate: false
]

{ #category : 'instances' }
BpFillBetween class >> instanceWhereFirstIsHigherInterpolated [
	"Gallery: Fill the area between two lines (fill_between_demo), selective filling, second chart: the region where y1 > y2, ending where the curves cross (see `BpFillBetween>>interpolate:`)."

	<sampleInstance>
	^ self selectiveFillWhere: [ :a :b | a > b ] colorAt: 1 interpolate: true
]

{ #category : 'instances' }
BpFillBetween class >> instanceWhereFirstIsLower [
	"Gallery: Fill the area between two lines (fill_between_demo), selective filling, first chart: the region where y1 < y2, in the second color of the palette."

	<sampleInstance>
	^ self selectiveFillWhere: [ :a :b | a < b ] colorAt: 2 interpolate: false
]

{ #category : 'instances' }
BpFillBetween class >> instanceWhereFirstIsLowerInterpolated [
	"Gallery: Fill the area between two lines (fill_between_demo), selective filling, second chart: the region where y1 < y2, starting where the curves cross."

	<sampleInstance>
	^ self selectiveFillWhere: [ :a :b | a < b ] colorAt: 2 interpolate: true
]

{ #category : 'private - demo' }
BpFillBetween class >> noisyBandCurves [
	"Answer the x, the upper and the lower curves of the plot type demo: two noisy lines over 16 points from 0 to 8."

	| random x |
	random := Random seed: 1.
	x := self linspaceFrom: 0 to: 8 count: 16.
	^ {
		  x.
		  (x collect: [ :each | 3 + (4 * each / 8) + (random next * 0.5) ]).
		  (x collect: [ :each | 1 + (2 * each / 8) + (random next * 0.5) ]) }
]

{ #category : 'private - demo' }
BpFillBetween class >> selectiveFillWhere: aBlock colorAt: anIndex interpolate: aBoolean [
	"Answer the fill between the two curves of the selective fill demo where aBlock answers true for their values, in the color anIndex of the default palette, half transparent."

	^ (self x: self selectiveX y1: self selectiveY1 y2: self selectiveY2)
		  where: (self selectiveY1 with: self selectiveY2 collect: aBlock);
		  color: (BpPalette default colorAt: anIndex);
		  alpha: 0.3;
		  interpolate: aBoolean;
		  yourself
]

{ #category : 'private - demo' }
BpFillBetween class >> selectiveX [
	"Answer the x of the selective fill demo."

	^ #( 0 1 2 3 )
]

{ #category : 'private - demo' }
BpFillBetween class >> selectiveY1 [
	"Answer the first curve of the selective fill demo, high then low."

	^ #( 0.8 0.8 0.2 0.2 )
]

{ #category : 'private - demo' }
BpFillBetween class >> selectiveY2 [
	"Answer the second curve of the selective fill demo, low then high."

	^ #( 0 0 1 1 )
]

{ #category : 'private - demo' }
BpFillBetween class >> stepDemoX [
	"Answer the x of the step demo."

	^ 1 to: 8
]

{ #category : 'private - demo' }
BpFillBetween class >> stepDemoY [
	"Answer the values of the step demo, one per x."

	^ #( 2 4 3 6 5 7 4 6 )
]

{ #category : 'private - demo' }
BpFillBetween class >> stepFill: aSymbol [
	"Answer the fill of the step demo down to 0 with the step style aSymbol, half transparent."

	^ (self x: self stepDemoX y1: self stepDemoY)
		  step: aSymbol;
		  alpha: 0.4;
		  yourself
]

{ #category : 'instance creation' }
BpFillBetween class >> x: aCollection y1: aCollectionOrNumber [
	"Answer the area between the curve aCollectionOrNumber over aCollection and 0."

	^ self x: aCollection y1: aCollectionOrNumber y2: 0
]

{ #category : 'instance creation' }
BpFillBetween class >> x: aCollection y1: aCollectionOrNumber y2: anotherCollectionOrNumber [
	"Answer the area between two curves over aCollection, each one value per x or one for all."

	^ self new
		  x: aCollection y1: aCollectionOrNumber y2: anotherCollectionOrNumber;
		  yourself
]

{ #category : 'instance creation' }
BpFillBetween class >> y: aCollection x1: aCollectionOrNumber [
	"Answer the area between the curve aCollectionOrNumber over the y values aCollection and 0 (see `BpFillBetween class>>y:x1:x2:`)."

	^ self y: aCollection x1: aCollectionOrNumber x2: 0
]

{ #category : 'instance creation' }
BpFillBetween class >> y: aCollection x1: aCollectionOrNumber x2: anotherCollectionOrNumber [
	"Answer the area between two curves over the y values aCollection, the horizontal counterpart of `BpFillBetween class>>x:y1:y2:`. The fill keeps the vocabulary of `x:y1:y2:`: y is its x, x1 and x2 its y1 and y2."

	^ self new
		  orientation: #horizontal;
		  x: aCollection y1: aCollectionOrNumber y2: anotherCollectionOrNumber;
		  yourself
]

{ #category : 'accessing - style' }
BpFillBetween >> color [

	^ color
]

{ #category : 'accessing - style' }
BpFillBetween >> color: aColor [
	"Set the color of the fill and of its outline."

	color := aColor.
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
BpFillBetween >> edgeColor: aColor [
	"Set the color of the outline only. The fill has no outline by default."

	edgeColor := aColor.
	self refresh
]

{ #category : 'accessing - style' }
BpFillBetween >> faceColor [

	^ faceColor
]

{ #category : 'accessing - style' }
BpFillBetween >> faceColor: aColor [
	"Set the color of the fill only; `Color transparent` leaves it empty."

	faceColor := aColor.
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
	"Answer a closed polygon through somePoints, given as (x @ y) of `BpChart>>fillBetweenX:y1:y2:`, styled and with my handlers."

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
	"Fill between curves of y over x (#vertical, `BpChart>>fillBetweenX:y1:y2:`, the default) or of x over y (#horizontal, `BpChart>>fillBetweenY:x1:x2:`)."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - patches' }
BpFillBetween >> oriented: aPoint [
	"Answer aPoint, given as (x @ y) of `BpChart>>fillBetweenX:y1:y2:`, in data coordinates: swapped for `BpChart>>fillBetweenY:x1:x2:`."

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
