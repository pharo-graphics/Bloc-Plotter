"
I am a scatter plot: the artist of matplotlib `Axes.scatter`. I show one `BpMarkerPatch` per point, whose `BpMarker`, size and color may vary from point to point: the numbers of `c:` are mapped to colors through a colormap.

## Examples

```
BpScatter scriptScatter.
BpScatter scriptScatterWithLegend.
BpScatter scriptMarkers.
BpScatter scriptInteraction.
BpScatter exampleColoredPoints
```

## Design Rationale

- My setters are the arguments of matplotlib `Axes.scatter`: `s:` (size in points squared, 36 by default), `c:` (a color, one per point, or numbers), `marker:`, `cmap:`, `vmin:`, `vmax:`, `alpha:`, `linewidths:`, `edgecolors:` ('face' by default, 'none', or colors) and `label:`. My results are `offsets` and `patches`.
- As in matplotlib, alpha applies to the faces and to the edges, and an unfilled marker ('+', 'x', an asterisk) is drawn with the face color.
- Numbers of `c:` are normalized between `vmin` and `vmax` (their smallest and largest by default), clipped, then mapped by the colormap: a name known by `BpColors class>>colormap:` or a block.

## Usage

1. `BpAxes>>scatterX:y:` creates me with `x:y:` and adds me to the axes (see `BpArtist`).
2. My patches answer their `index`, `dataPoint`, `area` and `amount` (the number of `c:`), which interaction handlers given to `whenPatch:do:` use.

## Implementation Notes

- My patches cover only their point in data coordinates, so autoscaling ignores the size of the markers, as matplotlib does.
- Not supported yet: `norm`, `plotnonfinite`, masked values and matplotlib `legend_elements`.

## Invariants and Assumptions

- x and y have the same size; `x:y:` raises an error otherwise.
"
Class {
	#name : 'BpScatter',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'y',
		's',
		'c',
		'marker',
		'cmap',
		'vmin',
		'vmax',
		'linewidths',
		'edgecolors',
		'offsets',
		'sizes',
		'values',
		'facecolors'
	],
	#category : 'Bloc-Plotter-Scatter',
	#package : 'Bloc-Plotter',
	#tag : 'Scatter'
}

{ #category : 'accessing' }
BpScatter class >> defaultSize [
	"Answer the marker size in points squared when none is given: the square of the matplotlib default marker size, 6 points."

	^ 36
]

{ #category : 'examples' }
BpScatter class >> exampleColoredPoints [
	"Answer a scatter of five points colored by a number through viridis, with growing sizes."

	<sampleInstance>
	^ ((BpAxes new
		    extent: 400 @ 300;
		    yourself) scatterX: #( 1 2 3 4 5 ) y: #( 2 4 3 5 1 ))
		  c: #( 1 2 3 4 5 );
		  s: #( 20 40 80 160 320 );
		  yourself
]

{ #category : 'examples' }
BpScatter class >> exampleInteractiveScatter [
	"A scatter with interaction handlers on its markers: hovering a marker outlines it, clicking it shows its point and value in the title."

	| random figure axes scatter |
	random := Random seed: 19680801.
	figure := BpFigure new.
	axes := figure axes first.
	scatter := axes scatterX: ((1 to: 50) collect: [ :each | random next ]) y: ((1 to: 50) collect: [ :each | random next ]).
	scatter
		c: ((1 to: 50) collect: [ :each | random next ]);
		s: 150;
		edgecolors: 'none'.
	axes title: 'Click a point'.
	scatter
		whenPatch: BlMouseEnterEvent do: [ :event :point | point border: (BlBorder paint: Color black width: 2) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :point | point border: BlBorder empty ];
		whenPatch: BlClickEvent do: [ :event :point |
			axes title: ('point {1}: ({2}, {3}), c = {4}' format: {
				 point index.
				 (point dataPoint x printShowingDecimalPlaces: 2).
				 (point dataPoint y printShowingDecimalPlaces: 2).
				 (point amount printShowingDecimalPlaces: 2) }) ].
	^ figure
]

{ #category : 'examples' }
BpScatter class >> exampleMarkers [
	"matplotlib gallery: Marker examples (scatter_star_poly): a marker symbol, a TeX symbol, a path, a pentagon, a star and an asterisk."

	| random x y z figure |
	random := Random seed: 19680801.
	x := (1 to: 10) collect: [ :each | random next ].
	y := (1 to: 10) collect: [ :each | random next ].
	z := x with: y collect: [ :eachX :eachY | (eachX squared + eachY squared) sqrt ].
	figure := BpFigure rows: 2 columns: 3.
	{
		('>' -> 'marker=''>''').
		('$\clubsuit$' -> 'marker=''$\clubsuit$''').
		(#( #( -1 -1 ) #( 1 -1 ) #( 1 1 ) #( -1 -1 ) ) -> 'marker=verts').
		(#( 5 0 ) -> 'marker=(5, 0)').
		(#( 5 1 ) -> 'marker=(5, 1)').
		(#( 5 2 ) -> 'marker=(5, 2)') } withIndexDo: [ :each :index |
			| axes |
			axes := figure axes at: index.
			(axes scatterX: x y: y)
				s: 80;
				c: z;
				marker: each key.
			axes title: each value ].
	^ figure
]

{ #category : 'examples' }
BpScatter class >> exampleScatter [
	"matplotlib gallery: Scatter plot (shapes_and_collections/scatter): random points with random sizes and colors."

	| random n x y colors area figure |
	random := Random seed: 19680801.
	n := 50.
	x := (1 to: n) collect: [ :each | random next ].
	y := (1 to: n) collect: [ :each | random next ].
	colors := (1 to: n) collect: [ :each | random next ].
	"0 to 15 point radii"
	area := (1 to: n) collect: [ :each | (30 * random next) squared ].
	figure := BpFigure new.
	(figure axes first scatterX: x y: y)
		s: area;
		c: colors;
		alpha: 0.5.
	^ figure
]

{ #category : 'examples' }
BpScatter class >> exampleScatterWithLegend [
	"matplotlib gallery: Scatter plot with a legend (scatter_with_legend), first figure: one scatter per color, each with a label."

	| random figure axes |
	random := Random seed: 19680801.
	figure := BpFigure new.
	axes := figure axes first.
	#( 'tab:blue' 'tab:orange' 'tab:green' ) do: [ :color |
		| n x y scale |
		n := 750.
		x := (1 to: n) collect: [ :each | random next ].
		y := (1 to: n) collect: [ :each | random next ].
		scale := (1 to: n) collect: [ :each | 200.0 * random next ].
		(axes scatterX: x y: y)
			c: color;
			s: scale;
			label: color;
			alpha: 0.3;
			edgecolors: 'none' ].
	axes
		legend;
		grid: true.
	^ figure
]

{ #category : 'script' }
BpScatter class >> scriptInteraction [
	"Interaction handlers on the markers of a scatter: hover a point to outline it, click it to see its coordinates and value."

	<example>
	^ self exampleInteractiveScatter show: 'Scatter interaction'
]

{ #category : 'script' }
BpScatter class >> scriptMarkers [
	"Reproduce the matplotlib gallery 'Marker examples': six ways to give the marker of a scatter."

	<example>
	^ self exampleMarkers show: 'scatter_star_poly'
]

{ #category : 'script' }
BpScatter class >> scriptScatter [
	"Reproduce the matplotlib gallery 'Scatter plot': random points with random sizes and colors, half transparent."

	<example>
	^ self exampleScatter show: 'scatter'
]

{ #category : 'script' }
BpScatter class >> scriptScatterWithLegend [
	"Reproduce the matplotlib gallery 'Scatter plot with a legend': three labeled scatters, a legend and a grid."

	<example>
	^ self exampleScatterWithLegend show: 'scatter_with_legend'
]

{ #category : 'instance creation' }
BpScatter class >> x: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	aCollectionOfNumbers size = anotherCollectionOfNumbers size ifFalse: [ ^ self error: 'x and y must be the same size' ].
	^ self new
		  setX: aCollectionOfNumbers y: anotherCollectionOfNumbers;
		  yourself
]

{ #category : 'accessing - options' }
BpScatter >> c: aColorOrCollection [
	"Set the color of the markers (matplotlib c): one color or color name, one per point, or one number per point mapped through my colormap."

	c := aColorOrCollection.
	self refresh
]

{ #category : 'accessing - options' }
BpScatter >> cmap: aNameOrBlock [
	"Set the colormap mapping the numbers of c: a name such as #viridis, or a block from a fraction between 0 and 1 to a color."

	cmap := aNameOrBlock.
	self refresh
]

{ #category : 'private - computing' }
BpScatter >> colorOf: aColorOrName [

	| color |
	color := aColorOrName isColor
		         ifTrue: [ aColorOrName ]
		         ifFalse: [ BpColors named: aColorOrName ].
	^ alpha ifNil: [ color ] ifNotNil: [ color alpha: alpha ]
]

{ #category : 'private - computing' }
BpScatter >> colormapBlock [

	^ cmap isBlock
		  ifTrue: [ cmap ]
		  ifFalse: [ BpColors colormap: cmap ]
]

{ #category : 'private - computing' }
BpScatter >> compute [

	offsets := x with: y collect: [ :eachX :eachY | eachX @ eachY ].
	sizes := (1 to: offsets size) collect: [ :index | self setting: (s ifNil: [ self class defaultSize ]) at: index ].
	values := self hasValues
		          ifTrue: [ c asArray ]
		          ifFalse: [ Array new: offsets size ].
	facecolors := (1 to: offsets size) collect: [ :index | self faceColorAt: index ]
]

{ #category : 'private - computing' }
BpScatter >> edgeColorAt: anIndex [
	"Answer the edge color of a point, or nil without edge. An unfilled marker is drawn with its face color, as matplotlib."

	| edge |
	marker isFilled ifFalse: [ ^ facecolors at: anIndex ].
	edge := self setting: edgecolors at: anIndex.
	edge = 'face' ifTrue: [ ^ facecolors at: anIndex ].
	edge = 'none' ifTrue: [ ^ nil ].
	^ self colorOf: edge
]

{ #category : 'accessing - options' }
BpScatter >> edgecolors: anObject [
	"Set the edge color of the markers: 'face' (the face color, the default), 'none', a color or color name, or one per point."

	edgecolors := anObject.
	self refresh
]

{ #category : 'private - computing' }
BpScatter >> faceColorAt: anIndex [

	c ifNil: [ ^ self colorOf: defaultColors first ].
	self hasValues ifTrue: [ ^ self colorOf: (self colormapBlock value: (self normalized: (c at: anIndex))) ].
	^ self colorOf: (self setting: c at: anIndex)
]

{ #category : 'private - computing' }
BpScatter >> hasValues [
	"Answer whether c gives numbers to map through the colormap."

	^ c isCollection and: [ c isString not and: [ c isNotEmpty and: [ c first isNumber ] ] ]
]

{ #category : 'initialization' }
BpScatter >> initialize [

	super initialize.
	x := #(  ).
	y := #(  ).
	marker := BpMarker on: 'o'.
	cmap := #viridis.
	linewidths := 1.5.
	edgecolors := 'face'.
	offsets := #(  ).
	sizes := #(  ).
	values := #(  ).
	facecolors := #(  )
]

{ #category : 'axes' }
BpScatter >> legendEntries [
	"Answer my label with a marker of my first point."

	(label isNil or: [ offsets isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> self newSwatch) }
]

{ #category : 'accessing - options' }
BpScatter >> linewidths: aNumberOrCollection [
	"Set the width of the marker edges in points, for all points or one per point."

	linewidths := aNumberOrCollection.
	self refresh
]

{ #category : 'accessing - options' }
BpScatter >> marker: aSpecification [
	"Set the marker of all points from a matplotlib specification (see BpMarker class>>on:)."

	marker := BpMarker on: aSpecification.
	self refresh
]

{ #category : 'private - computing' }
BpScatter >> newPatches [

	^ (1 to: offsets size) collect: [ :index |
		  | patch |
		  patch := BpMarkerPatch new
			           artist: self;
			           index: index;
			           dataPoint: (offsets at: index);
			           area: (sizes at: index);
			           amount: (values at: index);
			           marker: marker;
			           yourself.
		  patch updateShape.
		  self style: patch.
		  patch ]
]

{ #category : 'private - style' }
BpScatter >> newSwatch [

	| swatch |
	swatch := BpMarkerPatch new
		          index: 1;
		          area: (self class defaultSize min: sizes first);
		          marker: marker;
		          yourself.
	swatch
		updateShape;
		extent: (marker extentWithSide: swatch side).
	self style: swatch.
	^ swatch
]

{ #category : 'private - computing' }
BpScatter >> normalized: aNumber [
	"Answer aNumber as a fraction between vmin and vmax, clipped between 0 and 1."

	| low high |
	low := vmin ifNil: [ c min ].
	high := vmax ifNil: [ c max ].
	high = low ifTrue: [ ^ 0 ].
	^ (aNumber - low / (high - low) max: 0) min: 1
]

{ #category : 'accessing - results' }
BpScatter >> offsets [
	"Answer the points shown, in data coordinates (matplotlib PathCollection get_offsets)."

	^ offsets
]

{ #category : 'accessing - results' }
BpScatter >> patches [
	"Answer my marker patches, one per point."

	^ patches
]

{ #category : 'accessing - options' }
BpScatter >> s: aNumberOrCollection [
	"Set the marker size in points squared, for all points or one per point (matplotlib s)."

	s := aNumberOrCollection.
	self refresh
]

{ #category : 'initialization' }
BpScatter >> setX: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	x := aCollectionOfNumbers asArray.
	y := anotherCollectionOfNumbers asArray.
	self refresh
]

{ #category : 'private - style' }
BpScatter >> style: aPatch [
	"Give aPatch the colors of its point and the interaction handlers of the patches."

	| face edge |
	face := facecolors at: aPatch index.
	edge := self edgeColorAt: aPatch index.
	aPatch background: ((marker isFilled and: [ marker isText not ])
	 ifTrue: [ face ]
	 ifFalse: [ Color transparent ]).
	marker isText ifTrue: [ aPatch paintText: face ].
	aPatch border: ((edge isNil or: [ marker isText ])
	 ifTrue: [ BlBorder empty ]
	 ifFalse: [ BlBorder paint: edge width: (self setting: linewidths at: aPatch index) * self class pixelsPerPoint ]).
	patchHandlers do: [ :each | self addHandler: each to: aPatch ]
]

{ #category : 'accessing - options' }
BpScatter >> vmax: aNumber [
	"Set the number of c mapped to the end of the colormap (the largest one by default)."

	vmax := aNumber.
	self refresh
]

{ #category : 'accessing - options' }
BpScatter >> vmin: aNumber [
	"Set the number of c mapped to the start of the colormap (the smallest one by default)."

	vmin := aNumber.
	self refresh
]
