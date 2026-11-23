"
I compute the colors of a cubehelix: a helix around the line of the greys, from black to white in the cube of the colors. Its brightness increases evenly while its hue turns.

## Examples

```
BpCubehelix instanceGreenToRed
```

## Design Rationale

- I am apart from `BpCubehelixPalette` because I am configured by several messages, while a palette does not change once created.

## Usage

1. `BpCubehelixPalette` creates me for its schemes, and I can be created to choose other colors.
2. `start:` and `rotation:`, or `hueFrom:to:`, set the hues, `saturation:` how far the colors are from the greys, `lightFrom:to:` and `gamma:` the brightness, `size:` the number of colors.
3. `palette` answers a palette of my colors. `BpCubehelixPalette>>resizedTo:` configures a copy of me.

## Implementation Notes

- The formulas are the ones of D. A. Green (2011), A colour scheme for the display of astronomical intensity images, Bulletin of the Astronomical Society of India 39, 289. The coefficients keep the brightness 0.30 red + 0.59 green + 0.11 blue at the one of the grey.
- The levels of red, green and blue are truncated, not rounded, to answer the colors of the published tables.

## Invariants and Assumptions

- A brightness is between 0 and 1.
- The brightness is even as long as no color is clipped, which happens with high saturations.
"
Class {
	#name : 'BpCubehelix',
	#superclass : 'Object',
	#instVars : [
		'start',
		'rotation',
		'gamma',
		'saturationRange',
		'lightRange',
		'size'
	],
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instances' }
BpCubehelix class >> instanceGreenToRed [
	"Answer a helix of eight colors, without black and white."

	<sampleInstance>
	^ self new
		  start: 2;
		  rotation: 0.6;
		  lightFrom: 0.2 to: 0.8;
		  size: 8;
		  yourself
]

{ #category : 'private' }
BpCubehelix >> colorAtLight: aFraction saturation: aNumber [
	"Answer the color at aFraction of the way from black to white."

	| light angle amplitude |
	light := aFraction raisedTo: gamma.
	angle := Float twoPi * (start / 3 + (rotation * aFraction)).
	amplitude := aNumber * light * (1 - light) / 2.
	^ Color
		  r: (self levelOf: light + (amplitude * (1.78277 * angle sin - (0.14861 * angle cos))))
		  g: (self levelOf: light - (amplitude * (0.29227 * angle cos + (0.90649 * angle sin))))
		  b: (self levelOf: light + (amplitude * 1.97294 * angle cos))
		  range: 255
]

{ #category : 'computing' }
BpCubehelix >> colors [
	"Answer my colors, evenly spaced along the helix."

	^ (1 to: size) collect: [ :each |
		  self colorAtLight: (self valueAt: each in: lightRange) saturation: (self valueAt: each in: saturationRange) ]
]

{ #category : 'accessing' }
BpCubehelix >> gamma [

	^ gamma
]

{ #category : 'accessing' }
BpCubehelix >> gamma: aNumber [
	"Set the exponent of the brightness: above 1 the colors are darker, below 1 lighter."

	gamma := aNumber
]

{ #category : 'accessing' }
BpCubehelix >> hueFrom: aStartAngle to: anEndAngle [
	"Set my start and rotation from the hues at both ends, in degrees."

	start := 3 * (aStartAngle / 360.0 - 1).
	rotation := anEndAngle / 360.0 - (start / 3) - 1
]

{ #category : 'initialization' }
BpCubehelix >> initialize [

	super initialize.
	start := 0.5.
	rotation := -1.5.
	gamma := 1.
	saturationRange := 1.2 -> 1.2.
	lightRange := 0 -> 1.
	size := 16
]

{ #category : 'private' }
BpCubehelix >> levelOf: aNumber [
	"Answer the integer between 0 and 255 of the fraction aNumber, clipped: saturated colors can leave the color space."

	^ (aNumber * 255.0 min: 255 max: 0) truncated
]

{ #category : 'accessing' }
BpCubehelix >> lightFrom: aNumber to: anotherNumber [
	"Set the brightness of my first and last colors, between 0 (black) and 1 (white)."

	lightRange := aNumber -> anotherNumber
]

{ #category : 'computing' }
BpCubehelix >> palette [
	"Answer a palette of my colors."

	^ BpCubehelixPalette name: 'cubehelix' helix: self
]

{ #category : 'accessing' }
BpCubehelix >> rotation [

	^ rotation
]

{ #category : 'accessing' }
BpCubehelix >> rotation: aNumber [
	"Set the number of turns through red, green and blue, from black to white; negative turns go through blue, green and red."

	rotation := aNumber
]

{ #category : 'accessing' }
BpCubehelix >> saturation: aNumber [
	"Set how far the colors are from the greys; 0 gives greys."

	self saturationFrom: aNumber to: aNumber
]

{ #category : 'accessing' }
BpCubehelix >> saturationFrom: aNumber to: anotherNumber [
	"Set the saturation of my first and last colors."

	saturationRange := aNumber -> anotherNumber
]

{ #category : 'accessing' }
BpCubehelix >> size [

	^ size
]

{ #category : 'accessing' }
BpCubehelix >> size: anInteger [
	"Set the number of colors (16 by default)."

	size := anInteger
]

{ #category : 'accessing' }
BpCubehelix >> start [

	^ start
]

{ #category : 'accessing' }
BpCubehelix >> start: aNumber [
	"Set the hue at the dark end: 0 is blue, 1 red, 2 green."

	start := aNumber
]

{ #category : 'private' }
BpCubehelix >> valueAt: anIndex in: anAssociation [
	"Answer the value for the color at anIndex, anAssociation holding the values for the first and the last color."

	| fraction |
	fraction := anIndex - 1 / (size - 1 max: 1).
	^ 1 - fraction * anAssociation key + (fraction * anAssociation value)
]
