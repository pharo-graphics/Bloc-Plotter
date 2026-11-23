"
I am a named source of colors. The charts and pies take their colors from palettes instead of naming colors one by one, so changing the palette of a `BpChart` (`palette:`) changes the colors of all its artists together. `colorAt:` answers one of my colors.

## Examples

```
BpPalette examplePalettes
```

## Design Rationale

- A palette answers `Color` instances and nothing else: there are no color names to resolve.
- My two subclasses read the argument of `colorAt:` differently. A `BpEnumeratedPalette` holds a list of colors and takes an index, for things that are counted (the artists of a chart, the wedges of a pie). A `BpInterpolatedPalette` takes a fraction between 0 and 1, for values on a continuous scale.

## Usage

1. The factory methods of my subclasses create palettes, for example `BpQualitativePalette class>>tab10` or `BpSequentialPalette class>>blues:`. `BpPalette class>>default` answers the one used when none is given.
2. `BpFigure` and `BpChart` hold an enumerated palette (`palette`, `palette:`), the default one at first. A figure gives its palette to all its charts.
3. `BpChart>>addArtist:` takes the next colors of the palette for the artist it adds (`nextColors:`). `BpChart>>palette:` gives colors again to the artists already added. Artists with fixed colors of the palette ask `BpArtist>>paletteColorAt:`.
4. `BpPie>>palette:` gives the colors of an enumerated palette to the wedges. `BpScatterPlot>>colorMap:` and `BpHexbin>>colorMap:` take an interpolated palette.

- Once created a palette does not change, so several charts can share it.
"
Class {
	#name : 'BpPalette',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'accessing' }
BpPalette class >> colorFromTriplet: aTriplet [
	"Answer the color of aTriplet, its red, green and blue between 0 and 255."

	^ Color
		  r: aTriplet first
		  g: aTriplet second
		  b: aTriplet third
		  range: 255
]

{ #category : 'accessing' }
BpPalette class >> default [
	"Answer the palette of the charts, and of the artists and pies that are not given any."

	^ BpQualitativePalette tab10
]

{ #category : 'private - demo' }
BpPalette class >> demoOpen: aCollectionOfPalettes title: aString [
	"Open a space showing each palette on a row."

	| space |
	space := BlSpace new.
	space
		title: aString;
		extent: 480 @ (aCollectionOfPalettes size * 18 + 20).
	space root
		layout: (BlLinearLayout vertical cellSpacing: 3);
		padding: (BlInsets all: 8);
		addChildren: (aCollectionOfPalettes collect: [ :each | self demoRowOf: each ]).
	space show.
	^ space
]

{ #category : 'private - demo' }
BpPalette class >> demoRowOf: aPalette [
	"Answer a row with the name of aPalette and a swatch per sample color."

	| label swatches |
	label := BlTextElement new
		         text: (aPalette name asRopedText fontSize: 11);
		         width: 110;
		         yourself.
	swatches := aPalette sampleColors collect: [ :each |
		            BlElement new
			            background: each;
			            extent: 18 @ 14;
			            yourself ].
	^ BlElement new
		  layout: BlLinearLayout horizontal;
		  constraintsDo: [ :c |
			  c horizontal fitContent.
			  c vertical fitContent ];
		  addChild: label;
		  addChildren: swatches;
		  yourself
]

{ #category : 'examples' }
BpPalette class >> examplePalettes [
	"Show a palette of each kind: qualitative, sequential, diverging and interpolated."

	<example>
	^ self
		  demoOpen: {
			  BpQualitativePalette instanceTab10.
			  BpSequentialPalette instanceBlues.
			  BpDivergingPalette instanceRdbu.
			  BpInterpolatedPalette instanceViridis }
		  title: 'Palettes'
]

{ #category : 'accessing' }
BpPalette >> colorAt: aNumber [
	"Answer my color at aNumber: an index counted from 1 in an enumerated palette, a fraction between 0 and 1 in an interpolated one."

	^ self subclassResponsibility
]

{ #category : 'accessing' }
BpPalette >> name [

	^ name
]

{ #category : 'initialization' }
BpPalette >> name: aString [

	name := aString
]

{ #category : 'printing' }
BpPalette >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: ' (';
		print: name;
		nextPut: $)
]

{ #category : 'accessing' }
BpPalette >> sampleColors [
	"Answer colors that show what I look like."

	^ self subclassResponsibility
]
