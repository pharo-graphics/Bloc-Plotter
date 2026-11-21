"
I am one tick of an axis of `BpAxes`: a short mark against the plot area and the label of my location.

## Examples

```
BpTick exampleXTick
```

## Usage

1. `BpAxes>>newTicksOn:` creates me with `axis:location:text:`, and `BpAxes>>rebuildTicks` adds my `elements` to the axes.
2. `BpAxesLayout` sends me `layoutIn:context:` to place my mark and my label from the data transform of the axes.
3. The axes replace me at each rebuild.
"
Class {
	#name : 'BpTick',
	#superclass : 'Object',
	#instVars : [
		'axis',
		'mark',
		'label',
		'location'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'instance creation' }
BpTick class >> axis: aSymbol location: aNumber text: aString [

	^ self new
		  axis: aSymbol location: aNumber text: aString;
		  yourself
]

{ #category : 'examples' }
BpTick class >> exampleXTick [

	<sampleInstance>
	^ self axis: #x location: 2.5 text: '2.5'
]

{ #category : 'accessing' }
BpTick >> axis [
	"Answer #x or #y."

	^ axis
]

{ #category : 'initialization' }
BpTick >> axis: aSymbol location: aNumber text: aString [

	axis := aSymbol.
	location := aNumber.
	mark := BlElement new
		        background: Color black;
		        extent: (aSymbol = #x
			         ifTrue: [ 1 @ 3.5 ]
			         ifFalse: [ 3.5 @ 1 ]);
		        yourself.
	label := BlTextElement new
		         labelMeasurement;
		         text: (aString asRopedText fontSize: 11);
		         yourself
]

{ #category : 'accessing' }
BpTick >> elements [

	^ {
		  mark.
		  label }
]

{ #category : 'accessing' }
BpTick >> label [

	^ label
]

{ #category : 'layout' }
BpTick >> layoutIn: anAxes context: aBlElementBoundsUpdater [
	"Place my mark outside the plot area, against its side, and my label next to it."

	| plot position size |
	plot := anAxes plotBounds.
	size := label measuredExtent.
	axis = #x
		ifTrue: [
			position := plot left + (anAxes dataTransform pointFor: location @ anAxes dataTransform yLimits first) x.
			mark applyLayoutIn: (position - 0.5 @ plot bottom extent: 1 @ 3.5) context: aBlElementBoundsUpdater.
			label applyLayoutIn: (position - (size x / 2) @ (plot bottom + 5) extent: size) context: aBlElementBoundsUpdater ]
		ifFalse: [
			position := plot top + (anAxes dataTransform pointFor: anAxes dataTransform xLimits first @ location) y.
			mark applyLayoutIn: (plot left - 3.5 @ (position - 0.5) extent: 3.5 @ 1) context: aBlElementBoundsUpdater.
			label applyLayoutIn: (plot left - 5 - size x @ (position - (size y / 2)) extent: size) context: aBlElementBoundsUpdater ]
]

{ #category : 'accessing' }
BpTick >> location [
	"Answer the data value I mark on my axis."

	^ location
]

{ #category : 'accessing' }
BpTick >> mark [

	^ mark
]
