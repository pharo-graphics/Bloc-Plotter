"
I am a stem plot, added by `BpAxes>>stem:` and `BpAxes>>stemLocations:heads:`. For each location I draw a vertical line (a stem) from a baseline to its head, and a marker on the head; a horizontal baseline joins the first and the last location. Three format strings style these parts: `lineFormat:` the stems, `markerFormat:` the markers and `baseFormat:` the baseline.

## Examples

```
BpStemPlot examplePlotType.
BpStemPlot exampleStemPlot.
BpStemPlot exampleInteraction
```

## Design Rationale

- My parts are `stemLines` (one open `BpPolygonPatch` of two vertices per stem), `markerLine` (one `BpMarkerPatch` per head) and `baseLine` (one `BpPolygonPatch`, nil when hidden). They are drawn in that order, above the grid, as lines.
- I take no color of the color cycle (`colorCount` is 0): stems and markers are 'C0' and the baseline 'C3' unless a format string gives another color, and markers take the color of the stems by default.
- The formats are read by `BpLine class>>formatPartsOf:`, so they accept what `BpLine>>format:` accepts, plus a whole color name ('grey') for any of them; a blank base format (' ') hides the baseline.
- `markerFaceColor:` sets the fill of the markers, the only part style the gallery changes; 'none' gives hollow markers.

## Usage

1. `BpAxes>>stem:` (heads only, located from 0) and `BpAxes>>stemLocations:heads:` create me with my data (`locations:heads:`) and add me to the axes (see `BpArtist`).
2. My axes read `isAboveGrid` (true) and my `legendEntries`: a stem with its marker on a piece of baseline.

## Implementation Notes

- The line style of the marker format is ignored: I never join the markers with a line, even with a format such as 'o-'.
- A marker in the line or base format is ignored.
- I have one slot and setter per option, hence many slots.

## Invariants and Assumptions

- `locations` and `heads` have the same size; `locations:heads:` changes both at once.
"
Class {
	#name : 'BpStemPlot',
	#superclass : 'BpArtist',
	#instVars : [
		'heads',
		'lineFormat',
		'markerFormat',
		'baseFormat',
		'bottom',
		'orientation',
		'markerFaceColor',
		'stemLines',
		'markerLine',
		'baseLine',
		'locations'
	],
	#category : 'Bloc-Plotter-Stem',
	#package : 'Bloc-Plotter',
	#tag : 'Stem'
}

{ #category : 'examples' }
BpStemPlot class >> exampleInteraction [
	"Interaction handlers on stems: hover a stem or a marker to paint it red, click a marker to see its location and head."

	<example>
	^ BpFigure instanceInteractiveStems show: 'Stem interaction'
]

{ #category : 'examples' }
BpStemPlot class >> examplePlotType [
	"Reproduce the plot type stem(x, y)."

	<example>
	^ BpFigure instanceStemPlotType show: 'stem(x, y)'
]

{ #category : 'examples' }
BpStemPlot class >> exampleStemPlot [
	"Reproduce the two figures of the gallery 'Stem plot': default stems, then grey stems with hollow diamonds on a baseline at 1.1."

	<example>
	BpFigure instanceStemPlot show: 'stem_plot'.
	^ BpFigure instanceStemPlotStyled show: 'stem_plot styled'
]

{ #category : 'instances' }
BpStemPlot class >> instanceStems [
	"Answer five stems going up and down from the baseline, in new axes."

	<sampleInstance>
	^ (BpAxes new
		   extent: 400 @ 300;
		   yourself) stem: #( 3 -1 4 -1 5 )
]

{ #category : 'private - demo' }
BpStemPlot class >> stemPlotLocations [
	"Answer the 41 locations of the gallery stem plot, from 0.1 to 2 pi."

	^ self linspaceFrom: 0.1 to: 2 * Float pi count: 41
]

{ #category : 'accessing - options' }
BpStemPlot >> baseFormat [

	^ baseFormat
]

{ #category : 'accessing - options' }
BpStemPlot >> baseFormat: aString [
	"Set the color and line style of the baseline with a format string ('C3-' by default, see `BpLine>>format:`); a blank string hides it."

	baseFormat := aString.
	self refresh
]

{ #category : 'accessing - results' }
BpStemPlot >> baseLine [
	"Answer my baseline patch, nil when hidden."

	^ baseLine
]

{ #category : 'accessing - options' }
BpStemPlot >> bottom [

	^ bottom
]

{ #category : 'accessing - options' }
BpStemPlot >> bottom: aNumber [
	"Set the value where the stems start and the baseline lies (0 by default)."

	bottom := aNumber.
	self refresh
]

{ #category : 'axes' }
BpStemPlot >> colorCount [
	"Answer 0: my default colors are fixed ('C0' and 'C3'), not taken from the color cycle."

	^ 0
]

{ #category : 'private - computing' }
BpStemPlot >> compute [
	"Check my formats, so that a wrong one fails when it is set."

	self partsOf: lineFormat.
	self partsOf: markerFormat.
	self isBaseLineHidden ifFalse: [ self partsOf: baseFormat ]
]

{ #category : 'accessing - data' }
BpStemPlot >> heads [

	^ heads
]

{ #category : 'accessing - data' }
BpStemPlot >> heads: aCollection [
	"Set the heads of the stems, located at 0, 1, 2, ..."

	self locations: nil heads: aCollection
]

{ #category : 'initialization' }
BpStemPlot >> initialize [

	super initialize.
	lineFormat := 'C0-'.
	markerFormat := 'o'.
	baseFormat := 'C3-'.
	bottom := 0.
	orientation := #vertical.
	stemLines := #(  ).
	markerLine := #(  )
]

{ #category : 'axes' }
BpStemPlot >> isAboveGrid [

	^ true
]

{ #category : 'private - style' }
BpStemPlot >> isBaseLineHidden [

	^ baseFormat isAllSeparators
]

{ #category : 'accessing - options' }
BpStemPlot >> isHorizontal [

	^ orientation = #horizontal
]

{ #category : 'axes' }
BpStemPlot >> legendEntries [
	"Answer my label with a stem and its marker on a piece of baseline."

	(label isNil or: [ markerLine isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> self newSwatch) }
]

{ #category : 'accessing - options' }
BpStemPlot >> lineFormat [

	^ lineFormat
]

{ #category : 'accessing - options' }
BpStemPlot >> lineFormat: aString [
	"Set the color and line style of the stems with a format string ('C0-' by default, see `BpLine>>format:`) or a color name. The markers take this color unless the marker format gives one."

	lineFormat := aString.
	self refresh
]

{ #category : 'accessing - data' }
BpStemPlot >> locations [
	"Answer the locations of my stems: as given, or 0, 1, 2, ... when only the heads were given."

	heads ifNil: [ ^ #(  ) ].
	^ locations ifNil: [ (0 to: heads size - 1) asArray ]
]

{ #category : 'accessing - data' }
BpStemPlot >> locations: aCollectionOrNil heads: anotherCollection [
	"Set the locations of the stems and their heads at once. Without locations (nil), the stems are located at 0, 1, 2, ..."

	(aCollectionOrNil isNotNil and: [ aCollectionOrNil size ~= anotherCollection size ]) ifTrue: [
		^ self error: ('locations and heads have different sizes: {1} and {2}' format: {
			   aCollectionOrNil size.
			   anotherCollection size }) ].
	locations := aCollectionOrNil ifNotNil: [ aCollectionOrNil asArray ].
	heads := anotherCollection asArray.
	self refresh
]

{ #category : 'private - style' }
BpStemPlot >> markerColor [
	"Answer the color of the marker format, else the color of the stems."

	^ (self partsOf: markerFormat) at: #color ifPresent: [ :each | self paintOf: each ] ifAbsent: [ self stemColor ]
]

{ #category : 'accessing - style' }
BpStemPlot >> markerFaceColor [

	^ markerFaceColor
]

{ #category : 'accessing - style' }
BpStemPlot >> markerFaceColor: aColorOrName [
	"Set the fill color of the markers; 'none' gives hollow markers."

	markerFaceColor := aColorOrName.
	self refresh
]

{ #category : 'accessing - options' }
BpStemPlot >> markerFormat [

	^ markerFormat
]

{ #category : 'accessing - options' }
BpStemPlot >> markerFormat: aString [
	"Set the marker and its color with a format string ('o' by default, see `BpLine>>format:`)."

	markerFormat := aString.
	self refresh
]

{ #category : 'accessing - results' }
BpStemPlot >> markerLine [
	"Answer my markers, one patch per head."

	^ markerLine
]

{ #category : 'private - style' }
BpStemPlot >> markerShape [

	^ BpMarker on: ((self partsOf: markerFormat) at: #marker ifAbsent: [ 'o' ])
]

{ #category : 'private - computing' }
BpStemPlot >> newBaseLine [
	"Answer my baseline from my first to my last location, or nil when hidden or empty."

	| parts allLocations |
	allLocations := self locations.
	(allLocations isEmpty or: [ self isBaseLineHidden ]) ifTrue: [ ^ nil ].
	parts := self partsOf: baseFormat.
	^ self
		  newLineThrough: {
			  (allLocations min @ bottom).
			  (allLocations max @ bottom) }
		  color: (self paintOf: (parts at: #color ifAbsent: [ 'C3' ]))
		  style: (parts at: #lineStyle ifAbsent: [ #solid ])
]

{ #category : 'private - computing' }
BpStemPlot >> newLineThrough: somePoints color: aColor style: aLineStyle [
	"Answer an open line patch through somePoints, given as (location @ value)."

	| patch |
	patch := BpPolygonPatch new
		         artist: self;
		         closed: false;
		         dataVertices: (somePoints collect: [ :each | self oriented: each ]);
		         yourself.
	patch
		background: Color transparent;
		border: (self strokeColor: aColor width: BpLine defaultLineWidth style: aLineStyle).
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'private - computing' }
BpStemPlot >> newMarkerAt: aPoint index: anIndex marker: aMarker color: aColor [
	"Answer the marker patch of the head anIndex, at aPoint given as (location @ value)."

	| patch |
	patch := BpMarkerPatch new
		         artist: self;
		         index: anIndex;
		         dataPoint: (self oriented: aPoint);
		         area: BpLine defaultMarkerSize squared;
		         marker: aMarker;
		         yourself.
	patch updateShape.
	self style: patch color: aColor.
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'private - computing' }
BpStemPlot >> newPatches [
	"Answer my stems, then my markers, then my baseline, in drawing order."

	| allLocations color style marker headColor |
	allLocations := self locations.
	color := self stemColor.
	style := self stemStyle.
	marker := self markerShape.
	headColor := self markerColor.
	stemLines := allLocations with: (heads ifNil: [ #(  ) ]) collect: [ :location :head |
		             self
			             newLineThrough: {
				             (location @ bottom).
				             (location @ head) }
			             color: color
			             style: style ].
	markerLine := allLocations withIndexCollect: [ :location :index |
		              self
			              newMarkerAt: location @ (heads at: index)
			              index: index
			              marker: marker
			              color: headColor ].
	baseLine := self newBaseLine.
	^ stemLines , markerLine , (baseLine ifNil: [ #(  ) ] ifNotNil: [ { baseLine } ])
]

{ #category : 'axes' }
BpStemPlot >> newSwatch [

	| width height swatch marker side |
	width := 28.
	height := 14.
	swatch := BlElement new
		          extent: width @ height;
		          yourself.
	baseLine ifNotNil: [ swatch addChild: (self newSwatchLineFrom: 0 @ height to: width @ height border: baseLine border) ].
	swatch addChild: (self newSwatchLineFrom: width / 2 @ height to: width / 2 @ (height / 2) border: stemLines first border).
	marker := BpMarkerPatch new
		          index: 1;
		          area: BpLine defaultMarkerSize squared;
		          marker: self markerShape;
		          yourself.
	marker updateShape.
	self style: marker color: self markerColor.
	side := marker marker extentWithSide: marker side.
	marker
		extent: side;
		position: width / 2 @ (height / 2) - (side / 2).
	swatch addChild: marker.
	^ swatch
]

{ #category : 'axes' }
BpStemPlot >> newSwatchLineFrom: aPoint to: anotherPoint border: aBorder [

	^ BlElement new
		  geometry: (BlLineGeometry from: aPoint to: anotherPoint);
		  border: aBorder;
		  extent: (aPoint max: anotherPoint);
		  yourself
]

{ #category : 'accessing - options' }
BpStemPlot >> orientation [

	^ orientation
]

{ #category : 'accessing - options' }
BpStemPlot >> orientation: aSymbol [
	"Set #vertical stems (the default) or #horizontal ones, going right from the baseline."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - computing' }
BpStemPlot >> oriented: aPoint [
	"Answer aPoint, given as (location @ value), in data coordinates: swapped for horizontal stems."

	^ self isHorizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'private - style' }
BpStemPlot >> partsOf: aString [
	"Answer the parts (#color, #lineStyle, #marker) of a format string, a whole color name giving only the color."

	(self isColorName: aString) ifTrue: [
		^ Dictionary new
			  at: #color put: aString;
			  yourself ].
	^ BpLine formatPartsOf: aString
]

{ #category : 'private - style' }
BpStemPlot >> stemColor [

	^ self paintOf: ((self partsOf: lineFormat) at: #color ifAbsent: [ 'C0' ])
]

{ #category : 'accessing - results' }
BpStemPlot >> stemLines [
	"Answer my stems, one line patch per head."

	^ stemLines
]

{ #category : 'private - style' }
BpStemPlot >> stemStyle [

	^ (self partsOf: lineFormat) at: #lineStyle ifAbsent: [ #solid ]
]

{ #category : 'private - style' }
BpStemPlot >> style: aMarkerPatch color: aColor [
	"Give aMarkerPatch the colors of my markers: filled with my marker face color or aColor, outlined with aColor; unfilled markers ('x', '+') are only outlined."

	| marker |
	marker := aMarkerPatch marker.
	aMarkerPatch background: (marker isFilled
		 ifTrue: [ markerFaceColor ifNil: [ aColor ] ifNotNil: [ self paintOf: markerFaceColor ] ]
		 ifFalse: [ Color transparent ]).
	marker isText ifTrue: [ aMarkerPatch paintText: aColor ].
	aMarkerPatch border: (marker isText
		 ifTrue: [ BlBorder empty ]
		 ifFalse: [ BlBorder paint: aColor width: BpLine defaultMarkerEdgeWidth * self class pixelsPerPoint ])
]
