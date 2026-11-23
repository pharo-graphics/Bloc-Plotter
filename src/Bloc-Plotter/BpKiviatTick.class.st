"
I label a value on one axis of a `BpKiviat`, at a fraction of its radius. See `BpTick` for the life cycle.

## Examples

```
BpKiviatTick instanceMiddle
```

## Design Rationale

- I know the angle of my axis, because each axis of a kiviat may have its own values; a `BpPolarTick` takes the angle of its chart.
- The label of the edge is moved inside the frame, since the name of the axis is just outside.

## Usage

`BpKiviat>>labelTicksOf:at:` creates me.
"
Class {
	#name : 'BpKiviatTick',
	#superclass : 'BpPolarTick',
	#instVars : [
		'angle'
	],
	#category : 'Bloc-Plotter-Kiviat',
	#package : 'Bloc-Plotter',
	#tag : 'Kiviat'
}

{ #category : 'instance creation' }
BpKiviatTick class >> angle: anAngle location: aFraction text: aString [

	^ self new
		  angle: anAngle location: aFraction text: aString;
		  yourself
]

{ #category : 'instances' }
BpKiviatTick class >> instanceMiddle [
	"Answer the label 5 in the middle of the first axis."

	<sampleInstance>
	^ self angle: 0 location: 0.5 text: '5'
]

{ #category : 'accessing' }
BpKiviatTick >> angle [
	"Answer the angle of the axis I label."

	^ angle
]

{ #category : 'initialization' }
BpKiviatTick >> angle: anAngle location: aFraction text: aString [

	angle := anAngle.
	self axis: #y location: aFraction text: aString.
	label
		text: (aString asRopedText fontSize: 9);
		background: (Color white alpha: 0.7)
]

{ #category : 'layout' }
BpKiviatTick >> radialCenterIn: aChart [
	"Answer the center of my label: on my axis at my fraction of the radius, closer to the center when my label would cross the edge and overlap the name of the axis."

	| direction radius |
	direction := aChart dataTransform directionFor: angle.
	radius := aChart dataTransform radiusFor: location.
	^ aChart plotBounds center + (direction * (radius min: aChart dataTransform outerRadius - (self reachAlong: direction)))
]

{ #category : 'layout' }
BpKiviatTick >> reachAlong: aPoint [
	"Answer how far my label extends from its center in the direction of the unit point aPoint."

	| size |
	size := label measuredExtent.
	^ aPoint x abs * size x + (aPoint y abs * size y) / 2
]
