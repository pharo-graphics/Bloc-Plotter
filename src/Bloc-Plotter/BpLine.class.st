"
I am a line plot of a `BpAxes` (`BpAxes>>plotX:y:`): a line through points given by their x and y values, with an optional marker at each point. `format:` reads a format string such as 'o-' or 'r--'; the setters (`color:`, `lineStyle:`, `lineWidth:`, `marker:`, `markerSize:`, `markerFaceColor:`, `markerEdgeColor:`, `markerEdgeWidth:`) set one property each.

## Examples

```
BpLine exampleSine.
BpLine scriptPlotType.
BpLine scriptFormats
```

## Design Rationale

- My line is one `BpPolygonPatch` (open) through all the points, and each marker is a `BpMarkerPatch`, as in `BpScatterPlot`: interaction handlers (`whenPatch:do:`) can tell the line from the points.
- A format string sets the same slots as the setters, so a setter sent afterwards wins over the format. A marker without a line style draws no line ('o' draws only circles), and a string that is only a color name ('tan', 'C1') sets only the color.
- My defaults are 1.5 point wide lines, 6 point markers with 1 point edges, and dashes that grow with the width of the line (`dashPatterns`, in points for a one point line). Solid lines have projecting caps, dashed ones butt caps.
- My patches are drawn above the grid (`isAboveGrid`), while bars and scatter points are drawn below.

## Usage

1. `BpAxes>>plotX:y:` and `BpAxes>>plotX:y:format:` create me and add me to the axes; see `BpArtist` for the rest of the life cycle. `BpErrorBar` adds error bars to my points.
2. My legend entry (`legendEntries`) is a short piece of my line with one marker in its middle.

## Invariants and Assumptions

- x and y have the same size (`x:y:` raises an error otherwise). Marker sizes are diameters in points, so a marker patch has an area of `markerSize squared`, as the `s` of `BpScatterPlot`.
"
Class {
	#name : 'BpLine',
	#superclass : 'BpArtist',
	#instVars : [
		'x',
		'y',
		'color',
		'marker',
		'linePatch',
		'markerPatches',
		'points',
		'lineWidth',
		'markerFaceColor',
		'markerSize',
		'markerEdgeColor',
		'lineStyle',
		'markerEdgeWidth'
	],
	#category : 'Bloc-Plotter-Plot',
	#package : 'Bloc-Plotter',
	#tag : 'Plot'
}

{ #category : 'constants' }
BpLine class >> defaultLineWidth [

	^ 1.5
]

{ #category : 'constants' }
BpLine class >> defaultMarkerEdgeWidth [

	^ 1
]

{ #category : 'constants' }
BpLine class >> defaultMarkerSize [

	^ 6
]

{ #category : 'examples' }
BpLine class >> exampleFormats [
	"Answer the figure of the pyplot tutorial drawing three curves with format strings ('r--', 'bs', 'g^') and a legend."

	<sampleInstance>
	| figure axes t |
	t := (0 to: 24) collect: [ :index | index / 5 ].
	figure := BpFigure new.
	axes := figure axes first.
	(axes plotX: t y: t format: 'r--') label: 'linear'.
	(axes plotX: t y: (t collect: [ :each | each squared ]) format: 'bs') label: 'quadratic'.
	(axes plotX: t y: (t collect: [ :each | each raisedTo: 3 ]) format: 'g^') label: 'cubic'.
	axes
		title: 'Format strings';
		legend.
	^ figure
]

{ #category : 'examples' }
BpLine class >> examplePlotType [
	"Answer the figure of the plot type page (plot_types/basic/plot): markers only, a line, and a line with markers, with fixed limits and ticks."

	<sampleInstance>
	| figure axes x y x2 y2 |
	x := (0 to: 99) collect: [ :index | index * 10 / 99.0 ].
	y := x collect: [ :each | 4 + (2 * each) sin ].
	x2 := (0 to: 24) collect: [ :index | index * 10 / 24.0 ].
	y2 := x2 collect: [ :each | 4 + (2 * each) sin ].
	figure := BpFigure new.
	axes := figure axes first.
	(axes plotX: x2 y: (y2 collect: [ :each | each + 2.5 ]) format: 'x') markerEdgeWidth: 2.
	(axes plotX: x y: y) lineWidth: 2.
	(axes plotX: x2 y: (y2 collect: [ :each | each - 2.5 ]) format: 'o-') lineWidth: 2.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	^ figure
]

{ #category : 'examples' }
BpLine class >> exampleSine [
	"Answer a sine line with circle markers."

	<sampleInstance>
	^ (self
		   x: ((0 to: 24) collect: [ :index | index * 10 / 24.0 ])
		   y: ((0 to: 24) collect: [ :index | 4 + (2 * index * 10 / 24.0) sin ]))
		  format: 'o-';
		  yourself
]

{ #category : 'format' }
BpLine class >> formatPartsOf: aString [
	"Answer the parts of the format string aString, as a dictionary with the keys #marker, #lineStyle and #color."

	| stream parts |
	parts := Dictionary new.
	stream := aString readStream.
	[ stream atEnd ] whileFalse: [ self readFormatPartFrom: stream into: parts ].
	^ parts
]

{ #category : 'format' }
BpLine class >> readFormatPartFrom: aStream into: aDictionary [

	| char |
	char := aStream next.
	('-:' includes: char) ifTrue: [
		^ aDictionary at: #lineStyle put: (self lineStyleNames at: ((char = $- and: [ '-.' includes: aStream peek ])
			    ifTrue: [ String with: char with: aStream next ]
			    ifFalse: [ String with: char ])) ].
	(char = $C and: [ aStream peek isNotNil and: [ aStream peek isDigit ] ]) ifTrue: [
		^ aDictionary at: #color put: (String with: char with: aStream next) ].
	('bgrcmykw' includes: char) ifTrue: [ ^ aDictionary at: #color put: (String with: char) ].
	(BpMarker namedMarkers includesKey: (String with: char)) ifTrue: [ ^ aDictionary at: #marker put: (String with: char) ].
	^ self error: 'Unknown format character: ' , char printString
]

{ #category : 'script' }
BpLine class >> scriptFormats [
	"Show three curves drawn with format strings (see `BpLine>>format:`) and their legend."

	<example>
	^ self exampleFormats show: 'plot format strings'
]

{ #category : 'script' }
BpLine class >> scriptPlotType [
	"Show the figure of the plot type page: markers only, a line, and a line with markers."

	<example>
	^ self examplePlotType show: 'plot'
]

{ #category : 'constants' }
BpLine class >> swatchExtent [
	"Answer the extent of my legend swatch, in pixels."

	^ 28 @ 14
]

{ #category : 'instance creation' }
BpLine class >> x: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	aCollectionOfNumbers size = anotherCollectionOfNumbers size ifFalse: [ ^ self error: 'x and y must be the same size' ].
	^ self new
		  setX: aCollectionOfNumbers y: anotherCollectionOfNumbers;
		  yourself
]

{ #category : 'accessing' }
BpLine >> color: aColorOrName [
	"Set the color of my line and, by default, of my markers."

	color := aColorOrName.
	self refresh
]

{ #category : 'private - computing' }
BpLine >> compute [

	points := x with: y collect: [ :eachX :eachY | eachX @ eachY ]
]

{ #category : 'private' }
BpLine >> edgeColor [

	^ markerEdgeColor ifNil: [ self lineColor ] ifNotNil: [ self colorOf: markerEdgeColor ]
]

{ #category : 'private' }
BpLine >> faceColor [

	^ markerFaceColor ifNil: [ self lineColor ] ifNotNil: [ self colorOf: markerFaceColor ]
]

{ #category : 'accessing - format' }
BpLine >> format: aString [
	"Set my marker, line style and color from a format string '[marker][line][color]', in any order ('o-', 'r--', '^k:', 'C1', or a whole color name such as 'tan'). A marker without a line style draws no line. Setters sent afterwards win."

	| parts |
	(self isColorName: aString) ifTrue: [ ^ self color: aString ].
	parts := self class formatPartsOf: aString.
	parts at: #color ifPresent: [ :each | color := each ].
	parts at: #marker ifPresent: [ :each | marker := BpMarker on: each ].
	lineStyle := parts at: #lineStyle ifAbsent: [
		             (parts includesKey: #marker)
			             ifTrue: [ #none ]
			             ifFalse: [ #solid ] ].
	self refresh
]

{ #category : 'initialization' }
BpLine >> initialize [

	super initialize.
	x := #(  ).
	y := #(  ).
	lineStyle := #solid.
	lineWidth := self class defaultLineWidth.
	markerSize := self class defaultMarkerSize.
	markerEdgeWidth := self class defaultMarkerEdgeWidth.
	markerPatches := #(  )
]

{ #category : 'axes' }
BpLine >> isAboveGrid [

	^ true
]

{ #category : 'axes' }
BpLine >> legendEntries [
	"Answer my label with a short piece of my line, with one marker in its middle."

	(label isNil or: [ points isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> self newSwatch) }
]

{ #category : 'private' }
BpLine >> lineBorder [
	"Answer the stroke of my line."

	^ self strokeColor: self lineColor width: lineWidth style: lineStyle
]

{ #category : 'private' }
BpLine >> lineColor [

	^ self colorOf: (color ifNil: [ defaultColors first ])
]

{ #category : 'accessing' }
BpLine >> linePatch [

	^ linePatch
]

{ #category : 'accessing' }
BpLine >> lineStyle: aSymbolOrString [
	"Set my line style: #solid, #dashed, #dashdot, #dotted or #none, or a string ('-', '--', '-.', ':', 'None', ...)."

	lineStyle := self class lineStyleOf: aSymbolOrString.
	self refresh
]

{ #category : 'accessing' }
BpLine >> lineWidth: aNumber [
	"Set the width of my line, in points."

	lineWidth := aNumber.
	self refresh
]

{ #category : 'accessing' }
BpLine >> marker: aMarkerSpec [
	"Set the marker drawn at each point, as `BpMarker class>>on:` accepts it ('o', 's', '^', ...); nil draws none."

	marker := aMarkerSpec ifNotNil: [ BpMarker on: aMarkerSpec ].
	self refresh
]

{ #category : 'accessing' }
BpLine >> markerEdgeColor: aColorOrName [

	markerEdgeColor := aColorOrName.
	self refresh
]

{ #category : 'accessing' }
BpLine >> markerEdgeWidth: aNumber [
	"Set the width of the edges of my markers, in points."

	markerEdgeWidth := aNumber.
	self refresh
]

{ #category : 'accessing' }
BpLine >> markerFaceColor: aColorOrName [

	markerFaceColor := aColorOrName.
	self refresh
]

{ #category : 'accessing' }
BpLine >> markerPatches [

	^ markerPatches
]

{ #category : 'accessing' }
BpLine >> markerSize: aNumber [
	"Set the size of my markers, in points."

	markerSize := aNumber.
	self refresh
]

{ #category : 'private - computing' }
BpLine >> newLinePatch [

	| patch |
	patch := BpPolygonPatch new
		         artist: self;
		         closed: false;
		         dataVertices: points;
		         yourself.
	patch
		background: Color transparent;
		border: self lineBorder.
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'private - computing' }
BpLine >> newMarkerPatchAt: aPoint index: anIndex [

	| patch |
	patch := BpMarkerPatch new
		         artist: self;
		         index: anIndex;
		         dataPoint: aPoint;
		         area: markerSize squared;
		         marker: marker;
		         yourself.
	patch updateShape.
	self styleMarker: patch.
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'private - computing' }
BpLine >> newPatches [
	"Answer my line, unless my line style is #none, then a marker patch per point when I have a marker."

	linePatch := (lineStyle = #none or: [ points isEmpty ]) ifFalse: [ self newLinePatch ].
	markerPatches := marker
		                 ifNil: [ #(  ) ]
		                 ifNotNil: [ points withIndexCollect: [ :each :index | self newMarkerPatchAt: each index: index ] ].
	^ (linePatch ifNil: [ #(  ) ] ifNotNil: [ { linePatch } ]) , markerPatches
]

{ #category : 'private - computing' }
BpLine >> newSwatch [

	| width height swatch |
	width := self class swatchExtent x.
	height := self class swatchExtent y.
	swatch := BlElement new
		          extent: width @ height;
		          yourself.
	lineStyle = #none ifFalse: [
		swatch addChild: (BlElement new
			 geometry: (BlLineGeometry from: 0 @ (height / 2) to: width @ (height / 2));
			 border: self lineBorder;
			 extent: width @ height;
			 yourself) ].
	marker ifNotNil: [
		| patch side |
		patch := BpMarkerPatch new
			         index: 1;
			         area: markerSize squared;
			         marker: marker;
			         yourself.
		patch updateShape.
		self styleMarker: patch.
		side := marker extentWithSide: patch side.
		patch
			extent: side;
			position: width @ height - side / 2.
		swatch addChild: patch ].
	^ swatch
]

{ #category : 'accessing' }
BpLine >> points [

	^ points
]

{ #category : 'initialization' }
BpLine >> setX: aCollectionOfNumbers y: anotherCollectionOfNumbers [

	x := aCollectionOfNumbers asArray.
	y := anotherCollectionOfNumbers asArray.
	self refresh
]

{ #category : 'private - computing' }
BpLine >> styleMarker: aMarkerPatch [
	"Give aMarkerPatch my marker colors: unfilled markers ('x', '+') are drawn with the edge color only."

	aMarkerPatch background: (marker isFilled
		 ifTrue: [ self faceColor ]
		 ifFalse: [ Color transparent ]).
	marker isText ifTrue: [ aMarkerPatch paintText: self faceColor ].
	aMarkerPatch border: (marker isText
		 ifTrue: [ BlBorder empty ]
		 ifFalse: [ BlBorder paint: self edgeColor width: markerEdgeWidth * self class pixelsPerPoint ])
]
