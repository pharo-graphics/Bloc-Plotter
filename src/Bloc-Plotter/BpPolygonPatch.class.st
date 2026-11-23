"
I am a polyline through my `dataVertices` when open, a filled polygon when closed: the outline of a step histogram (`BpHistogram>>histType:` #step or #stepfilled) the line of a `BpLine`, a box, whisker, cap, median or mean line of a `BpBoxPlot`, a stem or the baseline of a `BpStemPlot`, a region of a `BpFillBetween`, a layer of a `BpStackPlot`, or the outline of a `BpStairs`. See `BpPatch` for the life cycle.

## Examples

```
BpPolygonPatch exampleStep
```

## Implementation Notes

- My geometry gets its vertices in pixels, relative to my bounds, each time I am measured (`pixelBoundsWith:`).
- My geometry starts with one vertex because a `BlPolylineGeometry` without vertices fails to answer its bounds.
"
Class {
	#name : 'BpPolygonPatch',
	#superclass : 'BpPatch',
	#instVars : [
		'dataVertices',
		'closed'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'examples' }
BpPolygonPatch class >> exampleStep [
	"Answer the outline of a step histogram."

	<sampleInstance>
	^ (BpHistogram new
		   x: #( 1 2 2 3 );
		   bins: 3;
		   histType: #step;
		   yourself) patches first
]

{ #category : 'accessing' }
BpPolygonPatch >> closed: aBoolean [
	"A new BlPolylineGeometry without vertices fails to answer its bounds (see the Bloc backlog), so both geometries start with one vertex."

	closed := aBoolean.
	self geometry: (aBoolean
		 ifTrue: [ BlPolygonGeometry vertices: { (0 @ 0) } ]
		 ifFalse: [ BlPolylineGeometry vertices: { (0 @ 0) } ])
]

{ #category : 'accessing' }
BpPolygonPatch >> dataBounds [

	^ Rectangle encompassing: dataVertices
]

{ #category : 'accessing' }
BpPolygonPatch >> dataVertices [
	"Answer my points in data coordinates."

	^ dataVertices
]

{ #category : 'accessing' }
BpPolygonPatch >> dataVertices: aCollectionOfPoints [

	dataVertices := aCollectionOfPoints asArray
]

{ #category : 'initialization' }
BpPolygonPatch >> initialize [

	super initialize.
	dataVertices := #(  ).
	self closed: true
]

{ #category : 'accessing' }
BpPolygonPatch >> isClosed [

	^ closed
]

{ #category : 'layout' }
BpPolygonPatch >> pixelBoundsWith: aTransform [
	"Answer the bounds of my points in the plot area, and give my geometry these points relative to my bounds."

	| points box |
	points := dataVertices collect: [ :each | aTransform pointFor: each ].
	box := Rectangle encompassing: points.
	self geometry vertices: (points collect: [ :each | each - box origin ]).
	^ box
]
