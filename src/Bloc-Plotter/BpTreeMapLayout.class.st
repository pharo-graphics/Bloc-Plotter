"
I am the layout of a `BpTreeMap`: I let it place its boxes in its size, then give them their bounds.

## Examples

```
BpTreeMapLayout instanceOfAmounts
```

## Usage

`BpTreeMap>>initialize` installs me; Bloc then sends me `measure:with:` and `layout:in:context:`.
"
Class {
	#name : 'BpTreeMapLayout',
	#superclass : 'BlLayout',
	#category : 'Bloc-Plotter-TreeMap',
	#package : 'Bloc-Plotter',
	#tag : 'TreeMap'
}

{ #category : 'instances' }
BpTreeMapLayout class >> instanceOfAmounts [

	<sampleInstance>
	^ BpTreeMap instanceAmounts layout
]

{ #category : 'layout' }
BpTreeMapLayout >> layout: aTreeMap in: aRectangle context: aBlElementBoundsUpdater [

	aTreeMap boxes do: [ :each | each applyLayoutIn: each placement context: aBlElementBoundsUpdater ]
]

{ #category : 'measure' }
BpTreeMapLayout >> measure: aTreeMap with: anExtentSpec [
	"Take the size the tree map is given, let it place its boxes in it, then give each box its size."

	aTreeMap measuredExtent: (anExtentSpec extentForWidth: 0.0 height: 0.0).
	aTreeMap placeBoxesIn: aTreeMap measuredExtent.
	aTreeMap boxes do: [ :each | each measure: (BlExtentMeasurementSpec exact: each placement extent) ]
]
