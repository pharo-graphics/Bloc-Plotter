"
I am the layout of a `BpPlotArea`: I place each patch where its data coordinates are, through the data transform of the plot area, each `BpGridLine` across the plot area at its location, and the legend in the upper right corner.

## Examples

```
BpPlotAreaLayout exampleOfHistogram
```

## Usage

`BpPlotArea>>initialize` installs me; Bloc then sends me `measure:with:` and `layout:in:context:`.

## Implementation Notes

- Measuring a patch (`BpPatch>>measureWith:`) computes its pixel bounds once; laying it out reuses them.
"
Class {
	#name : 'BpPlotAreaLayout',
	#superclass : 'BlLayout',
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'examples' }
BpPlotAreaLayout class >> exampleOfHistogram [

	<sampleInstance>
	^ BpAxes exampleHistogram plotArea layout
]

{ #category : 'layout' }
BpPlotAreaLayout >> layout: aPlotArea in: aRectangle context: aBlElementBoundsUpdater [
	"Place each patch where its data coordinates are, each grid line at its location, and the legend in the upper right corner."

	aPlotArea patches do: [ :each | each applyLayoutIn: each pixelBounds context: aBlElementBoundsUpdater ].
	aPlotArea gridLines do: [ :each |
		each applyLayoutIn: (each boundsWith: aPlotArea dataTransform in: aPlotArea measuredExtent) context: aBlElementBoundsUpdater ].
	aPlotArea legend ifNotNil: [ :legend |
		legend
			applyLayoutIn: (aPlotArea measuredExtent x - legend measuredExtent x - 6 @ 6 extent: legend measuredExtent)
			context: aBlElementBoundsUpdater ]
]

{ #category : 'measure' }
BpPlotAreaLayout >> measure: aPlotArea with: anExtentSpec [
	"Take the extent given by the axes, size each patch from its data coordinates, each grid line across the plot area, and let the legend fit its content."

	aPlotArea measuredExtent: (anExtentSpec extentForWidth: 0.0 height: 0.0).
	aPlotArea patches do: [ :each | each measureWith: aPlotArea dataTransform ].
	aPlotArea gridLines do: [ :each |
		each measure: (BlExtentMeasurementSpec exact: (each boundsWith: aPlotArea dataTransform in: aPlotArea measuredExtent) extent) ].
	aPlotArea legend ifNotNil: [ :legend | self measureChild: legend parentSpec: BlExtentMeasurementSpec unspecified ]
]
