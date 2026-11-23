"
I am one line of the grid of a `BpPolarChart`: from the center to the edge at the location of an angle, a circle at the location of a radius. See `BpGridLine` for the life cycle.

## Examples

```
BpPolarGridLine instanceCircle
```

## Usage

`BpPolarChart>>newGridLineFor:` and `BpKiviat>>newGridLines` create me.

## Implementation Notes

- My geometry gets the ends of the line of an angle, relative to my bounds, each time these are asked (`boundsWith:in:`).
"
Class {
	#name : 'BpPolarGridLine',
	#superclass : 'BpGridLine',
	#category : 'Bloc-Plotter-Polar',
	#package : 'Bloc-Plotter',
	#tag : 'Polar'
}

{ #category : 'instances' }
BpPolarGridLine class >> instanceCircle [
	"Answer the circle of the radius 0.5."

	<sampleInstance>
	^ self axis: #y location: 0.5
]

{ #category : 'accessing' }
BpPolarGridLine >> boundsWith: aTransform in: anExtent [
	"Answer my bounds in a plot area of anExtent: from its center to its edge for an angle, the square around my circle for a radius."

	| radius |
	axis = #x ifTrue: [ ^ self spokeBoundsWith: aTransform ].
	radius := aTransform radiusFor: location.
	^ aTransform center - radius asPoint extent: radius asPoint * 2
]

{ #category : 'accessing' }
BpPolarGridLine >> setAxis: anAxis location: aNumber [

	super setAxis: anAxis location: aNumber.
	self
		border: (BlBorder paint: self background paint width: 0.8 * BpArtist pixelsPerPoint);
		background: Color transparent;
		geometry: (axis = #x
			 ifTrue: [ BlPolylineGeometry vertices: { (0 @ 0) } ]
			 ifFalse: [ BlCircleGeometry new ])
]

{ #category : 'accessing' }
BpPolarGridLine >> spokeBoundsWith: aTransform [
	"Answer the bounds of the line of my angle, and give my geometry its ends."

	| center end box |
	center := aTransform center.
	end := center + ((aTransform directionFor: location) * aTransform outerRadius).
	box := Rectangle encompassing: {
		       center.
		       end }.
	self geometry vertices: {
		(center - box origin).
		(end - box origin) }.
	^ box
]
