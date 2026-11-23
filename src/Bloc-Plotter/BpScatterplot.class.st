"
I am a scatter plot, added by `BpAxes>>scatterX:y:`. I show one `BpMarkerPatch` per point, whose `BpMarker`, size and color may vary from point to point: the numbers of `c:` are mapped to colors through a colormap.

## Examples

```
BpScatterPlot scriptScatter.
BpScatterPlot scriptScatterWithLegend.
BpScatterPlot scriptMarkers.
BpScatterPlot scriptInteraction.
BpScatterPlot exampleColoredPoints
```

## Design Rationale

- My setters are `s:` (size in points squared, 36 by default), `c:` (a color, one per point, or numbers), `marker:`, `colorMap:`, `vMin:`, `vMax:`, `alpha:`, `lineWidths:`, `edgeColors:` ('face' by default, 'none', or colors) and `label:`. My results are `offsets` and `patches`.
- Alpha applies to the faces and to the edges, and an unfilled marker ('+', 'x', an asterisk) is drawn with the face color.
- Numbers of `c:` are normalized between `vMin` and `vMax` (their smallest and largest by default), clipped, then mapped by the colormap: a name known by `BpColors class>>colorMap:` or a block.

## Usage

1. `BpAxes>>scatterX:y:` creates me with `x:y:` and adds me to the axes (see `BpArtist`).
2. My patches answer their `index`, `dataPoint`, `area` and `amount` (the number of `c:`), which interaction handlers given to `whenPatch:do:` use.

## Implementation Notes

- My patches cover only their point in data coordinates, so autoscaling ignores the size of the markers.
- Not supported yet: normalizations other than linear, non-finite and masked values, and legend entries built from the sizes or colors.

## Invariants and Assumptions

- x and y have the same size; `x:y:` raises an error otherwise.
"
Class {
	#name : 'BpScatterPlot',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'y',
		's',
		'c',
		'marker',
		'offsets',
		'sizes',
		'values',
		'lineWidths',
		'faceColors',
		'edgeColors',
		'colorMap',
		'vMin',
		'vMax'
	],
	#category : 'Bloc-Plotter-Scatter',
	#package : 'Bloc-Plotter',
	#tag : 'Scatter'
}

{ #category : 'accessing' }
BpScatterPlot class >> defaultSize [
	"Answer the marker size in points squared when none is given: the square of the default marker size, 6 points."

	^ 36
]

{ #category : 'examples' }
BpScatterPlot class >> exampleColoredPoints [
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
BpScatterPlot class >> exampleInteractiveScatter [
	"A scatter with interaction handlers on its markers: hovering a marker outlines it, clicking it shows its point and value in the title."

	<sampleInstance>
	| random figure axes scatter |
	random := Random seed: 19680801.
	figure := BpFigure new.
	axes := figure axes first.
	scatter := axes scatterX: ((1 to: 50) collect: [ :each | random next ]) y: ((1 to: 50) collect: [ :each | random next ]).
	scatter
		c: ((1 to: 50) collect: [ :each | random next ]);
		s: 150;
		edgeColors: 'none'.
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
BpScatterPlot class >> exampleMarkers [
	"Gallery: Marker examples (scatter_star_poly): a marker symbol, a TeX symbol, a path, a pentagon, a star and an asterisk."

	<sampleInstance>
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
BpScatterPlot class >> exampleScatter [
	"Gallery: Scatter plot (shapes_and_collections/scatter): random points with random sizes and colors."

	<sampleInstance>
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
BpScatterPlot class >> exampleScatterWithLegend [
	"Gallery: Scatter plot with a legend (scatter_with_legend), first figure: one scatter per color, each with a label."

	<sampleInstance>
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
			edgeColors: 'none' ].
	axes
		legend;
		grid: true.
	^ figure
]

{ #category : 'script' }
BpScatterPlot class >> scriptInteraction [
	"Interaction handlers on the markers of a scatter: hover a point to outline it, click it to see its coordinates and value."

	<example>
	^ self exampleInteractiveScatter show: 'Scatter interaction'
]

{ #category : 'script' }
BpScatterPlot class >> scriptMarkers [
	"Reproduce the gallery 'Marker examples': six ways to give the marker of a scatter."

	<example>
	^ self exampleMarkers show: 'scatter_star_poly'
]

{ #category : 'script' }
BpScatterPlot class >> scriptScatter [
	"Reproduce the gallery 'Scatter plot': random points with random sizes and colors, half transparent."

	<example>
	^ self exampleScatter show: 'scatter'
]

{ #category : 'script' }
BpScatterPlot class >> scriptScatterWithLegend [
	"Reproduce the gallery 'Scatter plot with a legend': three labeled scatters, a legend and a grid."

	<example>
	^ self exampleScatterWithLegend show: 'scatter_with_legend'
]

{ #category : 'instance creation' }
BpScatterPlot class >> x: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	aCollectionOfNumbers size = anotherCollectionOfNumbers size ifFalse: [ ^ self error: 'x and y must be the same size' ].
	^ self new
		  setX: aCollectionOfNumbers y: anotherCollectionOfNumbers;
		  yourself
]

{ #category : 'accessing - options' }
BpScatterPlot >> c: aColorOrCollection [
	"Set the color of the markers: one color or color name, one per point, or one number per point mapped through my colormap."

	c := aColorOrCollection.
	self refresh
]

{ #category : 'accessing - options' }
BpScatterPlot >> colorMap: aNameOrBlock [
	"Set the colormap mapping the numbers of c: a name such as #viridis, or a block from a fraction between 0 and 1 to a color."

	colorMap := aNameOrBlock.
	self refresh
]

{ #category : 'private - computing' }
BpScatterPlot >> colorMapBlock [

	^ colorMap isBlock
		  ifTrue: [ colorMap ]
		  ifFalse: [ BpColors colorMap: colorMap ]
]

{ #category : 'private - computing' }
BpScatterPlot >> compute [

	offsets := x with: y collect: [ :eachX :eachY | eachX @ eachY ].
	sizes := (1 to: offsets size) collect: [ :index | self setting: (s ifNil: [ self class defaultSize ]) at: index ].
	values := self hasValues
		          ifTrue: [ c asArray ]
		          ifFalse: [ Array new: offsets size ].
	faceColors := (1 to: offsets size) collect: [ :index | self faceColorAt: index ]
]

{ #category : 'private - computing' }
BpScatterPlot >> edgeColorAt: anIndex [
	"Answer the edge color of a point, or nil without edge. An unfilled marker is drawn with its face color."

	| edge |
	marker isFilled ifFalse: [ ^ faceColors at: anIndex ].
	edge := self setting: edgeColors at: anIndex.
	edge = 'face' ifTrue: [ ^ faceColors at: anIndex ].
	edge = 'none' ifTrue: [ ^ nil ].
	^ self colorOf: edge
]

{ #category : 'accessing - options' }
BpScatterPlot >> edgeColors: anObject [
	"Set the edge color of the markers: 'face' (the face color, the default), 'none', a color or color name, or one per point."

	edgeColors := anObject.
	self refresh
]

{ #category : 'private - computing' }
BpScatterPlot >> faceColorAt: anIndex [

	c ifNil: [ ^ self colorOf: defaultColors first ].
	self hasValues ifTrue: [ ^ self colorOf: (self colorMapBlock value: (self normalized: (c at: anIndex))) ].
	^ self colorOf: (self setting: c at: anIndex)
]

{ #category : 'private - computing' }
BpScatterPlot >> hasValues [
	"Answer whether c gives numbers to map through the colormap."

	^ c isCollection and: [ c isString not and: [ c isNotEmpty and: [ c first isNumber ] ] ]
]

{ #category : 'initialization' }
BpScatterPlot >> initialize [

	super initialize.
	x := #(  ).
	y := #(  ).
	marker := BpMarker on: 'o'.
	colorMap := #viridis.
	lineWidths := 1.5.
	edgeColors := 'face'.
	offsets := #(  ).
	sizes := #(  ).
	values := #(  ).
	faceColors := #(  )
]

{ #category : 'axes' }
BpScatterPlot >> legendEntries [
	"Answer my label with a marker of my first point."

	(label isNil or: [ offsets isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> self newSwatch) }
]

{ #category : 'accessing - options' }
BpScatterPlot >> lineWidths: aNumberOrCollection [
	"Set the width of the marker edges in points, for all points or one per point."

	lineWidths := aNumberOrCollection.
	self refresh
]

{ #category : 'accessing - options' }
BpScatterPlot >> marker: aSpecification [
	"Set the marker of all points from a marker specification (see BpMarker class>>on:)."

	marker := BpMarker on: aSpecification.
	self refresh
]

{ #category : 'private - computing' }
BpScatterPlot >> newPatches [

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
BpScatterPlot >> newSwatch [

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
BpScatterPlot >> normalized: aNumber [
	"Answer aNumber as a fraction between vMin and vMax, clipped between 0 and 1."

	| low high |
	low := vMin ifNil: [ c min ].
	high := vMax ifNil: [ c max ].
	high = low ifTrue: [ ^ 0 ].
	^ (aNumber - low / (high - low) max: 0) min: 1
]

{ #category : 'accessing - results' }
BpScatterPlot >> offsets [
	"Answer the points shown, in data coordinates."

	^ offsets
]

{ #category : 'accessing - options' }
BpScatterPlot >> s: aNumberOrCollection [
	"Set the marker size in points squared, for all points or one per point."

	s := aNumberOrCollection.
	self refresh
]

{ #category : 'initialization' }
BpScatterPlot >> setX: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	x := aCollectionOfNumbers asArray.
	y := anotherCollectionOfNumbers asArray.
	self refresh
]

{ #category : 'private - style' }
BpScatterPlot >> style: aPatch [
	"Give aPatch the colors of its point and the interaction handlers of the patches."

	| face edge |
	face := faceColors at: aPatch index.
	edge := self edgeColorAt: aPatch index.
	aPatch background: ((marker isFilled and: [ marker isText not ])
		 ifTrue: [ face ]
		 ifFalse: [ Color transparent ]).
	marker isText ifTrue: [ aPatch paintText: face ].
	aPatch border: ((edge isNil or: [ marker isText ])
		 ifTrue: [ BlBorder empty ]
		 ifFalse: [ BlBorder paint: edge width: (self setting: lineWidths at: aPatch index) * self class pixelsPerPoint ]).
	patchHandlers do: [ :each | self addHandler: each to: aPatch ]
]

{ #category : 'accessing - options' }
BpScatterPlot >> vMax: aNumber [
	"Set the number of c mapped to the end of the colormap (the largest one by default)."

	vMax := aNumber.
	self refresh
]

{ #category : 'accessing - options' }
BpScatterPlot >> vMin: aNumber [
	"Set the number of c mapped to the start of the colormap (the smallest one by default)."

	vMin := aNumber.
	self refresh
]
