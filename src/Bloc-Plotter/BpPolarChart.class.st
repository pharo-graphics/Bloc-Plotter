"
I am a chart in polar coordinates: the x of the data is an angle in radians, its y a radius. My plot area is a disk, with the angles labeled in degrees around it and the radii on its circles. Every artist of a `BpChart` can be added to me: the bars of `barX:height:` and of a `BpHistogram` become sectors, the lines, points and filled areas follow the angles.

## Examples

```
BpPolarChart examplePolarBar.
BpPolarChart exampleWindRose.
BpPolarChart examplePolarArtists
```

## Design Rationale

- I am a `BpChart` with another transform (`BpPolarTransform`), other ticks (`BpPolarTick`) and other grid lines (`BpPolarGridLine`), so the artists do not know whether they are in a polar chart.
- The radii start at 0, or at the lowest value when it is negative: an area around the center would be misread otherwise.
- `startAngle:` and `counterClock:` mean the same as for a `BpPie`.
- My grid is shown by default, because without it nothing shows the angles.
- My legend is my child and not the one of my plot area, whose disk would clip it.

## Usage

1. `BpFigure>>rows:columns:chartClass:` creates me; I can also be shown alone.
2. I am used as a `BpChart`. `startAngle:`, `counterClock:` and `radialLabelAngle:` say where the angle 0 is, in which direction the angles grow, and along which direction the radii are labeled.
3. `BpChartLayout` asks me `computePlotBoundsIn:`: I take the largest disk that leaves room for the labels of the angles and for my title.

## Implementation Notes

- A line joins its points with straight segments: give it enough points to follow a circle.
- Categories are placed at the angles 0, 1, 2, ... radians, as on the x axis of a `BpChart`: give angles instead, and label them with `xTickFormatter:`.

## Invariants and Assumptions

- My plot area is square.
"
Class {
	#name : 'BpPolarChart',
	#superclass : 'BpChart',
	#instVars : [
		'radialLabelAngle',
		'legendElement'
	],
	#category : 'Bloc-Plotter-Polar',
	#package : 'Bloc-Plotter',
	#tag : 'Polar'
}

{ #category : 'examples' }
BpPolarChart class >> examplePolarArtists [
	"Show other artists in polar charts: a line, points, a histogram and a filled curve."

	<example>
	^ BpFigure instancePolarArtists show: 'Polar artists'
]

{ #category : 'examples' }
BpPolarChart class >> examplePolarBar [
	"Reproduce the gallery 'Bar chart on polar axis' (see `BpFigure class>>instancePolarBar`)."

	<example>
	^ BpFigure instancePolarBar show: 'polar_bar'
]

{ #category : 'examples' }
BpPolarChart class >> exampleWindRose [
	"Show bars in a chart turning as a compass."

	<example>
	| figure |
	figure := BpFigure rows: 1 columns: 1 chartClass: self.
	self showWindRoseIn: figure charts first.
	^ figure show: 'Wind rose'
]

{ #category : 'instances' }
BpPolarChart class >> instanceBars [
	"Answer a polar chart of four bars of the same width, one per quarter turn."

	<sampleInstance>
	| chart |
	chart := self new
		         extent: 400 @ 400;
		         yourself.
	(chart barXValues: ((0 to: 3) collect: [ :each | each * Float halfPi ]) heightValues: #( 4 7 5 9 )) width: Float halfPi * 0.8.
	^ chart
]

{ #category : 'instances' }
BpPolarChart class >> instanceWindRose [
	"Answer a polar chart turning as a compass: the angle 0 is at the top, the angles go clockwise and are labeled with the wind directions."

	<sampleInstance>
	| chart |
	chart := self new
		         extent: 400 @ 400;
		         yourself.
	self showWindRoseIn: chart.
	^ chart
]

{ #category : 'private - demo' }
BpPolarChart class >> showHistogramIn: aPolarChart random: aRandom [

	(aPolarChart addArtist: (BpHistogram xValues: ((1 to: 300) collect: [ :each | Float pi + aRandom nextNormal ])))
		bins: ((0 to: 16) collect: [ :each | each * Float pi / 8 ]);
		edgeColor: ((BpSequentialPalette greys: 9) colorAt: 1).
	aPolarChart title: 'BpHistogram'
]

{ #category : 'private - demo' }
BpPolarChart class >> showPointsIn: aPolarChart random: aRandom [

	(aPolarChart addArtist: (BpScatterPlot
		  x: ((1 to: 80) collect: [ :each | Float twoPi * aRandom next ])
		  y: ((1 to: 80) collect: [ :each | 2 * aRandom next ])))
		s: 40;
		alpha: 0.7.
	aPolarChart title: 'BpScatterPlot'
]

{ #category : 'private - demo' }
BpPolarChart class >> showWindRoseIn: aPolarChart [
	"Show bars labeled with the wind directions in aPolarChart, turning as a compass."

	| directions |
	directions := #( 'N' 'NE' 'E' 'SE' 'S' 'SW' 'W' 'NW' ).
	(aPolarChart barXValues: ((0 to: 7) collect: [ :each | each * Float pi / 4 ]) heightValues: #( 5 3 2 4 8 12 9 6 ))
		width: Float pi / 5;
		alpha: 0.7.
	aPolarChart
		startAngle: 90;
		counterClock: false;
		xTickFormatter: [ :each | directions at: (each * 4 / Float pi) rounded + 1 ];
		title: 'Wind directions'
]

{ #category : 'layout' }
BpPolarChart >> angleTicks [

	^ ticks select: [ :each | each axis = #x ]
]

{ #category : 'private - building' }
BpPolarChart >> autoScale: anAxis [
	"Answer a full turn for the angles. For the radii, start at 0, or at the lowest value when it is negative, and leave a margin at the edge."

	| values low high |
	anAxis = #x ifTrue: [
		^ {
			  0.
			  Float twoPi } ].
	(self scaleOf: anAxis) = #log ifTrue: [ ^ super autoScale: anAxis ].
	values := self dataValuesOn: anAxis.
	values ifEmpty: [ ^ #( 0 1 ) ].
	low := 0 min: values min.
	high := values max.
	high > low ifFalse: [ high := low + 1 ].
	^ {
		  low.
		  (self limitsFrom: low to: high on: anAxis) last }
]

{ #category : 'layout' }
BpPolarChart >> computePlotBoundsIn: anExtent [
	"Compute the largest square whose circle leaves room for the labels of the angles around it, for my title at the top and for my color bars on the right. My labels, title and color bars must be measured."

	| top area radius |
	top := self title isEmpty
		       ifTrue: [ 6 ]
		       ifFalse: [ titleElement measuredExtent y + 10 ].
	area := 6 @ top corner: anExtent - 6 - (self colorBarsWidth @ 0).
	radius := self angleTicks
		          inject: (area width min: area height) / 2
		          into: [ :min :each | min min: (each maxRadiusIn: area extent with: transform) ].
	radius := radius max: 1.
	self plotBounds: (area center - radius asPoint extent: radius asPoint * 2)
]

{ #category : 'accessing' }
BpPolarChart >> counterClock [

	^ transform counterClock
]

{ #category : 'accessing' }
BpPolarChart >> counterClock: aBoolean [
	"Set whether the angles grow counterclockwise (the default)."

	transform counterClock: aBoolean.
	self rebuild
]

{ #category : 'private - building' }
BpPolarChart >> defaultLabelsFor: aCollectionOfLocations on: anAxis [
	"Label the angles in degrees."

	anAxis = #x ifFalse: [ ^ super defaultLabelsFor: aCollectionOfLocations on: anAxis ].
	^ (BpTickLocator labelsFor: (aCollectionOfLocations collect: [ :each | each radiansToDegrees ])) collect: [ :each | each , '°' ]
]

{ #category : 'initialization' }
BpPolarChart >> initialize [

	super initialize.
	plotArea geometry: BlCircleGeometry new
]

{ #category : 'initialization' }
BpPolarChart >> initializeSettings [

	super initializeSettings.
	radialLabelAngle := 22.5.
	showGrid := true.
	yTickCount := 5
]

{ #category : 'layout' }
BpPolarChart >> layoutLegendContext: aBlElementBoundsUpdater [
	"Place my legend in my upper right corner."

	legendElement ifNotNil: [ :legend |
		legend
			applyLayoutIn: (self measuredExtent x - legend measuredExtent x - 6 @ 6 extent: legend measuredExtent)
			context: aBlElementBoundsUpdater ]
]

{ #category : 'accessing' }
BpPolarChart >> legendElement [

	^ legendElement
]

{ #category : 'private - building' }
BpPolarChart >> newGridLineFor: aTick [

	^ BpPolarGridLine axis: aTick axis location: aTick location
]

{ #category : 'private - building' }
BpPolarChart >> newTickOn: anAxis location: aNumber text: aString [

	^ BpPolarTick axis: anAxis location: aNumber text: aString
]

{ #category : 'private - building' }
BpPolarChart >> newTransform [

	^ BpPolarTransform new
]

{ #category : 'accessing' }
BpPolarChart >> radialLabelAngle [

	^ radialLabelAngle
]

{ #category : 'accessing' }
BpPolarChart >> radialLabelAngle: aNumber [
	"Set the direction along which the radii are labeled, in degrees, counterclockwise from the right (22.5 by default)."

	radialLabelAngle := aNumber.
	self rebuild
]

{ #category : 'private - building' }
BpPolarChart >> showLegend: aLegendOrNil [
	"Show aLegendOrNil instead of my current legend, outside my round plot area, which would clip it."

	legendElement ifNotNil: [ :legend | self removeChild: legend ].
	legendElement := aLegendOrNil.
	aLegendOrNil ifNotNil: [ :legend | self addChild: legend ]
]

{ #category : 'accessing' }
BpPolarChart >> startAngle [

	^ transform startAngle
]

{ #category : 'accessing' }
BpPolarChart >> startAngle: aNumber [
	"Set where the angle 0 is, in degrees, counterclockwise from the right: 90 puts it at the top."

	transform startAngle: aNumber.
	self rebuild
]

{ #category : 'private - building' }
BpPolarChart >> tickLocationsOn: anAxis [
	"Put a tick every 45 degrees, and no tick at the center."

	| lowest |
	anAxis = #x ifTrue: [ ^ xTicks ifNil: [ (0 to: 7) collect: [ :each | each * Float pi / 4 ] ] ].
	yTicks ifNotNil: [ ^ yTicks ].
	lowest := (self limitsOn: anAxis) first.
	^ (super tickLocationsOn: anAxis) select: [ :each | each > lowest ]
]

{ #category : 'layout' }
BpPolarChart >> titleBottom [
	"Answer the y below my title, above the labels of the angles."

	^ plotBounds top - 10 - (self angleTicks inject: 0 into: [ :max :each | max max: each label measuredExtent y ])
]
