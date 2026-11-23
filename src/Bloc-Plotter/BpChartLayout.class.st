"
I am the layout of `BpChart`: I give their plot area the space left by the tick labels, the title and the color bars, then place them all.

## Examples

```
BpChartLayout instanceOfHistogram
```

## Usage

`BpChart>>initialize` installs me; Bloc then sends me `measure:with:` and `layout:in:context:`.

## Implementation Notes

- I measure the tick labels, the title and the color bars first, so that `BpChart>>computePlotBoundsIn:` leaves them room; the plot area then gets the remaining extent exactly.
- The ticks place themselves (`BpTick>>layoutIn:context:`) from the data transform of the chart.
"
Class {
	#name : 'BpChartLayout',
	#superclass : 'BlLayout',
	#category : 'Bloc-Plotter-Chart',
	#package : 'Bloc-Plotter',
	#tag : 'Chart'
}

{ #category : 'instances' }
BpChartLayout class >> instanceOfHistogram [

	<sampleInstance>
	^ BpChart instanceHistogram layout
]

{ #category : 'layout' }
BpChartLayout >> layout: aChart in: aRectangle context: aBlElementBoundsUpdater [
	"Place the plot area, the ticks around it, the title centered above it and the color bars beside it."

	| plot title |
	plot := aChart plotBounds.
	aChart plotArea applyLayoutIn: plot context: aBlElementBoundsUpdater.
	aChart ticks do: [ :each | each layoutIn: aChart context: aBlElementBoundsUpdater ].
	title := aChart titleElement.
	title
		applyLayoutIn:
		(plot center x - (title measuredExtent x / 2) @ (aChart titleBottom - title measuredExtent y) extent: title measuredExtent)
		context: aBlElementBoundsUpdater.
	aChart layoutColorBarsContext: aBlElementBoundsUpdater.
	aChart layoutLegendContext: aBlElementBoundsUpdater
]

{ #category : 'measure' }
BpChartLayout >> measure: aChart with: anExtentSpec [
	"Measure the tick marks, labels, title and color bars, compute the plot bounds from their sizes, then give the plot area its size and the color bars its height."

	| extent |
	extent := anExtentSpec extentForWidth: 0.0 height: 0.0.
	aChart measuredExtent: extent.
	aChart children do: [ :each |
		each == aChart plotArea ifFalse: [ self measureChild: each parentSpec: BlExtentMeasurementSpec unspecified ] ].
	aChart computePlotBoundsIn: extent.
	aChart plotArea measure: (BlExtentMeasurementSpec exact: aChart plotBounds extent).
	aChart measureColorBars
]
