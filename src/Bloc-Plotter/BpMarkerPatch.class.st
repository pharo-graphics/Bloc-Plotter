"
I am the marker of one point of a `BpScatterPlot` or a `BpLine`, of a flier or a mean of a `BpBoxPlot`, or of a head of a `BpStemPlot`. I know the `index` of my point, its `dataPoint`, my `area` (matplotlib s, in points squared) and my `amount` (the number of c mapped to my color, or nil). I take the shape of my `BpMarker` at my size, centered on my point. See `BpPatch` for the life cycle.

## Examples

```
BpMarkerPatch exampleCircle
```

## Implementation Notes

- The side of my unit cell is the square root of my area, in points, so that the area of a circle grows with s as in matplotlib.
- A text marker is shown by a `BlTextElement` child, centered by a `BlFrameLayout`.
"
Class {
	#name : 'BpMarkerPatch',
	#superclass : 'BpPatch',
	#instVars : [
		'marker',
		'dataPoint',
		'index',
		'area',
		'amount'
	],
	#category : 'Bloc-Plotter-Scatter',
	#package : 'Bloc-Plotter',
	#tag : 'Scatter'
}

{ #category : 'examples' }
BpMarkerPatch class >> exampleCircle [
	"Answer the marker of the third point of a scatter, a circle of 80 points squared."

	<sampleInstance>
	^ ((BpScatterPlot x: #( 1 2 3 ) y: #( 3 1 2 ))
		   s: 80;
		   yourself) patches third
]

{ #category : 'accessing' }
BpMarkerPatch >> amount [
	"Answer the number of my point mapped to my color (matplotlib c), or nil when my color was given."

	^ amount
]

{ #category : 'accessing' }
BpMarkerPatch >> amount: aNumberOrNil [

	amount := aNumberOrNil
]

{ #category : 'accessing' }
BpMarkerPatch >> area [
	"Answer my size in points squared (matplotlib s)."

	^ area
]

{ #category : 'accessing' }
BpMarkerPatch >> area: aNumber [

	area := aNumber
]

{ #category : 'accessing' }
BpMarkerPatch >> dataBounds [

	^ dataPoint corner: dataPoint
]

{ #category : 'accessing' }
BpMarkerPatch >> dataPoint [
	"Answer the point I show, in data coordinates."

	^ dataPoint
]

{ #category : 'accessing' }
BpMarkerPatch >> dataPoint: aPoint [

	dataPoint := aPoint
]

{ #category : 'accessing' }
BpMarkerPatch >> index [
	"Answer the index of my point in the data of my scatter."

	^ index
]

{ #category : 'accessing' }
BpMarkerPatch >> index: anInteger [

	index := anInteger
]

{ #category : 'accessing' }
BpMarkerPatch >> marker [

	^ marker
]

{ #category : 'accessing' }
BpMarkerPatch >> marker: aMarker [

	marker := aMarker
]

{ #category : 'drawing' }
BpMarkerPatch >> paintText: aColor [
	"Give the text of a text marker aColor."

	self childrenDo: [ :each | each text: (each text foreground: aColor) ]
]

{ #category : 'layout' }
BpMarkerPatch >> pixelBoundsWith: aTransform [
	"Center my marker on my point."

	^ (aTransform pointFor: dataPoint) + (marker offsetWithSide: self side) extent: (marker extentWithSide: self side)
]

{ #category : 'accessing' }
BpMarkerPatch >> side [
	"Answer the side of the unit cell of my marker in pixels: the square root of my area, in points."

	^ area sqrt * BpArtist pixelsPerPoint
]

{ #category : 'drawing' }
BpMarkerPatch >> updateShape [
	"Take the shape of my marker at my size; a text marker shows its text in my center."

	self geometry: (marker geometryWithSide: self side).
	self removeChildren.
	marker isText ifFalse: [ ^ self ].
	self layout: BlFrameLayout new.
	self addChild: (BlTextElement new
		 text: (marker text asRopedText fontSize: self side);
		 labelMeasurement;
		 constraintsDo: [ :c |
			 c frame horizontal alignCenter.
			 c frame vertical alignCenter ];
		 preventMouseEvents;
		 yourself)
]
