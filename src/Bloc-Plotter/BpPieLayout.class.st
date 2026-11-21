"
I am the layout of a `BpPie`. I place its wedges, shadows and texts from the pie geometry rather than from their own constraints.

## Examples

```
BpPieLayout exampleOfLabeledPie
```

## Usage

`BpPie>>initialize` installs me; Bloc then sends me `measure:with:` and `layout:in:context:`.

## Implementation Notes

- The pie takes the extent it is given: I do not support `fitContent`.
- I measure the texts first, then ask the pie to fit its radius so that texts and exploded wedges stay inside it (`BpPie>>fitUnitRadiusIn:`), and only then measure the wedges and shadows, whose size depends on that radius.
- Each part answers its bounds itself (`boundsInPie:extent:`); children that are not parts of the pie are not placed.
"
Class {
	#name : 'BpPieLayout',
	#superclass : 'BlLayout',
	#category : 'Bloc-Plotter-Pie',
	#package : 'Bloc-Plotter',
	#tag : 'Pie'
}

{ #category : 'examples' }
BpPieLayout class >> exampleOfLabeledPie [
	"Answer the layout of a pie with outside labels."

	<sampleInstance>
	^ BpPie exampleLabels layout
]

{ #category : 'layout' }
BpPieLayout >> layout: anElement in: aRectangle context: aBlElementBoundsUpdater [
	"Place each part of my pie (wedge, shadow or text) at the bounds it computes from the pie geometry."

	| extent |
	extent := anElement measuredExtent.
	anElement parts do: [ :each | each applyLayoutIn: (each boundsInPie: anElement extent: extent) context: aBlElementBoundsUpdater ].
	self layoutIgnored: anElement context: aBlElementBoundsUpdater
]

{ #category : 'measure' }
BpPieLayout >> measure: anElement with: anExtentSpec [
	"Take the size my pie is given, measure its texts, fit the pie radius so that they stay inside, then measure the wedges and shadows for that radius."

	| extent |
	extent := anExtentSpec extentForWidth: 0.0 height: 0.0.
	anElement measuredExtent: extent.
	anElement texts do: [ :each | each measureInPie: anElement extent: extent ].
	anElement fitUnitRadiusIn: extent.
	anElement parts do: [ :each | each measureInPie: anElement extent: extent ].
	self measureIgnored: anElement with: anExtentSpec
]
