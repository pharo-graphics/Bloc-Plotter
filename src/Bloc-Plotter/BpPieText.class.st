"
I am a text of a `BpPie`: a label or a percentage shown on the bisector of a `BpPieWedge`, at a `distance` from the pie center given as a fraction of its radius. I show my lines as my superclass `BpText` does.

## Examples

```
BpPieText exampleValueAndPercent
```

## Design Rationale

- My `alignment` is `#center` inside the pie; outside it, `#left` on the right half and `#right` on the left half, so that I go away from the pie.
- When I rotate, my `rotationAngle` follows the bisector of my wedge but stays between -90 and 90 degrees, so that I am never upside down.

## Usage

1. `BpPieLabelSet>>textFor:` creates me with my text, my wedge, my distance and whether I `rotate`.
2. `BpPie>>fitUnitRadiusIn:` asks me `maxUnitRadiusIn:radius:` to keep me inside the pie.
3. `BpPieLayout` places me around my anchor point (`BpPie>>anchorOf:in:`) following my `alignment`.

## Implementation Notes

- My rotation is a transformation around my anchor point, so it does not change my layout bounds.
"
Class {
	#name : 'BpPieText',
	#superclass : 'BpText',
	#instVars : [
		'wedge',
		'distance',
		'rotate'
	],
	#category : 'Bloc-Plotter-Pie',
	#package : 'Bloc-Plotter',
	#tag : 'Pie'
}

{ #category : 'examples' }
BpPieText class >> exampleValueAndPercent [
	"Answer the two-line text '36' and '45.0%' of the first wedge of a pie."

	<sampleInstance>
	^ BpPie examplePieLabelValuesAndPercents texts first
]

{ #category : 'geometry' }
BpPieText >> alignment [
	"Answer how I am placed relative to my anchor point: #center inside the pie, and outside it #left on the right half so that I go away from the pie, #right on the left half."

	distance > 1 ifFalse: [ ^ #center ].
	^ wedge midAngle degreesToRadians cos > 0
		  ifTrue: [ #left ]
		  ifFalse: [ #right ]
]

{ #category : 'layout' }
BpPieText >> boundsInPie: aPie extent: anExtent [
	"Answer my bounds placed around my anchor point following my alignment."

	| anchor size |
	anchor := aPie anchorOf: self in: anExtent.
	size := self measuredExtent.
	self alignment = #left ifTrue: [ ^ anchor - (0 @ (size y / 2)) extent: size ].
	self alignment = #right ifTrue: [ ^ anchor - (size x @ (size y / 2)) extent: size ].
	^ anchor - (size / 2) extent: size
]

{ #category : 'accessing' }
BpPieText >> distance [
	"Answer the distance from the pie center to my anchor, as a fraction of the pie radius."

	^ distance
]

{ #category : 'initialization' }
BpPieText >> initialize [

	super initialize.
	distance := 0.6.
	rotate := false
]

{ #category : 'layout' }
BpPieText >> maxRadiusFor: aFactor within: aHalfSize range: aRange [
	"Answer the largest r such that r * aFactor plus any offset between aRange x and aRange y stays between aHalfSize negated and aHalfSize."

	aFactor > 0 ifTrue: [ ^ aHalfSize - aRange y / aFactor max: 0 ].
	aFactor < 0 ifTrue: [ ^ aHalfSize + aRange x / aFactor negated max: 0 ].
	^ Float infinity
]

{ #category : 'layout' }
BpPieText >> maxUnitRadiusIn: anExtent radius: aRadius [
	"Answer the largest radius of a pie of radius 1 for which I stay inside anExtent, my anchor being on the bisector of my wedge."

	| size factor radians xRange yRange |
	size := self measuredExtent.
	rotate ifTrue: [ size := (size x max: size y) asPoint ].
	factor := aRadius * (distance + wedge explode).
	radians := wedge midAngle degreesToRadians.
	xRange := self alignment = #left
		          ifTrue: [ 0 @ size x ]
		          ifFalse: [
			          self alignment = #right
				          ifTrue: [ size x negated @ 0 ]
				          ifFalse: [ size x / -2 @ (size x / 2) ] ].
	yRange := size y / -2 @ (size y / 2).
	^ (self maxRadiusFor: radians cos * factor within: anExtent x / 2 range: xRange) min:
		  (self maxRadiusFor: radians sin negated * factor within: anExtent y / 2 range: yRange)
]

{ #category : 'layout' }
BpPieText >> measureInPie: aPie extent: anExtent [

	self measure: BlExtentMeasurementSpec unspecified
]

{ #category : 'accessing' }
BpPieText >> rotate [

	^ rotate
]

{ #category : 'geometry' }
BpPieText >> rotationAngle [
	"Answer my rotation in degrees, counterclockwise: along the bisector of my wedge when I rotate, kept between -90 and 90 so that I am never upside down."

	| angle |
	rotate ifFalse: [ ^ 0 ].
	angle := wedge midAngle \\ 360.
	angle > 270 ifTrue: [ ^ angle - 360 ].
	angle > 90 ifTrue: [ ^ angle - 180 ].
	^ angle
]

{ #category : 'private - updating' }
BpPieText >> updateTransformation [
	"Rotate me around my anchor point. Bloc rotates clockwise, hence the negated angle."

	| origin |
	origin := self alignment = #left
		          ifTrue: [ BlAffineTransformationLeftCenterOrigin new ]
		          ifFalse: [
			          self alignment = #right
				          ifTrue: [ BlAffineTransformationRightCenterOrigin new ]
				          ifFalse: [ BlAffineTransformationCenterOrigin new ] ].
	self transformDo: [ :t |
		t
			origin: origin;
			rotateBy: self rotationAngle negated ]
]

{ #category : 'accessing' }
BpPieText >> wedge [

	^ wedge
]

{ #category : 'accessing' }
BpPieText >> wedge: aWedge distance: aNumber rotate: aBoolean [

	wedge := aWedge.
	distance := aNumber.
	rotate := aBoolean.
	self updateTransformation
]
