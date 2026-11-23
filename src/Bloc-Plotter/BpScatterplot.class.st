"
I am a scatter plot, added by `BpChart>>scatterX:y:`. I show one `BpMarkerPatch` per point, whose `BpMarker`, size and color may vary from point to point: the numbers of `c:` are mapped to colors through a color map.

## Examples

```
BpScatterPlot exampleScatter.
BpScatterPlot exampleScatterWithLegend.
BpScatterPlot exampleMarkers.
BpScatterPlot exampleInteraction
```

## Design Rationale

- My setters are `s:` (size in points squared, 36 by default), `c:` (a color, one per point, or numbers), `marker:`, `colorMap:`, `vMin:`, `vMax:`, `alpha:`, `lineWidths:`, `edgeColors:` (nil, the face color, by default; `Color transparent` for no edge; a color or one per point) and `label:`. My results are `offsets` and `patches`.
- Alpha applies to the faces and to the edges, and an unfilled marker ('+', 'x', an asterisk) is drawn with the face color.
- Numbers of `c:` are mapped to colors by a `BpColorScale`: placed between `vMin` and `vMax` (their smallest and largest by default), clipped, then mapped by the color map, a `BpInterpolatedPalette` (`BpInterpolatedPalette class>>viridis` by default) or a block.

## Usage

1. `BpChart>>scatterX:y:` creates me with `x:y:` and adds me to the chart (see `BpArtist`).
2. `BpChart>>addColorBarFor:` tells the numbers of `c:` with a `BpColorBar`.
3. My patches answer their `index`, `dataPoint`, `area` and `amount` (the number of `c:`), which interaction handlers given to `whenPatch:do:` use.

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
		'colorScale'
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
BpScatterPlot class >> exampleInteraction [
	"Interaction handlers on the markers of a scatter: hover a point to outline it, click it to see its coordinates and value."

	<example>
	^ BpFigure instanceInteractiveScatter show: 'Scatter interaction'
]

{ #category : 'examples' }
BpScatterPlot class >> exampleMarkers [
	"Reproduce the gallery 'Marker examples': six ways to give the marker of a scatter."

	<example>
	^ BpFigure instanceScatterMarkers show: 'scatter_star_poly'
]

{ #category : 'examples' }
BpScatterPlot class >> exampleScatter [
	"Reproduce the gallery 'Scatter plot': random points with random sizes and colors, half transparent."

	<example>
	^ BpFigure instanceScatter show: 'scatter'
]

{ #category : 'examples' }
BpScatterPlot class >> exampleScatterWithLegend [
	"Reproduce the gallery 'Scatter plot with a legend': three labeled scatters, a legend and a grid."

	<example>
	^ BpFigure instanceScatterWithLegend show: 'scatter_with_legend'
]

{ #category : 'instances' }
BpScatterPlot class >> instanceColoredPoints [
	"Answer a scatter of five points colored by a number through viridis, with growing sizes."

	<sampleInstance>
	^ ((BpChart new
		    extent: 400 @ 300;
		    yourself) scatterX: #( 1 2 3 4 5 ) y: #( 2 4 3 5 1 ))
		  c: #( 1 2 3 4 5 );
		  s: #( 20 40 80 160 320 );
		  yourself
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
	"Set the color of the markers: one color, one per point, or one number per point mapped through my color map."

	c := aColorOrCollection.
	self refresh
]

{ #category : 'accessing - options' }
BpScatterPlot >> colorMap: aPaletteOrBlock [
	"Set what maps the numbers of c to colors: a `BpInterpolatedPalette`, or a block from a fraction between 0 and 1 to a color."

	colorScale colorMap: aPaletteOrBlock.
	self refresh
]

{ #category : 'axes' }
BpScatterPlot >> colorScale [
	"Answer what maps the numbers of c to colors."

	^ colorScale
]

{ #category : 'private - computing' }
BpScatterPlot >> compute [

	offsets := x with: y collect: [ :eachX :eachY | eachX @ eachY ].
	sizes := (1 to: offsets size) collect: [ :index | self setting: (s ifNil: [ self class defaultSize ]) at: index ].
	values := self hasValues
		          ifTrue: [ c asArray ]
		          ifFalse: [ Array new: offsets size ].
	self hasValues ifTrue: [ colorScale fitTo: c ].
	faceColors := (1 to: offsets size) collect: [ :index | self faceColorAt: index ]
]

{ #category : 'private - computing' }
BpScatterPlot >> edgeColorAt: anIndex [
	"Answer the edge color of a point, or nil without edge. An unfilled marker is drawn with its face color."

	| edge |
	marker isFilled ifFalse: [ ^ faceColors at: anIndex ].
	edge := self setting: edgeColors at: anIndex.
	edge ifNil: [ ^ faceColors at: anIndex ].
	edge isTransparent ifTrue: [ ^ nil ].
	^ self colorOf: edge
]

{ #category : 'accessing - options' }
BpScatterPlot >> edgeColors: anObject [
	"Set the edge color of the markers, one for all or one per point. Without it (nil) the edge has the face color; `Color transparent` draws no edge."

	edgeColors := anObject.
	self refresh
]

{ #category : 'private - computing' }
BpScatterPlot >> faceColorAt: anIndex [

	c ifNil: [ ^ self colorOf: defaultColors first ].
	self hasValues ifTrue: [ ^ self colorOf: (colorScale colorFor: (c at: anIndex)) ].
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
	colorScale := BpColorScale new.
	lineWidths := 1.5.
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

{ #category : 'axes' }
BpScatterPlot >> showsNumbersByColors [
	"Answer whether c gives numbers."

	^ self hasValues
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

	colorScale vMax: aNumber.
	self refresh
]

{ #category : 'accessing - options' }
BpScatterPlot >> vMin: aNumber [
	"Set the number of c mapped to the start of the colormap (the smallest one by default)."

	colorScale vMin: aNumber.
	self refresh
]
