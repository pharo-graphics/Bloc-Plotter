"
I convert polar data coordinates to the pixels of a plot area: x is an angle in radians, y a radius, on a linear or log scale. The circle of the upper radius fits the smallest side of the plot area. See `BpDataTransform` for the life cycle.

## Examples

```
BpPolarTransform instanceClock
```

## Design Rationale

- A bar is a rectangle of the data but not of the pixels, so I give it a sector: `preparePatch:` makes it take a `BlAnnulusSectorGeometry` before it is measured, and `pixelBoundsOf:` gives that geometry its angles and radii. The other patches are made of points, which `pointFor:` moves.

## Usage

1. `BpPolarChart>>newTransform` creates me.
2. `BpChart>>rebuild` sends me `preparePatch:` for each patch; `BpRectanglePatch>>pixelBoundsWith:` sends me `pixelBoundsOf:`. `BpPolarTick` and `BpPolarGridLine` ask me `directionFor:` and `radiusFor:`.

## Invariants and Assumptions

- The values below the lower limit are at the center.
"
Class {
	#name : 'BpPolarTransform',
	#superclass : 'BpDataTransform',
	#instVars : [
		'startAngle',
		'counterClock'
	],
	#category : 'Bloc-Plotter-Polar',
	#package : 'Bloc-Plotter',
	#tag : 'Polar'
}

{ #category : 'instances' }
BpPolarTransform class >> instanceClock [
	"Answer a transform of a 200 by 200 plot area turning as a clock: the angle 0 is at the top and the angles go clockwise. The radii go from 0 to 10."

	<sampleInstance>
	^ self new
		  startAngle: 90;
		  counterClock: false;
		  yLimits: #( 0 10 );
		  extent: 200 @ 200;
		  yourself
]

{ #category : 'transforming' }
BpPolarTransform >> center [
	"Answer the pixel position of the center in the plot area."

	^ extent / 2
]

{ #category : 'accessing' }
BpPolarTransform >> counterClock [

	^ counterClock
]

{ #category : 'accessing' }
BpPolarTransform >> counterClock: aBoolean [
	"Set whether the angles grow counterclockwise."

	counterClock := aBoolean
]

{ #category : 'transforming' }
BpPolarTransform >> degreesFor: anAngle [
	"Answer where anAngle, in radians from my start angle and in my direction, is: in degrees, counterclockwise from the right."

	^ counterClock
		  ifTrue: [ startAngle + anAngle radiansToDegrees ]
		  ifFalse: [ startAngle - anAngle radiansToDegrees ]
]

{ #category : 'transforming' }
BpPolarTransform >> directionFor: anAngle [
	"Answer the point at distance 1 of the origin toward anAngle, y going down."

	| radians |
	radians := (self degreesFor: anAngle) degreesToRadians.
	^ radians cos @ radians sin negated
]

{ #category : 'initialization' }
BpPolarTransform >> initialize [

	super initialize.
	xLimits := {
		           0.
		           Float twoPi }.
	startAngle := 0.
	counterClock := true
]

{ #category : 'transforming' }
BpPolarTransform >> outerRadius [
	"Answer the radius in pixels of the circle of my upper limit: it fits the smallest side of the plot area."

	^ (extent x min: extent y) / 2
]

{ #category : 'transforming' }
BpPolarTransform >> pixelBoundsOf: aRectanglePatch [
	"Give aRectanglePatch its sector, from the angles and radii of its data bounds, and answer the square around its outer circle: the sector of Bloc is centered in it and its angles go clockwise."

	| box inner outer angles |
	box := aRectanglePatch dataBounds.
	inner := self radiusFor: box top.
	outer := self radiusFor: box bottom.
	angles := {
		          (self degreesFor: box left).
		          (self degreesFor: box right) }.
	aRectanglePatch geometry
		startAngle: angles max negated;
		endAngle: angles min negated;
		innerRadius: (outer isZero
			 ifTrue: [ 0 ]
			 ifFalse: [ inner / outer ]).
	^ self center - outer asPoint extent: outer asPoint * 2
]

{ #category : 'transforming' }
BpPolarTransform >> pointFor: aDataPoint [
	"Answer the pixel position in the plot area of aDataPoint: its x is an angle in radians, its y a radius."

	^ self center + ((self directionFor: aDataPoint x) * (self radiusFor: aDataPoint y))
]

{ #category : 'transforming' }
BpPolarTransform >> preparePatch: aPatch [

	aPatch bePolar
]

{ #category : 'transforming' }
BpPolarTransform >> radiusFor: aValue [
	"Answer the distance in pixels from the center to aValue. The values below my lower limit are at the center."

	^ ((self fractionOf: aValue limits: yLimits scale: yScale) max: 0) * self outerRadius
]

{ #category : 'accessing' }
BpPolarTransform >> startAngle [

	^ startAngle
]

{ #category : 'accessing' }
BpPolarTransform >> startAngle: aNumber [
	"Set where the angle 0 is, in degrees, counterclockwise from the right."

	startAngle := aNumber
]
