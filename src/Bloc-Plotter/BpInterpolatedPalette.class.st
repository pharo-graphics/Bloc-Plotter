"
I am a palette for continuous values: `colorAt:` takes a fraction between 0 and 1 and mixes the two anchors around it. `BpColorScale` maps numbers through me, with `viridis` by default.

## Examples

```
BpInterpolatedPalette exampleFifteenColors
```

## Implementation Notes

- `viridis` and `inferno` mix eleven samples of the original maps of 256 colors, so a color in between can differ slightly from the original.

## Invariants and Assumptions

- The anchors are evenly spaced, and there are at least two of them.
- Fractions below 0 or above 1 are clipped.
"
Class {
	#name : 'BpInterpolatedPalette',
	#superclass : 'BpPalette',
	#instVars : [
		'anchors'
	],
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'examples' }
BpInterpolatedPalette class >> exampleFifteenColors [
	"Show fifteen colors of viridis, evenly spaced."

	<example>
	^ self
		  demoOpen: { (BpEnumeratedPalette name: 'viridis' colors: (self instanceViridis sampleColors: 15)) }
		  title: 'Fifteen colors of viridis'
]

{ #category : 'instance creation' }
BpInterpolatedPalette class >> inferno [
	"Answer the inferno palette, from black to pale yellow through purple, red and orange, interpolated between eleven samples."

	^ self
		  name: 'inferno'
		  anchors:
			  (#( #( 0 0 4 ) #( 22 11 57 ) #( 66 10 104 ) #( 106 23 110 ) #( 147 38 103 ) #( 188 55 84 ) #( 221 81 58 ) #( 243 120 25 )
			      #( 252 165 10 ) #( 246 215 70 ) #( 252 255 164 ) ) collect: [ :each | self colorFromTriplet: each ])
]

{ #category : 'instances' }
BpInterpolatedPalette class >> instanceInferno [

	<sampleInstance>
	^ self inferno
]

{ #category : 'instances' }
BpInterpolatedPalette class >> instanceViridis [

	<sampleInstance>
	^ self viridis
]

{ #category : 'instance creation' }
BpInterpolatedPalette class >> name: aString anchors: someColors [

	^ self new
		  name: aString;
		  anchors: someColors;
		  yourself
]

{ #category : 'instance creation' }
BpInterpolatedPalette class >> viridis [
	"Answer the viridis palette, from dark purple to yellow, interpolated between eleven samples."

	^ self
		  name: 'viridis'
		  anchors:
			  (#( #( 68 1 84 ) #( 72 36 117 ) #( 65 68 135 ) #( 53 95 141 ) #( 42 120 142 ) #( 33 145 140 ) #( 34 168 132 ) #( 68 191 112 )
			      #( 122 209 81 ) #( 189 223 38 ) #( 253 231 37 ) ) collect: [ :each | self colorFromTriplet: each ])
]

{ #category : 'accessing' }
BpInterpolatedPalette >> anchors [

	^ anchors
]

{ #category : 'initialization' }
BpInterpolatedPalette >> anchors: someColors [

	anchors := someColors asArray
]

{ #category : 'accessing' }
BpInterpolatedPalette >> colorAt: aFraction [
	"Answer my color at aFraction, between 0 (my first anchor) and 1 (my last one): a mix of the two anchors around it. Fractions outside are clipped."

	| position index |
	position := (aFraction min: 1 max: 0) * (anchors size - 1).
	index := position floor + 1 min: anchors size - 1.
	^ (anchors at: index) mixed: 1 - (position - (index - 1)) with: (anchors at: index + 1)
]

{ #category : 'accessing' }
BpInterpolatedPalette >> sampleColors [

	^ self sampleColors: 21
]

{ #category : 'accessing' }
BpInterpolatedPalette >> sampleColors: anInteger [
	"Answer anInteger (at least two) of my colors, evenly spaced from my first to my last anchor."

	^ (0 to: anInteger - 1) collect: [ :each | self colorAt: each / (anInteger - 1) ]
]
