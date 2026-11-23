"
I convert data coordinates to the pixels of a plot area: x goes right, y goes up, each axis on a linear or log scale. Patches and ticks ask me `pointFor:`, bars ask me `pixelBoundsOf:`. My subclass `BpPolarTransform` takes the x as an angle and the y as a radius.

## Examples

```
BpDataTransform instanceLogScale
```

## Usage

1. `BpChart>>newTransform` creates me, and `BpChart>>initialize` gives me to its `BpPlotArea`.
2. `BpChart>>rebuild` sets my limits and scales and lets me prepare the patches (`preparePatch:`), and `BpChart>>plotBounds:` my extent.
3. `BpRectanglePatch>>pixelBoundsWith:`, `BpPolygonPatch>>pixelBoundsWith:` and `BpTick>>layoutIn:context:` convert their data coordinates with me.

- I am mutable and shared by the chart and its plot area: points computed from me are valid until the next rebuild or layout.

## Implementation Notes

- On a log scale, non-positive values are clipped one axis length below the axis: bars starting at 0 then go down out of the clipped plot area.
"
Class {
	#name : 'BpDataTransform',
	#superclass : 'Object',
	#instVars : [
		'xLimits',
		'yLimits',
		'xScale',
		'yScale',
		'extent'
	],
	#category : 'Bloc-Plotter-Chart',
	#package : 'Bloc-Plotter',
	#tag : 'Chart'
}

{ #category : 'instances' }
BpDataTransform class >> instanceLogScale [
	"Answer a transform of a 400 by 300 plot area showing x from 0 to 10, and y from 1 to 1000 on a log scale."

	<sampleInstance>
	^ self new
		  xLimits: #( 0 10 );
		  yLimits: #( 1 1000 );
		  yScale: #log;
		  extent: 400 @ 300;
		  yourself
]

{ #category : 'accessing' }
BpDataTransform >> extent [

	^ extent
]

{ #category : 'accessing' }
BpDataTransform >> extent: aPoint [
	"Set the size in pixels of the plot area."

	extent := aPoint
]

{ #category : 'transforming' }
BpDataTransform >> fractionOf: aValue limits: aCollection scale: aSymbol [
	"Answer where aValue is between the limits, 0 at the first and 1 at the last. On a log scale, non-positive values are clipped well below the axis."

	| low high value |
	aSymbol = #log
		ifTrue: [
			low := aCollection first log: 10.
			high := aCollection last log: 10.
			value := aValue > 0
				         ifTrue: [ aValue log: 10 ]
				         ifFalse: [ low - (high - low) ] ]
		ifFalse: [
			low := aCollection first.
			high := aCollection last.
			value := aValue ].
	high = low ifTrue: [ ^ 0.5 ].
	^ value - low / (high - low)
]

{ #category : 'initialization' }
BpDataTransform >> initialize [

	super initialize.
	xLimits := #( 0 1 ).
	yLimits := #( 0 1 ).
	xScale := #linear.
	yScale := #linear.
	extent := 1 @ 1
]

{ #category : 'transforming' }
BpDataTransform >> pixelBoundsOf: aRectanglePatch [
	"Answer the pixel bounds of aRectanglePatch in the plot area."

	^ self rectangleFor: aRectanglePatch dataBounds
]

{ #category : 'transforming' }
BpDataTransform >> pointFor: aDataPoint [
	"Answer the pixel position in the plot area of aDataPoint, the y axis going up."

	| xFraction yFraction |
	xFraction := self fractionOf: aDataPoint x limits: xLimits scale: xScale.
	yFraction := self fractionOf: aDataPoint y limits: yLimits scale: yScale.
	^ xFraction * extent x @ (1 - yFraction * extent y)
]

{ #category : 'transforming' }
BpDataTransform >> preparePatch: aPatch [
	"Give aPatch the shape it needs to be shown with me, before it is measured. Nothing to do: patches are built for an x and a y axis."

	
]

{ #category : 'transforming' }
BpDataTransform >> rectangleFor: aDataRectangle [
	"Answer the pixel rectangle in the plot area of aDataRectangle."

	^ Rectangle encompassing: {
		  (self pointFor: aDataRectangle origin).
		  (self pointFor: aDataRectangle corner) }
]

{ #category : 'accessing' }
BpDataTransform >> xLimits [

	^ xLimits
]

{ #category : 'accessing' }
BpDataTransform >> xLimits: aCollection [
	"Set the data values shown at the left and right of the plot area (first and last of aCollection)."

	xLimits := aCollection
]

{ #category : 'accessing' }
BpDataTransform >> xScale [

	^ xScale
]

{ #category : 'accessing' }
BpDataTransform >> xScale: aSymbol [
	"Set the x scale: #linear or #log."

	xScale := aSymbol
]

{ #category : 'accessing' }
BpDataTransform >> yLimits [

	^ yLimits
]

{ #category : 'accessing' }
BpDataTransform >> yLimits: aCollection [
	"Set the data values shown at the bottom and top of the plot area (first and last of aCollection)."

	yLimits := aCollection
]

{ #category : 'accessing' }
BpDataTransform >> yScale [

	^ yScale
]

{ #category : 'accessing' }
BpDataTransform >> yScale: aSymbol [
	"Set the y scale: #linear or #log."

	yScale := aSymbol
]
