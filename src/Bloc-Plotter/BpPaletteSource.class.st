"
I represent what a `BpFigure` does with the palettes of its charts: either it gives them all the same one, or it lets each of them have its own. I am abstract: `BpUniquePalette` and `BpPersonalPalette` are the two cases.

## Examples

```
BpPaletteSource instanceDefault
```

## Design Rationale

- A figure asks me what to do instead of testing a flag or a missing palette: it always holds one of my instances, and sends `givePaletteTo:` without knowing which.

## Usage

1. `BpFigure>>initialize` and `BpFigure>>chartPersonalPalette` create a `BpPersonalPalette`, `BpFigure>>uniquePalette:` creates a `BpUniquePalette`.
2. The figure keeps me until it is configured again.
3. The figure sends me `givePaletteTo:` for each chart it creates (`rows:columns:chartClass:`) or is given (`chartAtRow:column:put:`), and `palette` to answer its own.
"
Class {
	#name : 'BpPaletteSource',
	#superclass : 'Object',
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instances' }
BpPaletteSource class >> instanceDefault [
	"Answer the palette source of a new figure."

	<sampleInstance>
	^ BpPersonalPalette instanceDefault
]

{ #category : 'palette' }
BpPaletteSource >> givePaletteTo: aChart [
	"Give a palette to aChart, or leave it its own."

	^ self subclassResponsibility
]

{ #category : 'palette' }
BpPaletteSource >> palette [
	"Answer the palette of all the charts. Raise an error when there is no common one."

	^ self subclassResponsibility
]
