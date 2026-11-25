"
I let each chart of a figure have its own palette: I never change it. I am what a new figure uses (see `BpPaletteSource`).

## Examples

```
BpPersonalPalette instanceDefault
```

## Design Rationale

- `palette` raises an error: the charts may all have different palettes, so there is none to answer.
"
Class {
	#name : 'BpPersonalPalette',
	#superclass : 'BpPaletteSource',
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instances' }
BpPersonalPalette class >> instanceDefault [
	"Answer a source leaving each chart its own palette."

	<sampleInstance>
	^ self new
]

{ #category : 'palette' }
BpPersonalPalette >> givePaletteTo: aChart [
	"Leave aChart its own palette."

	
]

{ #category : 'palette' }
BpPersonalPalette >> palette [
	"There is no common palette to answer."

	^ self error: 'There is no common palette: each chart has its own'
]
