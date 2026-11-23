"
I am a color bar: a strip of the colors of a `BpColorScale` with ticks telling their numbers. I tell the numbers that my `source`, a `BpHeatmap`, a `BpHexbin`, a `BpScatterPlot` or a `BpTreeMap`, shows by colors.

## Examples

```
BpColorBar exampleColorBars.
BpTreeMap exampleColorBar
```

## Design Rationale

- I only ask my source whether it shows numbers by colors (`showsNumbersByColors`), its `colorScale`, and how it shows a color (`colorOf:`): an artist with an alpha has a transparent bar, as its patches.
- I am an element of my own rather than a part of an artist, so that I can be put in a chart or anywhere else.
- The largest number is at the top.

## Usage

1. `BpChart>>addColorBarFor:` creates me with `on:`, keeps me in `colorBars` and places me on the right of its plot area, as high as it. It sends me `refresh` at each rebuild, so I follow the changes of my artist.
2. Out of a chart, `on:` gives a bar 200 pixels high. Send me `refresh` after changing the source.

- I am mutable: each setter or `refresh` replaces my ticks.

## Implementation Notes

- The strip is a gradient of a hundred colors: the steps of a block used as color map are shown within 1%.
- A hexbin with `bins:` shows steps, so my numbers are the ones of the steps.
- Not supported yet: horizontal bars, and bars shared by several charts.

## Invariants and Assumptions

- My source shows numbers by colors: `on:` raises an error otherwise.
"
Class {
	#name : 'BpColorBar',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'source',
		'strip',
		'labelElement',
		'ticks',
		'thickness',
		'tickCount',
		'tickLocations',
		'tickFormatter'
	],
	#category : 'Bloc-Plotter-ColorBar',
	#package : 'Bloc-Plotter',
	#tag : 'ColorBar'
}

{ #category : 'examples' }
BpColorBar class >> exampleColorBars [
	"Show the color bars of a heatmap, a hexbin on a log scale, a transparent scatter plot and a polar chart, with their settings."

	<example>
	^ BpFigure instanceColorBars show: 'Color bars'
]

{ #category : 'instances' }
BpColorBar class >> instanceOfHarvest [
	"Answer the color bar of a heatmap, out of its chart."

	<sampleInstance>
	^ (self on: BpHeatmap instanceHarvest)
		  label: 'harvest (tonnes per year)';
		  yourself
]

{ #category : 'instance creation' }
BpColorBar class >> on: aSource [
	"Answer a color bar of the numbers aSource shows by colors. aSource answers `showsNumbersByColors`, `colorScale` and `colorOf:` (see `BpArtist`)."

	aSource showsNumbersByColors ifFalse: [ ^ self error: aSource printString , ' shows no numbers by colors' ].
	^ self new
		  source: aSource;
		  yourself
]

{ #category : 'private - building' }
BpColorBar >> colorScale [

	^ source colorScale
]

{ #category : 'layout' }
BpColorBar >> fittingWidth [
	"Answer the width of my strip, my ticks and my label. They must be measured."

	| width |
	width := thickness + 6 + (ticks inject: 0 into: [ :max :each | max max: each label measuredExtent x ]).
	^ self label isEmpty
		  ifTrue: [ width ]
		  ifFalse: [ width + 5 + labelElement measuredExtent y ]
]

{ #category : 'initialization' }
BpColorBar >> initialize [

	super initialize.
	thickness := 14.
	tickCount := 5.
	ticks := #(  ).
	strip := BlElement new
		         border: (BlBorder paint: Color black width: 1);
		         yourself.
	labelElement := BlTextElement new
		                labelMeasurement;
		                transformDo: [ :t | t rotateBy: -90 ];
		                yourself.
	self
		label: '';
		layout: BpColorBarLayout new;
		clipChildren: false;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical exact: 200 ];
		addChildren: {
			strip.
			labelElement }
]

{ #category : 'accessing' }
BpColorBar >> label [

	^ labelElement text asString
]

{ #category : 'accessing' }
BpColorBar >> label: aString [
	"Set what my numbers are, written along me from bottom to top."

	labelElement text: (aString asRopedText fontSize: 11)
]

{ #category : 'layout' }
BpColorBar >> labelBoundsIn: anExtent [
	"Answer the bounds of my label before its rotation around its center: along my right side, halfway up."

	| size |
	size := labelElement measuredExtent.
	^ anExtent x - (size y / 2) @ (anExtent y / 2) - (size / 2) extent: size
]

{ #category : 'accessing' }
BpColorBar >> labelElement [

	^ labelElement
]

{ #category : 'private - building' }
BpColorBar >> newPaint [
	"Answer a gradient of a hundred colors of my color scale, its end at the top."

	^ (BlLinearGradientPaint direction: 0 @ 1)
		  stops: ((0 to: 100) collect: [ :each | each / 100 -> (source colorOf: (self colorScale colorAt: 1 - (each / 100))) ]);
		  yourself
]

{ #category : 'private - building' }
BpColorBar >> newTickLocations [

	| limits |
	tickLocations ifNil: [ ^ self colorScale ticksCount: tickCount ].
	limits := self colorScale limits.
	^ tickLocations select: [ :each | each between: limits min and: limits max ]
]

{ #category : 'private - building' }
BpColorBar >> newTicks [

	| locations labels |
	locations := self newTickLocations asArray.
	labels := tickFormatter
		          ifNil: [ self colorScale labelsFor: locations ]
		          ifNotNil: [ locations collect: [ :each | (tickFormatter value: each) asString ] ].
	^ locations with: labels asArray collect: [ :each :text | BpColorBarTick axis: #y location: each text: text ]
]

{ #category : 'updating' }
BpColorBar >> refresh [
	"Show the colors and numbers of my source again, after it or my settings changed."

	strip background: self newPaint.
	ticks do: [ :each | self removeChildren: each elements ].
	ticks := self newTicks.
	ticks do: [ :each | self addChildren: each elements ]
]

{ #category : 'accessing' }
BpColorBar >> source [
	"Answer what shows the numbers: an artist or a tree map."

	^ source
]

{ #category : 'accessing' }
BpColorBar >> source: aSource [

	source := aSource.
	self refresh
]

{ #category : 'accessing' }
BpColorBar >> strip [
	"Answer the element painted with my colors."

	^ strip
]

{ #category : 'accessing' }
BpColorBar >> thickness [

	^ thickness
]

{ #category : 'accessing' }
BpColorBar >> thickness: aNumber [
	"Set the width of my strip of colors in pixels (14 by default)."

	thickness := aNumber.
	self requestLayout
]

{ #category : 'accessing' }
BpColorBar >> tickCount: anInteger [
	"Set the largest number of intervals between my ticks (5 by default)."

	tickCount := anInteger.
	self refresh
]

{ #category : 'accessing' }
BpColorBar >> tickFormatter: aBlockOrNil [
	"Set a block answering the label of a tick from its number; nil prints the numbers."

	tickFormatter := aBlockOrNil.
	self refresh
]

{ #category : 'accessing' }
BpColorBar >> tickLocations: aCollectionOfNumbersOrNil [
	"Put my ticks at aCollectionOfNumbersOrNil, those out of my limits being left out; nil chooses them again."

	tickLocations := aCollectionOfNumbersOrNil.
	self refresh
]

{ #category : 'accessing' }
BpColorBar >> ticks [

	^ ticks
]

{ #category : 'layout' }
BpColorBar >> yOf: aNumber in: aHeight [
	"Answer where aNumber is along me when I am aHeight high."

	^ 1 - (self colorScale fractionOf: aNumber) * aHeight
]
