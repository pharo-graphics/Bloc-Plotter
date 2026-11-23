"
I am the layout of `BpColorBar`: I put its strip on the left, its ticks beside it, and its label along its right side.

## Examples

```
BpColorBarLayout instanceOfHarvest
```

## Usage

`BpColorBar>>initialize` installs me; Bloc then sends me `measure:with:` and `layout:in:context:`.

## Implementation Notes

- The height is the one I am given, and the width the one the bar needs (`BpColorBar>>fittingWidth`) unless it is imposed.
- The label is rotated around its center, hence placed by its bounds before the rotation (`BpColorBar>>labelBoundsIn:`).
"
Class {
	#name : 'BpColorBarLayout',
	#superclass : 'BlLayout',
	#category : 'Bloc-Plotter-ColorBar',
	#package : 'Bloc-Plotter',
	#tag : 'ColorBar'
}

{ #category : 'instances' }
BpColorBarLayout class >> instanceOfHarvest [

	<sampleInstance>
	^ BpColorBar instanceOfHarvest layout
]

{ #category : 'layout' }
BpColorBarLayout >> layout: aColorBar in: aRectangle context: aBlElementBoundsUpdater [
	"Place the strip on the left, the ticks beside it, and the label along the right side."

	| extent |
	extent := aColorBar measuredExtent.
	aColorBar strip applyLayoutIn: (0 @ 0 extent: aColorBar thickness @ extent y) context: aBlElementBoundsUpdater.
	aColorBar ticks do: [ :each | each layoutIn: aColorBar context: aBlElementBoundsUpdater ].
	aColorBar labelElement applyLayoutIn: (aColorBar labelBoundsIn: extent) context: aBlElementBoundsUpdater
]

{ #category : 'measure' }
BpColorBarLayout >> measure: aColorBar with: anExtentSpec [
	"Measure the ticks and the label, take the width they need unless another one is imposed, then give the strip my height."

	aColorBar children do: [ :each | self measureChild: each parentSpec: BlExtentMeasurementSpec unspecified ].
	aColorBar measuredExtent: (anExtentSpec extentForWidth: aColorBar fittingWidth height: 0.0).
	aColorBar strip measure: (BlExtentMeasurementSpec exact: aColorBar thickness @ aColorBar measuredExtent y)
]
