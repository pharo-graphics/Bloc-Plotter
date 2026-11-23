"
I am one tick of a `BpPolarChart`: the label of an angle, placed outside its circle, or the label of a radius, placed on its circle in the direction of `BpPolarChart>>radialLabelAngle`. I have no mark: the grid shows where I am. See `BpTick` for the life cycle.

## Examples

```
BpPolarTick instanceAngle
```

## Usage

`BpPolarChart>>newTickOn:location:text:` creates me, and `BpPolarChart>>computePlotBoundsIn:` asks me `maxRadiusIn:with:` so that my label stays inside the chart.

## Implementation Notes

- My label does not receive mouse events, because the label of a radius may be over a patch.
"
Class {
	#name : 'BpPolarTick',
	#superclass : 'BpTick',
	#category : 'Bloc-Plotter-Polar',
	#package : 'Bloc-Plotter',
	#tag : 'Polar'
}

{ #category : 'instances' }
BpPolarTick class >> instanceAngle [
	"Answer the tick of the angle pi / 2, labeled in degrees."

	<sampleInstance>
	^ self axis: #x location: Float halfPi text: '90°'
]

{ #category : 'initialization' }
BpPolarTick >> axis: aSymbol location: aNumber text: aString [
	"My label lets the mouse events go through: the label of a radius may be over a patch."

	super axis: aSymbol location: aNumber text: aString.
	label preventMouseEvents
]

{ #category : 'accessing' }
BpPolarTick >> elements [
	"Answer my label only: the grid shows where I am."

	^ { label }
]

{ #category : 'layout' }
BpPolarTick >> gap [
	"Answer the distance in pixels from the circle of the chart to the label of an angle."

	^ 6
]

{ #category : 'layout' }
BpPolarTick >> layoutIn: aChart context: aBlElementBoundsUpdater [
	"Place the label of an angle outside the circle of the chart, the label of a radius on its circle."

	| size center |
	size := label measuredExtent.
	center := axis = #x
		          ifTrue: [ self outerCenterIn: aChart ]
		          ifFalse: [ self radialCenterIn: aChart ].
	label applyLayoutIn: (center - (size / 2) extent: size) context: aBlElementBoundsUpdater
]

{ #category : 'layout' }
BpPolarTick >> maxRadiusIn: anExtent with: aPolarTransform [
	"Answer the largest radius of a circle centered in anExtent for which the label of my angle stays inside. My label must be measured."

	| direction size |
	direction := (aPolarTransform directionFor: location) abs.
	size := label measuredExtent.
	^ (self maxRadiusToward: direction x length: size x within: anExtent x) min:
		  (self maxRadiusToward: direction y length: size y within: anExtent y)
]

{ #category : 'layout' }
BpPolarTick >> maxRadiusToward: aFraction length: aLabelLength within: aLength [
	"The label is centered at aFraction of the radius, of the gap and of half its length; half its length more must fit in half aLength."

	aFraction < 1.0e-6 ifTrue: [ ^ Float infinity ].
	^ aLength - aLabelLength / 2 / aFraction - (aLabelLength / 2) - self gap
]

{ #category : 'layout' }
BpPolarTick >> outerCenterIn: aChart [
	"Answer the center of the label of my angle: in its direction, far enough for the label not to touch the circle."

	| plot direction |
	plot := aChart plotBounds.
	direction := aChart dataTransform directionFor: location.
	^ plot center + (direction * (plot width / 2 + self gap)) + (direction * label measuredExtent / 2)
]

{ #category : 'layout' }
BpPolarTick >> radialCenterIn: aChart [
	"Answer the center of the label of my radius, on its circle in the direction the chart asks."

	| radians |
	radians := aChart radialLabelAngle degreesToRadians.
	^ aChart plotBounds center + (radians cos @ radians sin negated * (aChart dataTransform radiusFor: location))
]
