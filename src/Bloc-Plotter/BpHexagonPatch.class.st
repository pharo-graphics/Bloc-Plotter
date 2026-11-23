"
I am a hexagon of a `BpHexbin`. I know my `center`, my `count` of points and my `amount`, the number my color shows. See `BpPatch` for the life cycle.

## Examples

```
BpHexagonPatch instanceHexagon
```

## Implementation Notes

- My border is centered on my edge: drawn inside, it would let the plot area show between the antialiased edges of neighboring hexagons.
- I only count for the center of my hexagon in the limits of the chart (`dataBounds`).
"
Class {
	#name : 'BpHexagonPatch',
	#superclass : 'BpPolygonPatch',
	#instVars : [
		'center',
		'count',
		'amount'
	],
	#category : 'Bloc-Plotter-Hexbin',
	#package : 'Bloc-Plotter',
	#tag : 'Hexbin'
}

{ #category : 'instances' }
BpHexagonPatch class >> instanceHexagon [
	"Answer the hexagon holding two points out of three."

	<sampleInstance>
	^ (BpHexbin x: #( 0 1 1 ) y: #( 0 1 1 )) patches detect: [ :each | each count = 2 ]
]

{ #category : 'accessing' }
BpHexagonPatch >> amount [
	"Answer the number shown by my color: my count, or the values of my points reduced to one."

	^ amount
]

{ #category : 'accessing' }
BpHexagonPatch >> amount: aNumber [

	amount := aNumber
]

{ #category : 'accessing' }
BpHexagonPatch >> center [
	"Answer my center in data coordinates."

	^ center
]

{ #category : 'accessing' }
BpHexagonPatch >> center: aPoint [

	center := aPoint
]

{ #category : 'accessing' }
BpHexagonPatch >> count [
	"Answer the number of points I hold."

	^ count
]

{ #category : 'accessing' }
BpHexagonPatch >> count: anInteger [

	count := anInteger
]

{ #category : 'accessing' }
BpHexagonPatch >> dataBounds [
	"Answer my center only: my corners may be out of the region of my hexbin, which the limits of the chart follow."

	^ center corner: center
]

{ #category : 'initialization' }
BpHexagonPatch >> initialize [

	super initialize.
	self outskirts: BlOutskirts centered
]
