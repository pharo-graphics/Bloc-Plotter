"
I am one line of the grid of a `BpAxes` (`BpAxes>>grid:`): a light gray line across the plot area at the location of a tick, vertical for the x axis and horizontal for the y axis.

## Examples

```
BpGridLine instanceVertical
```

## Design Rationale

- I am drawn above the patches and below the legend, and I do not receive mouse events, so I never hide a patch from interaction handlers.

## Usage

1. `BpAxes>>rebuild` creates me with `axis:location:` for each tick when `BpAxes>>grid:` was sent true, and gives me to its `BpPlotArea` (`gridLines:`).
2. `BpPlotAreaLayout` places me with `boundsWith:in:`; the axes replace me at each rebuild.
"
Class {
	#name : 'BpGridLine',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'axis',
		'location'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'instance creation' }
BpGridLine class >> axis: anAxis location: aNumber [

	^ self new
		  setAxis: anAxis location: aNumber;
		  yourself
]

{ #category : 'instances' }
BpGridLine class >> instanceVertical [
	"Answer a vertical grid line at 0.5 on the x axis."

	<sampleInstance>
	^ self axis: #x location: 0.5
]

{ #category : 'accessing' }
BpGridLine >> axis [
	"Answer #x for a vertical line at a location of the x axis, #y for a horizontal one."

	^ axis
]

{ #category : 'accessing' }
BpGridLine >> boundsWith: aTransform in: anExtent [
	"Answer my bounds in a plot area of anExtent: a line 0.8 point wide across the plot area at my location."

	| width position |
	width := 0.8 * BpArtist pixelsPerPoint.
	axis = #x ifTrue: [
		position := (aTransform pointFor: location @ aTransform yLimits first) x.
		^ position - (width / 2) @ 0 extent: width @ anExtent y ].
	position := (aTransform pointFor: aTransform xLimits first @ location) y.
	^ 0 @ (position - (width / 2)) extent: anExtent x @ width
]

{ #category : 'initialization' }
BpGridLine >> initialize [

	super initialize.
	self
		background: (Color
			 r: 176
			 g: 176
			 b: 176
			 range: 255);
		preventMouseEvents
]

{ #category : 'accessing' }
BpGridLine >> location [

	^ location
]

{ #category : 'accessing' }
BpGridLine >> setAxis: anAxis location: aNumber [

	axis := anAxis.
	location := aNumber
]
