"
I am the layout of `BpAxes`: I give their plot area the space left by the tick labels and the title, then place the plot area, the ticks and the title.

## Examples

```
BpAxesLayout instanceOfHistogram
```

## Usage

`BpAxes>>initialize` installs me; Bloc then sends me `measure:with:` and `layout:in:context:`.

## Implementation Notes

- I measure the tick labels and the title first, so that `BpAxes>>computePlotBoundsIn:` leaves them room; the plot area then gets the remaining extent exactly.
- The ticks place themselves (`BpTick>>layoutIn:context:`) from the data transform of the axes.
"
Class {
	#name : 'BpAxesLayout',
	#superclass : 'BlLayout',
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'instances' }
BpAxesLayout class >> instanceOfHistogram [

	<sampleInstance>
	^ BpAxes instanceHistogram layout
]

{ #category : 'layout' }
BpAxesLayout >> layout: anAxes in: aRectangle context: aBlElementBoundsUpdater [
	"Place the plot area, the ticks around it and the title centered above it."

	| plot title |
	plot := anAxes plotBounds.
	anAxes plotArea applyLayoutIn: plot context: aBlElementBoundsUpdater.
	anAxes ticks do: [ :each | each layoutIn: anAxes context: aBlElementBoundsUpdater ].
	title := anAxes titleElement.
	title
		applyLayoutIn:
		(plot center x - (title measuredExtent x / 2) @ (plot top - 6 - title measuredExtent y) extent: title measuredExtent)
		context: aBlElementBoundsUpdater
]

{ #category : 'measure' }
BpAxesLayout >> measure: anAxes with: anExtentSpec [
	"Measure the tick marks, labels and title, compute the plot bounds from their sizes, then give the plot area its size."

	| extent |
	extent := anExtentSpec extentForWidth: 0.0 height: 0.0.
	anAxes measuredExtent: extent.
	anAxes children do: [ :each |
		each == anAxes plotArea ifFalse: [ self measureChild: each parentSpec: BlExtentMeasurementSpec unspecified ] ].
	anAxes computePlotBoundsIn: extent.
	anAxes plotArea measure: (BlExtentMeasurementSpec exact: anAxes plotBounds extent)
]
