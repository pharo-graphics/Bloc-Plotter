"
I map numbers to colors: I place a number between two ends, on a linear or a logarithmic scale, and ask its color to a color map, a `BpInterpolatedPalette` or a block.

## Examples

```
BpColorScale instanceOrdersOfMagnitude
```

## Design Rationale

- The ends not given by `vMin:` and `vMax:` are taken from the numbers, all at once (`fitTo:`), before the colors are asked.
- A number beyond the ends has the color of the end. A number a logarithmic scale has no place for (0 and below) is transparent.

## Usage

1. `BpScatterPlot`, `BpHexbin`, `BpHeatmap` and `BpTreeMap` create me in `initialize` and keep me; their setters configure me.
2. They send me `fitTo:` with their numbers at each computation, then `colorFor:` for each one.
3. `BpColorBar` shows me: it asks my colors (`colorAt:`), and my ticks, their labels and their places (`ticksCount:`, `labelsFor:`, `fractionOf:`).
"
Class {
	#name : 'BpColorScale',
	#superclass : 'Object',
	#instVars : [
		'colorMap',
		'vMin',
		'vMax',
		'scale',
		'low',
		'high'
	],
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instances' }
BpColorScale class >> instanceOrdersOfMagnitude [
	"Answer a logarithmic scale from 1 to 1000."

	<sampleInstance>
	^ self new
		  scale: #log;
		  fitTo: #( 1 1000 );
		  yourself
]

{ #category : 'mapping' }
BpColorScale >> colorAt: aFraction [
	"Answer the color of my color map at aFraction, between 0 (its start) and 1 (its end)."

	^ colorMap isBlock
		  ifTrue: [ colorMap value: aFraction ]
		  ifFalse: [ colorMap colorAt: aFraction ]
]

{ #category : 'mapping' }
BpColorScale >> colorFor: aNumber [
	"Answer the color of aNumber, transparent when a logarithmic scale has no place for it."

	(self hasPlaceFor: aNumber) ifFalse: [ ^ Color transparent ].
	^ self colorAt: (self fractionOf: aNumber)
]

{ #category : 'accessing' }
BpColorScale >> colorMap: aPaletteOrBlock [
	"Set what maps the fractions to colors: a `BpInterpolatedPalette`, or a block from a fraction between 0 and 1 to a color."

	colorMap := aPaletteOrBlock
]

{ #category : 'mapping' }
BpColorScale >> fitTo: aCollectionOfNumbers [
	"Take the ends that were not given from aCollectionOfNumbers."

	| numbers |
	numbers := aCollectionOfNumbers select: [ :each | self hasPlaceFor: each ].
	low := vMin ifNil: [ numbers ifEmpty: [ 1 ] ifNotEmpty: [ numbers min ] ].
	high := vMax ifNil: [ numbers ifEmpty: [ 1 ] ifNotEmpty: [ numbers max ] ]
]

{ #category : 'mapping' }
BpColorScale >> fractionOf: aNumber [
	"Answer where aNumber is between my ends, clipped between 0 and 1."

	| start |
	high = low ifTrue: [ ^ 0 ].
	start := self scaled: low.
	^ (self scaled: aNumber) - start / ((self scaled: high) - start) min: 1 max: 0
]

{ #category : 'mapping' }
BpColorScale >> hasPlaceFor: aNumber [

	^ scale = #linear or: [ aNumber > 0 ]
]

{ #category : 'initialization' }
BpColorScale >> initialize [

	super initialize.
	colorMap := BpInterpolatedPalette viridis.
	scale := #linear.
	low := 0.
	high := 1
]

{ #category : 'mapping' }
BpColorScale >> labelsFor: aCollectionOfNumbers [
	"Answer the labels of ticks at aCollectionOfNumbers."

	^ scale = #log
		  ifTrue: [ BpTickLocator logLabelsFor: aCollectionOfNumbers ]
		  ifFalse: [ BpTickLocator labelsFor: aCollectionOfNumbers ]
]

{ #category : 'accessing' }
BpColorScale >> limits [
	"Answer the numbers mapped to the start and the end of the color map."

	^ {
		  low.
		  high }
]

{ #category : 'accessing' }
BpColorScale >> scale [

	^ scale
]

{ #category : 'accessing' }
BpColorScale >> scale: aSymbol [
	"Set #linear or #log."

	(#( #linear #log ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown scale: ' , aSymbol printString ].
	scale := aSymbol
]

{ #category : 'private' }
BpColorScale >> scaled: aNumber [

	^ scale = #log
		  ifTrue: [ aNumber log: 10 ]
		  ifFalse: [ aNumber ]
]

{ #category : 'mapping' }
BpColorScale >> ticksCount: anInteger [
	"Answer ticks between my ends: at most anInteger + 1 nice numbers, or the powers of ten on a logarithmic scale."

	^ scale = #log
		  ifTrue: [ BpTickLocator logTicksFrom: (low min: high) to: (low max: high) ]
		  ifFalse: [ BpTickLocator linearTicksFrom: (low min: high) to: (low max: high) count: anInteger ]
]

{ #category : 'accessing' }
BpColorScale >> vMax: aNumberOrNil [
	"Set the number mapped to the end of the color map; nil takes the largest one of the numbers given to fitTo:."

	vMax := aNumberOrNil
]

{ #category : 'accessing' }
BpColorScale >> vMin: aNumberOrNil [
	"Set the number mapped to the start of the color map; nil takes the smallest one of the numbers given to fitTo:."

	vMin := aNumberOrNil
]
