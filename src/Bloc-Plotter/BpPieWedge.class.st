"
I am one wedge of a `BpPie`: the sector showing one of its values. I know my value (`amount`), my `fraction` of the pie, the angles I span (`theta1`, `theta2`, in degrees counterclockwise from the right) and how far I am exploded.

## Examples

```
BpPieWedge exampleHogs
```

## Design Rationale

- My shape is a `BlAnnulusSectorGeometry` with no hole, so I only receive the mouse events that fall inside my sector.

## Usage

1. `BpPie>>newWedgeAt:amount:fraction:from:` creates me, gives me my color, and applies the `wedgeStyle` and the `whenWedge:do:` handlers of the pie.
2. `BpPieLayout` places me through `boundsInPie:extent:`: a square of the pie diameter, moved along my bisector when I am exploded.
3. `BpPieText` and `BpPieWedgeShadow` follow me. The pie replaces me at each rebuild.

- `explode:` can be changed after creation, followed by `requestLayout` on the pie, for example to pull me out while the mouse is over me.
"
Class {
	#name : 'BpPieWedge',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'index',
		'fraction',
		'theta1',
		'theta2',
		'explode',
		'label',
		'amount'
	],
	#category : 'Bloc-Plotter-Pie',
	#package : 'Bloc-Plotter',
	#tag : 'Pie'
}

{ #category : 'examples' }
BpPieWedge class >> exampleHogs [
	"Answer the exploded 'Hogs' wedge of `BpPie class>>#exampleExplodeShadowRotate`."

	<sampleInstance>
	^ BpPie exampleExplodeShadowRotate wedgeAt: 2
]

{ #category : 'accessing' }
BpPieWedge >> amount [
	"Answer the value I represent, one of the values of my pie."

	^ amount
]

{ #category : 'accessing' }
BpPieWedge >> amount: aNumber [

	amount := aNumber
]

{ #category : 'layout' }
BpPieWedge >> boundsInPie: aPie extent: anExtent [
	"Answer my bounds in aPie of extent anExtent: a square around my center, moved along my bisector when I am exploded."

	| diameter |
	diameter := aPie wedgeDiameterIn: anExtent.
	^ (aPie wedgeCenterOf: self in: anExtent) - (diameter / 2) asPoint extent: diameter asPoint
]

{ #category : 'accessing' }
BpPieWedge >> explode [
	"Answer how far I am moved away from the center, as a fraction of the pie radius."

	^ explode
]

{ #category : 'accessing' }
BpPieWedge >> explode: aNumber [

	explode := aNumber
]

{ #category : 'accessing' }
BpPieWedge >> fraction [
	"Answer the part of the whole pie I represent, between 0 and 1."

	^ fraction
]

{ #category : 'accessing' }
BpPieWedge >> fraction: aNumber [

	fraction := aNumber
]

{ #category : 'accessing' }
BpPieWedge >> index [

	^ index
]

{ #category : 'accessing' }
BpPieWedge >> index: anInteger [

	index := anInteger
]

{ #category : 'initialization' }
BpPieWedge >> initialize [

	super initialize.
	explode := 0.
	self theta1: 0 theta2: 360
]

{ #category : 'accessing' }
BpPieWedge >> label [

	^ label
]

{ #category : 'accessing' }
BpPieWedge >> label: aString [

	label := aString
]

{ #category : 'layout' }
BpPieWedge >> measureInPie: aPie extent: anExtent [

	self measure: (BlExtentMeasurementSpec exact: (aPie wedgeDiameterIn: anExtent) asPoint)
]

{ #category : 'geometry' }
BpPieWedge >> midAngle [
	"Answer the angle of my bisector, in degrees, counterclockwise from the right. Explosion and labels follow it."

	^ theta1 + theta2 / 2
]

{ #category : 'printing' }
BpPieWedge >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: index;
		nextPutAll: ': ';
		print: amount;
		nextPut: $)
]

{ #category : 'accessing' }
BpPieWedge >> theta1 [
	"Answer the angle where I start, in degrees, counterclockwise from the right."

	^ theta1
]

{ #category : 'accessing' }
BpPieWedge >> theta1: aStartAngle theta2: anEndAngle [
	"Set the angles I span, in degrees, counterclockwise from the right. My geometry is a Bloc annulus sector, whose angles go clockwise."

	theta1 := aStartAngle.
	theta2 := anEndAngle.
	self geometry: (BlAnnulusSectorGeometry new
		 innerRadius: 0;
		 startAngle: (aStartAngle max: anEndAngle) negated;
		 endAngle: (aStartAngle min: anEndAngle) negated;
		 yourself)
]

{ #category : 'accessing' }
BpPieWedge >> theta2 [
	"Answer the angle where I end, in degrees, counterclockwise from the right."

	^ theta2
]
