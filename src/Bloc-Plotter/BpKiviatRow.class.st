"
I am one row of a `BpKiviat`: a value on each of its axes, shown by a polygon and, after `showMarkers: true`, by a dot on each value.

## Examples

```
BpKiviatRow instanceMaterial
```

## Design Rationale

- I do not know the scales: my kiviat turns my values into the points of my patches (`BpKiviat>>pointsFor:`), again at each rebuild because another row may change the limits.
- My outline and my dots have my color and my fill the same one made transparent by `alpha:` (0.25 by default), so that the rows below me stay visible. `fill: false` leaves my outline only.

## Usage

1. `BpKiviat>>addRow:` and `BpKiviat>>addRows:` create me and add me to the kiviat, which gives me the next color of its palette; see `BpArtist` for the rest of the life cycle.
2. `BpKiviat>>rebuild` sends me `place`.
"
Class {
	#name : 'BpKiviatRow',
	#superclass : 'BpArtist',
	#instVars : [
		'values',
		'color',
		'fill',
		'lineWidth',
		'showMarkers',
		'markerSize',
		'polygonPatch',
		'markerPatches'
	],
	#category : 'Bloc-Plotter-Kiviat',
	#package : 'Bloc-Plotter',
	#tag : 'Kiviat'
}

{ #category : 'instances' }
BpKiviatRow class >> instanceMaterial [
	"Answer a row of five values, with a dot on each one."

	<sampleInstance>
	^ self new
		  values: #( 1 5 2 2 3 );
		  showMarkers: true;
		  yourself
]

{ #category : 'accessing - style' }
BpKiviatRow >> color [

	^ color
]

{ #category : 'accessing - style' }
BpKiviatRow >> color: aColorOrNil [
	"Set the color of my outline, markers and fill; nil takes the one given by the palette of my kiviat. The fill is made transparent by alpha:."

	color := aColorOrNil.
	self refresh
]

{ #category : 'private - computing' }
BpKiviatRow >> compute [
	"Nothing to compute: the axes of my kiviat place my values (see place)."

	
]

{ #category : 'private - computing' }
BpKiviatRow >> dataPoints [
	"Answer my corners: the angle of each axis @ the fraction of the radius of my value on it. I have none while I am in no kiviat."

	^ chart ifNil: [ #(  ) ] ifNotNil: [ chart pointsFor: values ]
]

{ #category : 'accessing - style' }
BpKiviatRow >> fill [

	^ fill
]

{ #category : 'accessing - style' }
BpKiviatRow >> fill: aBoolean [
	"Set whether I am filled (the default) or only outlined."

	fill := aBoolean.
	self refresh
]

{ #category : 'initialization' }
BpKiviatRow >> initialize [

	super initialize.
	values := #(  ).
	alpha := 0.25.
	fill := true.
	lineWidth := 1.5.
	showMarkers := false.
	markerSize := 6.
	markerPatches := #(  )
]

{ #category : 'axes' }
BpKiviatRow >> isAboveGrid [

	^ true
]

{ #category : 'axes' }
BpKiviatRow >> legendEntries [

	label ifNil: [ ^ #(  ) ].
	^ { (label asString -> self newSwatch) }
]

{ #category : 'accessing - style' }
BpKiviatRow >> lineWidth [

	^ lineWidth
]

{ #category : 'accessing - style' }
BpKiviatRow >> lineWidth: aNumber [
	"Set the width of my outline in points (1.5 by default)."

	lineWidth := aNumber.
	self refresh
]

{ #category : 'inspector extensions' }
BpKiviatRow >> liveElement [
	"Answer the figure showing me. When I have no kiviat yet, I am added to the one of a new figure."

	| figure |
	chart ifNotNil: [ ^ chart liveElement ].
	figure := BpFigure rows: 1 columns: 1 chartClass: BpKiviat.
	figure charts first addKiviatRow: self.
	^ figure
]

{ #category : 'accessing' }
BpKiviatRow >> markerPatches [

	^ markerPatches
]

{ #category : 'accessing - style' }
BpKiviatRow >> markerSize [

	^ markerSize
]

{ #category : 'accessing - style' }
BpKiviatRow >> markerSize: aNumber [
	"Set the diameter of my dots in points (6 by default)."

	markerSize := aNumber.
	self refresh
]

{ #category : 'private - computing' }
BpKiviatRow >> newMarkerAt: aPoint index: anIndex [

	| patch |
	patch := BpMarkerPatch new
		         artist: self;
		         dataset: 1;
		         index: anIndex;
		         dataPoint: aPoint;
		         area: markerSize squared;
		         marker: (BpMarker on: 'o');
		         yourself.
	patch
		updateShape;
		background: self shownColor.
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'private - computing' }
BpKiviatRow >> newPatches [

	| points |
	points := self dataPoints.
	polygonPatch := self newPolygonThrough: points.
	markerPatches := showMarkers
		                 ifTrue: [ points withIndexCollect: [ :each :index | self newMarkerAt: each index: index ] ]
		                 ifFalse: [ #(  ) ].
	^ { polygonPatch } , markerPatches
]

{ #category : 'private - computing' }
BpKiviatRow >> newPolygonThrough: aCollectionOfPoints [

	| patch |
	patch := BpPolygonPatch new
		         artist: self;
		         dataset: 1;
		         dataVertices: aCollectionOfPoints;
		         yourself.
	self paint: patch.
	patchHandlers do: [ :each | self addHandler: each to: patch ].
	^ patch
]

{ #category : 'axes' }
BpKiviatRow >> newSwatch [

	| swatch |
	swatch := BlElement new
		          extent: 20 @ 10;
		          yourself.
	self paint: swatch.
	^ swatch
]

{ #category : 'private - style' }
BpKiviatRow >> paint: anElement [
	"Give anElement my outline and my fill."

	anElement
		background: (fill
			 ifTrue: [ self colorOf: self shownColor ]
			 ifFalse: [ Color transparent ]);
		border: (self strokeColor: self shownColor width: lineWidth style: #solid)
]

{ #category : 'axes' }
BpKiviatRow >> place [
	"Move my patches to where the axes of my kiviat now show my values."

	| points |
	points := self dataPoints.
	polygonPatch dataVertices: points.
	markerPatches withIndexDo: [ :each :index | each dataPoint: (points at: index) ]
]

{ #category : 'accessing' }
BpKiviatRow >> polygonPatch [

	^ polygonPatch
]

{ #category : 'accessing - style' }
BpKiviatRow >> showMarkers [

	^ showMarkers
]

{ #category : 'accessing - style' }
BpKiviatRow >> showMarkers: aBoolean [
	"Set whether a dot is shown on each of my values (false by default)."

	showMarkers := aBoolean.
	self refresh
]

{ #category : 'private - style' }
BpKiviatRow >> shownColor [

	^ color ifNil: [ defaultColors first ]
]

{ #category : 'accessing - data' }
BpKiviatRow >> values [

	^ values
]

{ #category : 'accessing - data' }
BpKiviatRow >> values: aCollectionOfNumbers [
	"Set my values, one per axis."

	chart ifNotNil: [ chart checkValues: aCollectionOfNumbers ].
	values := aCollectionOfNumbers asArray.
	self refresh
]
