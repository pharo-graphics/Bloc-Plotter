"
I am a stem plot, added by `BpChart>>stem:` and `BpChart>>stemLocations:heads:`. For each location I draw a vertical line (a stem) from a baseline to its head, and a marker on the head; a horizontal baseline joins the first and the last location. Three format strings style these parts: `lineFormat:` the stems, `markerFormat:` the markers and `baseFormat:` the baseline.

## Examples

```
BpStemPlot examplePlotType.
BpStemPlot exampleStemPlot.
BpStemPlot exampleInteraction
```

## Design Rationale

- My parts are `stemLines` (one open `BpPolygonPatch` of two vertices per stem), `markerLine` (one `BpMarkerPatch` per head) and `baseLine` (one `BpPolygonPatch`, nil when hidden). They are drawn in that order, above the grid, as lines.
- I take no color of the palette in turn (`colorCount` is 0): stems and markers are drawn in its first color and the baseline in its fourth, unless `lineColor:`, `markerColor:` or `baseColor:` gives another. Markers take the color of the stems by default.
- The formats are read by `BpLine class>>formatPartsOf:`, so they accept what `BpLine>>format:` accepts; a blank base format (' ') hides the baseline.
- `markerFaceColor:` sets the fill of the markers, the only part style the gallery changes; `Color transparent` gives hollow markers.

## Usage

1. `BpStemPlot class>>stem:` (heads only, located from 0) and `BpStemPlot class>>stemLocations:heads:` create me with my data (`locations:heads:`); `BpChart>>stem:` and `BpChart>>stemLocations:heads:` create me the same way and add me to the chart (see `BpArtist`), as `BpChart>>addArtist:` does for a stem plot created apart.
2. My chart reads `isAboveGrid` (true) and my `legendEntries`: a stem with its marker on a piece of baseline.

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
		'locations',
		'lineColor',
		'markerColor',
		'baseColor'
	],
	#category : 'Bloc-Plotter-Stem',
	#package : 'Bloc-Plotter',
	#tag : 'Stem'
}

{ #category : 'examples' }
BpStemPlot class >> exampleInteraction [
	"Interaction handlers on stems: hover a stem or a marker to paint it red, click a marker to see its location and head."

	<example>
	| figure chart stems |
	figure := BpFigure new.
	chart := BpChart new.
	stems := chart addArtist: self instanceStems.
	chart title: 'Click a marker'.
	stems
		whenPatch: BlMouseEnterEvent do: [ :event :patch |
			patch userData at: #border put: patch border.
			patch border: (BlBorder paint: (BpQualitativePalette set1 colorAt: 1) width: 3) ];
		whenPatch: BlMouseLeaveEvent do: [ :event :patch | patch userData at: #border ifPresent: [ :border | patch border: border ] ];
		whenPatch: BlClickEvent do: [ :event :patch |
			(stems markerLine includes: patch) ifTrue: [
				chart title: ('stem {1}: head {2}' format: {
					 (stems locations at: patch index).
					 ((stems heads at: patch index) printShowingDecimalPlaces: 2) }) ] ].
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Stem interaction'
]

{ #category : 'examples' }
BpStemPlot class >> examplePlotType [
	"Reproduce the plot type stem(x, y)."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: self instancePlotType.
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7);
		grid: true.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'stem(x, y)'
]

{ #category : 'examples' }
BpStemPlot class >> exampleStemPlot [
	"Reproduce the two figures of the gallery 'Stem plot' side by side: default stems, then grey stems with hollow diamonds on a baseline at 1.1."

	<example>
	| figure plain styled |
	figure := BpFigure rows: 1 columns: 2.
	plain := BpChart new.
	plain addArtist: self instanceExpSine.
	styled := BpChart new.
	styled addArtist: self instanceExpSineStyled.
	figure
		chartAtRow: 1 column: 1 put: plain;
		chartAtRow: 1 column: 2 put: styled.
	^ figure show: 'stem_plot'
]

{ #category : 'instances' }
BpStemPlot class >> instanceExpSine [
	"Gallery: Stem plot (stem_plot), first figure: exp(sin(x)) at 41 locations between 0.1 and 2 pi."

	<sampleInstance>
	^ self stemLocations: self stemPlotLocations heads: (self stemPlotLocations collect: [ :each | each sin exp ])
]

{ #category : 'instances' }
BpStemPlot class >> instanceExpSineStyled [
	"Gallery: Stem plot (stem_plot), second figure: grey stems, white diamonds and the baseline at 1.1."

	<sampleInstance>
	| greys |
	greys := BpSequentialPalette greys: 9.
	^ self instanceExpSine
		  lineColor: (greys colorAt: 6);
		  markerFormat: 'D';
		  bottom: 1.1;
		  markerFaceColor: (greys colorAt: 1);
		  yourself
]

{ #category : 'instances' }
BpStemPlot class >> instancePlotType [
	"Plot types: stem(x, y), eight stems."

	<sampleInstance>
	^ self stemLocations: ((0 to: 7) collect: [ :each | each + 0.5 ]) heads: #( 4.8 5.5 3.5 4.6 6.5 6.6 2.6 3.0 )
]

{ #category : 'instances' }
BpStemPlot class >> instanceStems [
	"Answer five stems going up and down from the baseline, located from 0."

	<sampleInstance>
	^ self stem: #( 3 -1 4 -1 5 )
]

{ #category : 'instance creation' }
BpStemPlot class >> stem: aCollection [
	"Answer a stem plot of the heads aCollection, located at 0, 1, 2, ..., to be configured with lineFormat:, markerFormat:, baseFormat:, bottom:, orientation:, ... (see `BpStemPlot`)."

	^ self new
		  heads: aCollection;
		  yourself
]

{ #category : 'instance creation' }
BpStemPlot class >> stemLocations: aCollection heads: anotherCollection [
	"Answer a stem plot of the heads anotherCollection at the locations aCollection (see `stem:`)."

	^ self new
		  locations: aCollection heads: anotherCollection;
		  yourself
]

{ #category : 'private - demo' }
BpStemPlot class >> stemPlotLocations [
	"Answer the 41 locations of the gallery stem plot, from 0.1 to 2 pi."

	^ self linspaceFrom: 0.1 to: 2 * Float pi count: 41
]

{ #category : 'accessing - style' }
BpStemPlot >> baseColor: aColor [
	"Set the color of the baseline, the fourth color of my palette by default."

	baseColor := aColor.
	self refresh
]

{ #category : 'accessing - options' }
BpStemPlot >> baseFormat [

	^ baseFormat
]

{ #category : 'accessing - options' }
BpStemPlot >> baseFormat: aString [
	"Set the line style of the baseline with a format string ('-' by default, see `BpLine>>format:`); a blank string hides it."

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
	"Answer 0: my default colors are fixed colors of the palette (the first and the fourth), not the next ones."

	^ 0
]

{ #category : 'private - computing' }
BpStemPlot >> compute [
	"Check my formats, so that a wrong one fails when it is set."

	BpLine formatPartsOf: lineFormat.
	BpLine formatPartsOf: markerFormat.
	self isBaseLineHidden ifFalse: [ BpLine formatPartsOf: baseFormat ]
]

{ #category : 'private - style' }
BpStemPlot >> headColor [

	^ markerColor ifNil: [ self stemColor ] ifNotNil: [ self colorOf: markerColor ]
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
	lineFormat := '-'.
	markerFormat := 'o'.
	baseFormat := '-'.
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

{ #category : 'accessing - style' }
BpStemPlot >> lineColor: aColor [
	"Set the color of the stems, the first color of my palette by default. The markers take it too, unless they have their own."

	lineColor := aColor.
	self refresh
]

{ #category : 'accessing - options' }
BpStemPlot >> lineFormat [

	^ lineFormat
]

{ #category : 'accessing - options' }
BpStemPlot >> lineFormat: aString [
	"Set the line style of the stems with a format string ('-' by default, see `BpLine>>format:`)."

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

{ #category : 'accessing - style' }
BpStemPlot >> markerColor: aColor [
	"Set the color of the markers, the color of the stems by default."

	markerColor := aColor.
	self refresh
]

{ #category : 'accessing - style' }
BpStemPlot >> markerFaceColor [

	^ markerFaceColor
]

{ #category : 'accessing - style' }
BpStemPlot >> markerFaceColor: aColor [
	"Set the fill color of the markers; `Color transparent` gives hollow markers."

	markerFaceColor := aColor.
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

	^ BpMarker on: ((BpLine formatPartsOf: markerFormat) at: #marker ifAbsent: [ 'o' ])
]

{ #category : 'private - computing' }
BpStemPlot >> newBaseLine [
	"Answer my baseline from my first to my last location, or nil when hidden or empty."

	| allLocations |
	allLocations := self locations.
	(allLocations isEmpty or: [ self isBaseLineHidden ]) ifTrue: [ ^ nil ].
	^ self
		  newLineThrough: {
			  (allLocations min @ bottom).
			  (allLocations max @ bottom) }
		  color: (self colorOf: (baseColor ifNil: [ self paletteColorAt: 4 ]))
		  style: ((BpLine formatPartsOf: baseFormat) at: #lineStyle ifAbsent: [ #solid ])
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
	headColor := self headColor.
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
	self style: marker color: self headColor.
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
BpStemPlot >> stemColor [

	^ self colorOf: (lineColor ifNil: [ self paletteColorAt: 1 ])
]

{ #category : 'accessing - results' }
BpStemPlot >> stemLines [
	"Answer my stems, one line patch per head."

	^ stemLines
]

{ #category : 'private - style' }
BpStemPlot >> stemStyle [

	^ (BpLine formatPartsOf: lineFormat) at: #lineStyle ifAbsent: [ #solid ]
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
