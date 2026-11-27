"
I am a palette of colors taken along a cubehelix, going from dark to light through several hues: printed in grey, the order of my colors stays visible. Each of my schemes holds 16 colors; `resizedTo:` and `resizedTo:lightFrom:to:` answer a palette of the same colors with another size.

## Examples

```
BpCubehelixPalette exampleCubehelix.
BpCubehelixPalette exampleGreyPrinting.
BpCubehelixPalette exampleChart
```

## Design Rationale

- I hold the helix (`BpCubehelix`) my colors were computed from, so any scheme can be asked in any size, while a `BpSequentialPalette` has a list of colors per size.
- The first colors of a scheme are close to black and to each other, and most schemes end with white. For the artists of a chart, ask for as many colors as there are artists and leave black and white out: `BpCubehelixPalette classic resizedTo: 5 lightFrom: 0.2 to: 0.8`.

## Usage

1. A scheme (`classic`, `perceptualRainbow`, `purple`, `jimSpecial`, `red`, `cubehelix1`, `cubehelix2`, `cubehelix3`) or `BpCubehelix>>palette` creates me. See `BpPalette` for the rest.

## Implementation Notes

- The settings of the schemes come from the Palettable project (https://jiffyclub.github.io/palettable/cubehelix/, BSD license, Copyright James R. A. Davenport and contributors). The colors computed from them are the ones it publishes.
- `cubehelix3` is so saturated that its colors are clipped: its steps of grey are not even, but they still go from dark to light.
"
Class {
	#name : 'BpCubehelixPalette',
	#superclass : 'BpEnumeratedPalette',
	#instVars : [
		'helix'
	],
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'schemes' }
BpCubehelixPalette class >> classic [

	^ self name: 'classic' helix: BpCubehelix new
]

{ #category : 'schemes' }
BpCubehelixPalette class >> cubehelix1 [

	^ self
		  name: 'cubehelix1'
		  start: 1.5
		  rotation: -1
		  saturation: 1.5
]

{ #category : 'schemes' }
BpCubehelixPalette class >> cubehelix2 [

	^ self
		  name: 'cubehelix2'
		  start: 2
		  rotation: 1
		  saturation: 1.5
]

{ #category : 'schemes' }
BpCubehelixPalette class >> cubehelix3 [

	^ self
		  name: 'cubehelix3'
		  start: 2
		  rotation: 1
		  saturation: 3
]

{ #category : 'examples' }
BpCubehelixPalette class >> exampleChart [
	"Show lines that can be told apart once printed in grey."

	<example>
	| figure chart |
	figure := BpFigure rows: 1 columns: 1.
	figure uniquePalette: self instanceFiveColors.
	chart := figure charts first.
	1 to: 5 do: [ :each | (chart addArtist: (BpLine x: (0 to: 10) y: ((0 to: 10) collect: [ :x | x * each ]))) label: ('times {1}' format: { each }) ].
	chart legend.
	^ figure show: 'Cubehelix colors'
]

{ #category : 'examples' }
BpCubehelixPalette class >> exampleCubehelix [
	"Show the cubehelix schemes of sixteen colors, and one of chosen settings."

	<example>
	^ self
		  demoOpen: {
			  self classic.
			  self perceptualRainbow.
			  self purple.
			  self jimSpecial.
			  self red.
			  self cubehelix1.
			  self cubehelix2.
			  self cubehelix3.
			  self instanceCustom }
		  title: 'Cubehelix palettes'
]

{ #category : 'examples' }
BpCubehelixPalette class >> exampleGreyPrinting [
	"Show palettes above their version in grey: cubehelix colors stay apart."

	<example>
	^ self
		  demoOpen: ({
			   self instanceClassic.
			   self instanceFiveColors.
			   BpQualitativePalette instanceTab10 } flatCollect: [ :each |
				   {
					   each.
					   (self greyVersionOf: each) } ])
		  title: 'Palettes printed in grey'
]

{ #category : 'private - demo' }
BpCubehelixPalette class >> greyVersionOf: aPalette [
	"Answer the palette of the colors of aPalette as they are printed in grey."

	^ BpEnumeratedPalette
		  name: aPalette name , ' (grey)'
		  colors: (aPalette colors collect: [ :each | Color gray: 0.3 * each red + (0.59 * each green) + (0.11 * each blue) ])
]

{ #category : 'instances' }
BpCubehelixPalette class >> instanceClassic [

	<sampleInstance>
	^ self classic
]

{ #category : 'instances' }
BpCubehelixPalette class >> instanceCustom [

	<sampleInstance>
	^ BpCubehelix instanceGreenToRed palette
]

{ #category : 'instances' }
BpCubehelixPalette class >> instanceFiveColors [
	"Answer five colors without black and white, for the artists of a chart."

	<sampleInstance>
	^ self classic resizedTo: 5 lightFrom: 0.2 to: 0.8
]

{ #category : 'schemes' }
BpCubehelixPalette class >> jimSpecial [

	^ self
		  name: 'jimSpecial'
		  start: 0.3
		  rotation: -0.5
		  saturation: 1.2
]

{ #category : 'instance creation' }
BpCubehelixPalette class >> name: aString helix: aCubehelix [
	"Answer the palette named aString of the colors of aCubehelix."

	^ self new
		  name: aString;
		  helix: aCubehelix;
		  yourself
]

{ #category : 'schemes' }
BpCubehelixPalette class >> name: aString start: aNumber rotation: aTurnCount saturation: aSaturation [

	^ self name: aString helix: (BpCubehelix new
		   start: aNumber;
		   rotation: aTurnCount;
		   saturation: aSaturation;
		   yourself)
]

{ #category : 'schemes' }
BpCubehelixPalette class >> perceptualRainbow [

	^ self name: 'perceptualRainbow' helix: (BpCubehelix new
		   hueFrom: 240 to: -300;
		   saturationFrom: 1 to: 2.5;
		   lightFrom: 0.3 to: 0.8;
		   gamma: 0.9;
		   yourself)
]

{ #category : 'schemes' }
BpCubehelixPalette class >> purple [

	^ self
		  name: 'purple'
		  start: 0
		  rotation: 0
		  saturation: 1.2
]

{ #category : 'schemes' }
BpCubehelixPalette class >> red [

	^ self
		  name: 'red'
		  start: 0
		  rotation: 0.5
		  saturation: 1.2
]

{ #category : 'accessing' }
BpCubehelixPalette class >> schemes [
	"Answer the selectors of my schemes."

	^ #( #classic #perceptualRainbow #purple #jimSpecial #red #cubehelix1 #cubehelix2 #cubehelix3 )
]

{ #category : 'accessing' }
BpCubehelixPalette >> helix: aCubehelix [

	helix := aCubehelix.
	self colors: helix colors
]

{ #category : 'accessing' }
BpCubehelixPalette >> resizedTo: anInteger [
	"Answer a palette of anInteger colors evenly spaced along my helix."

	^ self class name: name helix: (helix copy
		   size: anInteger;
		   yourself)
]

{ #category : 'accessing' }
BpCubehelixPalette >> resizedTo: anInteger lightFrom: aNumber to: anotherNumber [
	"Answer a palette of anInteger colors along my helix, whose brightness goes from aNumber to anotherNumber, between 0 (black) and 1 (white)."

	^ self class name: name helix: (helix copy
		   size: anInteger;
		   lightFrom: aNumber to: anotherNumber;
		   yourself)
]
