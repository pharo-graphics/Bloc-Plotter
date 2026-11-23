"
I am a bar: the rectangle of one bin of one dataset of a `BpHistogram`, or of one bar of a `BpBarPlot`. I know the index of my `bin` (the index of the bar in a bar plot) and my `amount`, the count or density of the bin, or the height of the bar. See `BpPatch` for the life cycle.

## Examples

```
BpRectanglePatch exampleBar
```
"
Class {
	#name : 'BpRectanglePatch',
	#superclass : 'BpPatch',
	#instVars : [
		'dataBounds',
		'bin',
		'amount'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'examples' }
BpRectanglePatch class >> exampleBar [
	"Answer the bar of the second bin of a histogram, which holds two values."

	<sampleInstance>
	^ (BpHistogram new
		   x: #( 1 2 2 3 );
		   bins: 3;
		   yourself) patches second
]

{ #category : 'accessing' }
BpRectanglePatch >> amount [
	"Answer the value I show: my height, the count (or density) of my bin for my dataset."

	^ amount
]

{ #category : 'accessing' }
BpRectanglePatch >> amount: aNumber [

	amount := aNumber
]

{ #category : 'accessing' }
BpRectanglePatch >> bin [
	"Answer the index of the bin I show."

	^ bin
]

{ #category : 'accessing' }
BpRectanglePatch >> bin: anInteger [

	bin := anInteger
]

{ #category : 'accessing' }
BpRectanglePatch >> dataBounds [

	^ dataBounds
]

{ #category : 'accessing' }
BpRectanglePatch >> dataBounds: aRectangle [

	dataBounds := aRectangle
]

{ #category : 'layout' }
BpRectanglePatch >> pixelBoundsWith: aTransform [

	^ aTransform rectangleFor: dataBounds
]
