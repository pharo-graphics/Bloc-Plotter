"
I am a step curve of a `BpChart`: one horizontal step per value, between two consecutive `edges`, joined by vertical risers. I suit data that is constant over intervals, such as a histogram computed beforehand. I draw one `BpPolygonPatch`: an open outline, or a closed and filled polygon after `fill: true`.

## Examples

```
BpStairs examplePlotType.
BpStairs exampleStairsDemo.
BpStairs exampleInteraction
```

## Design Rationale

- Unlike a line through points, my values hold over intervals: there is one more edge than values, and the edges default to 0, 1, 2, ...
- `baseline:` sets where the outline starts and ends: a number (0 by default), one value per step for a bottom that varies (the outline then comes back along it), or nil for no vertical lines at both ends. Autoscaling adds no margin beyond the lowest baseline value, so steps stand on the axis as bars do.
- `color:` colors what I show: the outline when I am not filled, the fill when I am. A filled curve has no outline unless `lineWidth:` is given; `faceColor:` and `edgeColor:` set the fill and the outline one at a time.
- `orientation: #horizontal` puts the edges on the y axis, keeping the same vocabulary.
- Like bars, I am drawn below the grid.

## Usage

1. `BpStairs class>>values:` (edges 0, 1, 2, ...) and `BpStairs class>>values:edges:` create me with my data, and `BpChart>>addArtist:` adds me to a chart (see `BpArtist`), which gives me one color of its palette.
2. My chart reads my polygon (`patches`) for autoscaling and my `legendEntries` (a rectangle drawn as my outline or fill).

## Implementation Notes

- My vertices follow the outline of a step patch: with a number as baseline, (e0, b), (e0, v1), (e1, v1), (e1, v2), ... (en, vn), (en, b); some vertices repeat, which draws nothing more.
- I have one slot and setter per option, hence many slots.
- Not supported yet: hatches, NaN values splitting the curve.

## Invariants and Assumptions

- There is one more edge than values, and a baseline collection has one value per step; `values:edges:` changes both at once.
"
Class {
	#name : 'BpStairs',
	#superclass : 'BpArtist',
	#instVars : [
		'values',
		'edges',
		'baseline',
		'orientation',
		'fill',
		'color',
		'faceColor',
		'edgeColor',
		'lineWidth',
		'lineStyle'
	],
	#category : 'Bloc-Plotter-Stairs',
	#package : 'Bloc-Plotter',
	#tag : 'Stairs'
}

{ #category : 'private - demo' }
BpStairs class >> curveStepsOf: aBlock label: aString [
	"Answer steps of the values of aBlock at the middles of the bins 0 to 12, without baseline, labeled aString."

	^ (self values: ((0 to: 11) collect: [ :index | aBlock value: index + (1 / 2) ]) edges: (0 to: 12))
		  baseline: nil;
		  label: aString;
		  yourself
]

{ #category : 'examples' }
BpStairs class >> exampleInteraction [
	"Interaction handlers on step curves: hover one to thicken it, click it to see its name in the title."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart title: 'Click a step curve'.
	{
		self instanceSineSteps.
		self instanceCosineSteps.
		self instanceHalfSineSteps } do: [ :stairs |
			chart addArtist: stairs.
			stairs
				whenPatch: BlMouseEnterEvent do: [ :event :polygon | polygon border: (BlBorder paint: polygon border paint width: 4) ];
				whenPatch: BlMouseLeaveEvent do: [ :event :polygon | stairs paint: polygon ];
				whenPatch: BlClickEvent do: [ :event :polygon | chart title: ('clicked: {1}' format: { stairs legendEntries first key }) ] ].
	chart legend.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Stairs interaction'
]

{ #category : 'examples' }
BpStairs class >> examplePlotType [
	"Reproduce the plot type stairs(values): eight steps in a chart of fixed limits and ticks, with a grid."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: self instanceEightSteps.
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'stairs(values)'
]

{ #category : 'examples' }
BpStairs class >> exampleStairsDemo [
	"Reproduce the gallery 'Stairs Demo': step histograms with a modified baseline or none, filled and horizontal steps, and steps over given edges in fixed limits."

	<example>
	| figure |
	figure := BpFigure rows: 3 columns: 1.
	figure extent: 600 @ 900.
	figure
		chartAtRow: 1 column: 1 put: (BpChart new
			 addArtist: self instanceStepHistogram;
			 addArtist: self instanceStepHistogramOnABaseline;
			 addArtist: self instanceStepHistogramWithoutBaseline;
			 title: 'Step Histograms';
			 legend;
			 yourself);
		chartAtRow: 2 column: 1 put: (BpChart new
			 addArtist: self instanceFilledSteps;
			 addArtist: self instanceHorizontalSteps;
			 title: 'Filled histogram';
			 legend;
			 yourself);
		chartAtRow: 3 column: 1 put: (BpChart new
			 addArtist: self instancePyramidSteps;
			 xLimits: #( 0 7 );
			 yLimits: #( -1 5 );
			 title: 'BpStairs artist';
			 legend;
			 yourself).
	^ figure show: 'stairs_demo'
]

{ #category : 'instances' }
BpStairs class >> instanceCosineSteps [
	"Answer steps following a cosine on 12 bins, without baseline, labeled cos."

	<sampleInstance>
	^ self curveStepsOf: [ :each | (each / 2) cos ] label: 'cos'
]

{ #category : 'instances' }
BpStairs class >> instanceEightSteps [
	"Plot types: stairs(values), eight steps drawn 2.5 points wide."

	<sampleInstance>
	^ (self values: #( 4.8 5.5 3.5 4.6 6.5 6.6 2.6 3.0 ))
		  lineWidth: 2.5;
		  yourself
]

{ #category : 'instances' }
BpStairs class >> instanceFilledSteps [
	"Gallery: Stairs Demo (stairs_demo), second chart: filled steps of heights 1 to 5 between the edges 0 to 5 (see `BpStairs>>fill:`)."

	<sampleInstance>
	^ (self values: (1 to: 5))
		  fill: true;
		  label: 'Filled histogram w/ automatic edges';
		  yourself
]

{ #category : 'instances' }
BpStairs class >> instanceHalfSineSteps [
	"Answer steps following half a sine on 12 bins, without baseline, labeled half sin."

	<sampleInstance>
	^ self curveStepsOf: [ :each | (each / 2) sin / 2 ] label: 'half sin'
]

{ #category : 'instances' }
BpStairs class >> instanceHorizontalSteps [
	"Gallery: Stairs Demo (stairs_demo), second chart: steps along the y axis over the edges 2 to 7 (see `BpStairs>>orientation:`)."

	<sampleInstance>
	^ (self values: ((1 to: 5) collect: [ :each | each * 0.3 ]) edges: (2 to: 7))
		  orientation: #horizontal;
		  label: 'Histogram w/ horizontal orientation';
		  yourself
]

{ #category : 'instances' }
BpStairs class >> instancePyramidSteps [
	"Gallery: Stairs Demo (stairs_demo), third chart: steps of heights 1, 2, 3, 2 and 1 over the edges 1 to 6."

	<sampleInstance>
	^ (self values: #( 1 2 3 2 1 ) edges: (1 to: 6))
		  label: 'Artist added to the chart';
		  yourself
]

{ #category : 'instances' }
BpStairs class >> instanceSineSteps [
	"Answer steps following a sine on 12 bins, without baseline, labeled sin."

	<sampleInstance>
	^ self curveStepsOf: [ :each | (each / 2) sin ] label: 'sin'
]

{ #category : 'instances' }
BpStairs class >> instanceStepHistogram [
	"Gallery: Stairs Demo (stairs_demo), first chart: the counts of 5000 normal samples drawn as a step histogram on their 20 edges."

	<sampleInstance>
	^ (self stepHistogramShiftedBy: 0)
		  label: 'Simple histogram';
		  yourself
]

{ #category : 'instances' }
BpStairs class >> instanceStepHistogramOnABaseline [
	"Gallery: Stairs Demo (stairs_demo), first chart: the same step histogram shifted by 5, standing on a baseline at 50 (see `BpStairs>>baseline:`)."

	<sampleInstance>
	^ (self stepHistogramShiftedBy: 5)
		  baseline: 50;
		  label: 'Modified baseline';
		  yourself
]

{ #category : 'instances' }
BpStairs class >> instanceStepHistogramWithoutBaseline [
	"Gallery: Stairs Demo (stairs_demo), first chart: the same step histogram shifted by 10, without baseline, so without its outer edges."

	<sampleInstance>
	^ (self stepHistogramShiftedBy: 10)
		  baseline: nil;
		  label: 'No edges';
		  yourself
]

{ #category : 'instances' }
BpStairs class >> instanceSteps [
	"Answer steps of heights 1, 3, 2 and 4 between the edges 0 to 4."

	<sampleInstance>
	^ self values: #( 1 3 2 4 )
]

{ #category : 'private - demo' }
BpStairs class >> stepHistogramCounts [
	"Answer the counts of 5000 normal samples (mean 5, deviation 3) in the bins of the step histograms of the gallery stairs demo."

	| random |
	random := Random seed: 0.
	^ BpHistogramBinning
		  countsOf: ((1 to: 5000) collect: [ :each | random nextNormalMean: 5 deviation: 3 ])
		  weights: nil
		  in: self stepHistogramEdges
]

{ #category : 'private - demo' }
BpStairs class >> stepHistogramEdges [
	"Answer the 20 edges of the step histograms of the gallery stairs demo, from 0 to 10."

	^ self linspaceFrom: 0 to: 10 count: 20
]

{ #category : 'private - demo' }
BpStairs class >> stepHistogramShiftedBy: aNumber [
	"Answer the step histogram of the gallery stairs demo, its edges shifted by aNumber."

	^ self values: self stepHistogramCounts edges: (self stepHistogramEdges collect: [ :each | each + aNumber ])
]

{ #category : 'instance creation' }
BpStairs class >> values: aCollectionOfNumbers [
	"Answer steps of the heights aCollectionOfNumbers between the edges 0, 1, 2, ..."

	^ self new
		  values: aCollectionOfNumbers;
		  yourself
]

{ #category : 'instance creation' }
BpStairs class >> values: aCollectionOfNumbers edges: anotherCollectionOfNumbers [
	"Answer steps of the heights aCollectionOfNumbers between the edges anotherCollectionOfNumbers, one more than the heights."

	^ self new
		  values: aCollectionOfNumbers edges: anotherCollectionOfNumbers;
		  yourself
]

{ #category : 'accessing' }
BpStairs >> baseline: aNumberCollectionOrNil [
	"Set where the outline starts and ends: a number (0 by default), one value per step for a varying bottom, or nil to leave the ends open, without vertical lines down to a baseline."

	baseline := aNumberCollectionOrNil.
	self refresh
]

{ #category : 'accessing' }
BpStairs >> color: aColor [
	"Set the color of the outline, or of the fill when I am filled."

	color := aColor.
	self refresh
]

{ #category : 'private - computing' }
BpStairs >> compute [
	"Check that there is one more edge than values, and one baseline value per step when the baseline is a collection."

	self edges size = (values size + 1) ifFalse: [
		^ self error: ('{1} edges for {2} values: there must be one more edge than values' format: {
			   self edges size.
			   values size }) ].
	((self isMany: baseline) and: [ baseline size ~= values size ]) ifTrue: [
		^ self error: ('the baseline has {1} values for {2} steps' format: {
			   baseline size.
			   values size }) ]
]

{ #category : 'accessing' }
BpStairs >> edgeColor: aColor [
	"Set the color of the outline."

	edgeColor := aColor.
	self refresh
]

{ #category : 'accessing' }
BpStairs >> edges [
	"Answer the edges of the bins: the given ones, or 0, 1, 2, ... one more than the values."

	^ edges ifNil: [ (0 to: values size) asArray ]
]

{ #category : 'accessing' }
BpStairs >> edges: aCollectionOrNil [
	"Set the edges of the bins, one more than the values; nil places them at 0, 1, 2, ..."

	edges := aCollectionOrNil ifNotNil: [ aCollectionOrNil asArray ].
	self refresh
]

{ #category : 'accessing' }
BpStairs >> faceColor: aColor [
	"Set the fill color, used when I am filled."

	faceColor := aColor.
	self refresh
]

{ #category : 'accessing' }
BpStairs >> fill: aBoolean [
	"Fill the area under the steps (true) or draw only their outline (false, the default)."

	fill := aBoolean.
	self refresh
]

{ #category : 'initialization' }
BpStairs >> initialize [

	super initialize.
	values := #(  ).
	baseline := 0.
	orientation := #vertical.
	fill := false.
	lineStyle := #solid
]

{ #category : 'axes' }
BpStairs >> legendEntries [
	"Answer my label with a rectangle filled and outlined as my steps."

	(label isNil or: [ patches isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> (BlElement new
		    extent: 20 @ 10;
		    in: [ :swatch | self paint: swatch ];
		    yourself)) }
]

{ #category : 'accessing' }
BpStairs >> lineStyle: aSymbolOrString [
	"Set the line style of the outline: #solid, #dashed, #dashdot, #dotted, or a string such as '--'."

	lineStyle := self class lineStyleOf: aSymbolOrString.
	self refresh
]

{ #category : 'accessing' }
BpStairs >> lineWidth: aNumberOfPointsOrNil [
	"Set the width of the outline in points; nil, the default, gives 1 point when I am not filled and no outline when I am."

	lineWidth := aNumberOfPointsOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpStairs >> newPatches [
	"Answer my outline: an open polygon, or a closed one when I am filled."

	| polygon |
	values isEmpty ifTrue: [ ^ #(  ) ].
	polygon := BpPolygonPatch new
		           artist: self;
		           dataset: 1;
		           closed: fill;
		           dataVertices: (self vertices collect: [ :each | self oriented: each ]);
		           yourself.
	self paint: polygon.
	patchHandlers do: [ :each | self addHandler: each to: polygon ].
	^ { polygon }
]

{ #category : 'accessing' }
BpStairs >> orientation: aSymbol [
	"Set #vertical steps (the default) or #horizontal ones, whose edges are on the y axis."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - computing' }
BpStairs >> oriented: aPoint [
	"Answer aPoint, given as (edge @ value), in data coordinates: swapped when I am horizontal."

	^ orientation = #horizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'private - style' }
BpStairs >> outlineColor [
	"Answer the color of my outline: the edge color, else my color when I am not filled (it is the fill color when I am), else the color my chart gave me."

	edgeColor ifNotNil: [ ^ edgeColor ].
	(fill not and: [ color isNotNil ]) ifTrue: [ ^ color ].
	^ defaultColors first
]

{ #category : 'private - style' }
BpStairs >> outlineWidth [
	"Answer the width of my outline in points: the given one, else 1 when I am not filled and 0 (no outline) when I am."

	lineWidth ifNotNil: [ ^ lineWidth ].
	^ fill
		  ifTrue: [ 0 ]
		  ifFalse: [ 1 ]
]

{ #category : 'private - style' }
BpStairs >> paint: anElement [
	"Give anElement my fill (transparent unless I am filled) and my outline."

	anElement background: (fill
		 ifTrue: [ self paintOf: (faceColor ifNil: [ color ifNil: [ defaultColors first ] ]) ]
		 ifFalse: [ Color transparent ]).
	self outlineWidth isZero ifTrue: [ ^ self ].
	anElement border: (self strokeColor: (self paintOf: self outlineColor) width: self outlineWidth style: lineStyle)
]

{ #category : 'axes' }
BpStairs >> stickyValuesOn: anAxis [
	"Answer the lowest value of my baseline on my value axis: autoscaling adds no margin beyond it."

	| valueAxis |
	valueAxis := orientation = #horizontal
		             ifTrue: [ #x ]
		             ifFalse: [ #y ].
	(baseline isNil or: [ anAxis ~= valueAxis ]) ifTrue: [ ^ #(  ) ].
	^ (self isMany: baseline)
		  ifTrue: [ { baseline min } ]
		  ifFalse: [ { baseline } ]
]

{ #category : 'accessing' }
BpStairs >> values: aCollectionOfNumbers [
	"Set the heights of the steps, one per bin."

	values := aCollectionOfNumbers asArray.
	self refresh
]

{ #category : 'accessing' }
BpStairs >> values: aCollectionOfNumbers edges: aCollectionOrNil [
	"Set the heights of the steps and the edges of their bins at once."

	values := aCollectionOfNumbers asArray.
	edges := aCollectionOrNil ifNotNil: [ aCollectionOrNil asArray ].
	self refresh
]

{ #category : 'private - computing' }
BpStairs >> vertices [
	"Answer the vertices of my outline, as (edge @ value) before orientation: up from the baseline, along each step, and down to the baseline; along the baseline back when it varies, or without the vertical ends when there is none."

	| xs ys bottoms |
	xs := self edges flatCollect: [ :each |
		      {
			      each.
			      each } ].
	ys := values flatCollect: [ :each |
		      {
			      each.
			      each } ].
	baseline ifNil: [ ys := { ys first } , ys , { ys last } ].
	(self isMany: baseline)
		ifTrue: [
			bottoms := (baseline flatCollect: [ :each |
				            {
					            each.
					            each } ]) reversed.
			ys := { bottoms last } , ys , {
				      bottoms first.
				      bottoms first } , bottoms , { bottoms last }.
			xs := xs , xs reversed ]
		ifFalse: [ baseline ifNotNil: [ ys := { baseline } , ys , { baseline } ] ].
	^ xs with: ys collect: [ :edge :value | edge @ value ]
]
