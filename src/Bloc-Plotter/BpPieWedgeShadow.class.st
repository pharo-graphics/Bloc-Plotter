"
I am the shadow of a `BpPieWedge`: a darker, half transparent copy of its shape, slightly moved to the bottom left.

## Examples

```
BpPieWedgeShadow exampleHogsShadow
```

## Design Rationale

- I do not receive mouse events, so I never hide a wedge.

## Usage

1. `BpPie>>rebuild` creates me with `on:` for each wedge when its `shadow` is true, and adds me before all the wedges so that no shadow covers a wedge.
2. `BpPieLayout` places me where my wedge is, moved by `BpPie>>shadowOffsetIn:`.
"
Class {
	#name : 'BpPieWedgeShadow',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'wedge'
	],
	#category : 'Bloc-Plotter-Pie',
	#package : 'Bloc-Plotter',
	#tag : 'Pie'
}

{ #category : 'examples' }
BpPieWedgeShadow class >> exampleHogsShadow [
	"Answer the shadow of the exploded 'Hogs' wedge of `BpPie class>>#exampleExplodeShadowRotate`."

	<sampleInstance>
	^ BpPie exampleExplodeShadowRotate shadows second
]

{ #category : 'instance creation' }
BpPieWedgeShadow class >> on: aWedge [

	^ self new
		  wedge: aWedge;
		  yourself
]

{ #category : 'layout' }
BpPieWedgeShadow >> boundsInPie: aPie extent: anExtent [
	"Answer the bounds of my wedge, slightly moved to the bottom left."

	^ (wedge boundsInPie: aPie extent: anExtent) translateBy: (aPie shadowOffsetIn: anExtent)
]

{ #category : 'initialization' }
BpPieWedgeShadow >> initialize [

	super initialize.
	self preventMouseEvents
]

{ #category : 'layout' }
BpPieWedgeShadow >> measureInPie: aPie extent: anExtent [

	self measure: (BlExtentMeasurementSpec exact: (aPie wedgeDiameterIn: anExtent) asPoint)
]

{ #category : 'accessing' }
BpPieWedgeShadow >> wedge [

	^ wedge
]

{ #category : 'accessing' }
BpPieWedgeShadow >> wedge: aWedge [
	"Take the shape of aWedge and a darker (shade 0.7), half transparent version of its color."

	| color |
	wedge := aWedge.
	self geometry: aWedge geometry copy.
	color := aWedge background paint color.
	self background: (Color
		 r: color red * 0.3
		 g: color green * 0.3
		 b: color blue * 0.3
		 alpha: 0.5)
]
