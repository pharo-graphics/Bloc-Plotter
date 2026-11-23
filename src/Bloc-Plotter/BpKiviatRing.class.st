"
I am a ring of a polygonal `BpKiviat`: a polygon with a corner on each axis, all at the same fraction of the radius. See `BpGridLine` for the life cycle.

## Examples

```
BpKiviatRing instanceSquare
```

## Usage

`BpKiviat>>newRingAt:` creates me; a circular kiviat uses `BpPolarGridLine`.

## Implementation Notes

- My geometry gets its corners, relative to my bounds, each time these are asked (`boundsWith:in:`). It starts with one corner because a polygon without vertices fails to answer its bounds.
"
Class {
	#name : 'BpKiviatRing',
	#superclass : 'BpPolarGridLine',
	#instVars : [
		'angles'
	],
	#category : 'Bloc-Plotter-Kiviat',
	#package : 'Bloc-Plotter',
	#tag : 'Kiviat'
}

{ #category : 'instances' }
BpKiviatRing class >> instanceSquare [
	"Answer the ring of four axes at half of the radius: a square."

	<sampleInstance>
	^ self location: 0.5 angles: ((0 to: 3) collect: [ :each | each * Float halfPi ])
]

{ #category : 'instance creation' }
BpKiviatRing class >> location: aFraction angles: aCollectionOfAngles [

	^ self new
		  location: aFraction angles: aCollectionOfAngles;
		  yourself
]

{ #category : 'accessing' }
BpKiviatRing >> boundsWith: aTransform in: anExtent [
	"Answer my bounds in a plot area of anExtent, and give my geometry a corner on each axis."

	| points box |
	points := angles collect: [ :each | aTransform pointFor: each @ location ].
	box := Rectangle encompassing: points.
	self geometry vertices: (points collect: [ :each | each - box origin ]).
	^ box
]

{ #category : 'initialization' }
BpKiviatRing >> location: aFraction angles: aCollectionOfAngles [

	angles := aCollectionOfAngles.
	self setAxis: #y location: aFraction.
	self geometry: (BlPolygonGeometry vertices: { (0 @ 0) })
]
