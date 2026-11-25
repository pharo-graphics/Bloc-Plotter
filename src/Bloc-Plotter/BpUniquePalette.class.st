"
I give the same palette to all the charts of a figure (see `BpPaletteSource`).

## Examples

```
BpUniquePalette instanceDefault
```

## Design Rationale

- A chart that already has my palette is left as it is: giving a palette to a chart recomputes its artists. So a chart that is given the palette of its figure before its artists is computed once.

## Usage

- Immutable: another palette is another instance (`BpFigure>>uniquePalette:`).
"
Class {
	#name : 'BpUniquePalette',
	#superclass : 'BpPaletteSource',
	#instVars : [
		'palette'
	],
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instances' }
BpUniquePalette class >> instanceDefault [
	"Answer a source giving the palette set1 to all the charts."

	<sampleInstance>
	^ self on: BpQualitativePalette set1
]

{ #category : 'instance creation' }
BpUniquePalette class >> on: anEnumeratedPalette [
	"Answer a source giving anEnumeratedPalette to all the charts."

	^ self new
		  setPalette: anEnumeratedPalette;
		  yourself
]

{ #category : 'palette' }
BpUniquePalette >> givePaletteTo: aChart [
	"Give my palette to aChart. A chart that already has it is left as it is, since giving a palette recomputes its artists."

	aChart palette == palette ifFalse: [ aChart palette: palette ]
]

{ #category : 'palette' }
BpUniquePalette >> palette [

	^ palette
]

{ #category : 'private - initialization' }
BpUniquePalette >> setPalette: anEnumeratedPalette [

	palette := anEnumeratedPalette
]
