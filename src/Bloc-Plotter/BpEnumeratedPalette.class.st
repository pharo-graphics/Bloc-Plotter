"
I am a palette holding a list of colors. `colorAt:` takes an index counted from 1 and starts again at my first color after the last one, so I never run out of colors.

## Examples

```
BpEnumeratedPalette instanceThreeGreys
```

## Design Rationale

- My subclasses group the ready-made schemes by use: `BpQualitativePalette`, `BpSequentialPalette` and `BpDivergingPalette`. Their factories hold the data as red, green and blue triplets between 0 and 255 and build `Color` instances from it (`name:triplets:`).
- `name:colors:` makes a palette of any colors, without a subclass.
"
Class {
	#name : 'BpEnumeratedPalette',
	#superclass : 'BpPalette',
	#instVars : [
		'colors'
	],
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instances' }
BpEnumeratedPalette class >> instanceThreeGreys [

	<sampleInstance>
	^ self name: 'three greys' colors: {
		  (Color gray: 0.2).
		  (Color gray: 0.5).
		  (Color gray: 0.8) }
]

{ #category : 'instance creation' }
BpEnumeratedPalette class >> name: aString colors: someColors [

	^ self new
		  name: aString;
		  colors: someColors;
		  yourself
]

{ #category : 'instance creation' }
BpEnumeratedPalette class >> name: aString size: anInteger in: someTripletLists [
	"Answer the palette named aString of the one of someTripletLists that has anInteger colors."

	^ self name: aString triplets: (someTripletLists detect: [ :each | each size = anInteger ] ifNone: [
		   self error: ('The scheme {1} has no palette of {2} colors' format: {
			    aString.
			    anInteger }) ])
]

{ #category : 'instance creation' }
BpEnumeratedPalette class >> name: aString triplets: someTriplets [
	"Answer the palette named aString of the colors given as red, green and blue triplets between 0 and 255."

	^ self name: aString colors: (someTriplets collect: [ :each | self colorFromTriplet: each ])
]

{ #category : 'accessing' }
BpEnumeratedPalette class >> schemes [
	"Answer the selectors of my ready-made schemes."

	^ #(  )
]

{ #category : 'accessing' }
BpEnumeratedPalette >> colorAt: anIndex [
	"Answer my color at anIndex, counted from 1. Past my last color, I start again from the first one."

	^ colors at: anIndex - 1 \\ colors size + 1
]

{ #category : 'accessing' }
BpEnumeratedPalette >> colors [

	^ colors
]

{ #category : 'initialization' }
BpEnumeratedPalette >> colors: someColors [

	colors := someColors asArray
]

{ #category : 'accessing' }
BpEnumeratedPalette >> sampleColors [

	^ colors
]

{ #category : 'accessing' }
BpEnumeratedPalette >> size [

	^ colors size
]
