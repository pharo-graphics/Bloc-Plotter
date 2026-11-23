"
I am an axis of a `BpKiviat`: the name of a variable and the scale of its values. My shown limits are the values at the center and at the edge of the kiviat.

## Examples

```
BpKiviatAxis instancePrice
```

## Design Rationale

- Limits are in the order center, edge: limits such as `#( 60000 10000 )` put the low values at the edge, for variables where less is better.
- Equal steps from the center to the edge are equal differences on a linear scale and equal ratios on a logarithmic one. The rings are the same for all axes, so the values they show are the ones that are nice on my scale when my limits are computed, and may be any number when they are given.

## Usage

1. `BpKiviat>>axisNames:` creates me, and so does `BpKiviat>>addRow:` when the kiviat has no axis yet.
2. `limits:`, `scale:` and `tickFormatter:` configure me; each one rebuilds my kiviat.
3. My kiviat gives me my `shownLimits:` at each rebuild, asks me the places of the values of its rows (`fractionOf:`) and the labels of its rings (`labelsAt:`).

## Invariants and Assumptions

- Limits including 0 or negative values are ignored on a logarithmic scale.
"
Class {
	#name : 'BpKiviatAxis',
	#superclass : 'Object',
	#instVars : [
		'name',
		'kiviat',
		'limits',
		'scale',
		'tickFormatter',
		'shownLimits'
	],
	#category : 'Bloc-Plotter-Kiviat',
	#package : 'Bloc-Plotter',
	#tag : 'Kiviat'
}

{ #category : 'instances' }
BpKiviatAxis class >> instancePrice [
	"Answer an axis with the low values at the edge."

	<sampleInstance>
	^ BpKiviat instanceCars axisNamed: 'Price'
]

{ #category : 'instance creation' }
BpKiviatAxis class >> name: aString in: aKiviat [

	^ self new
		  setName: aString kiviat: aKiviat;
		  yourself
]

{ #category : 'scaling' }
BpKiviatAxis >> canShow: aCollectionOrNil [
	"Answer whether aCollectionOrNil holds limits for my scale: a logarithmic one has no place for 0 and the negative values."

	^ aCollectionOrNil isNotNil and: [ scale = #linear or: [ aCollectionOrNil allSatisfy: [ :each | each > 0 ] ] ]
]

{ #category : 'scaling' }
BpKiviatAxis >> fractionOf: aValue [
	"Answer where aValue is between my shown limits: 0 at the center, 1 at the edge."

	^ kiviat dataTransform fractionOf: aValue limits: shownLimits scale: scale
]

{ #category : 'accessing' }
BpKiviatAxis >> hasScaleOf: anAxis [
	"Answer whether I show the same values as anAxis at the same places."

	^ scale = anAxis scale and: [ shownLimits first = anAxis shownLimits first and: [ shownLimits last = anAxis shownLimits last ] ]
]

{ #category : 'initialization' }
BpKiviatAxis >> initialize [

	super initialize.
	scale := #linear.
	shownLimits := #( 0 1 )
]

{ #category : 'labels' }
BpKiviatAxis >> labelsAt: aCollectionOfFractions [
	"Answer the labels of my values at aCollectionOfFractions, written by my formatter, or rounded to the decimals they need."

	| values |
	values := aCollectionOfFractions collect: [ :each | self rounded: (self valueAt: each) ] as: Array.
	tickFormatter ifNotNil: [ ^ values collect: [ :each | (tickFormatter value: each) asString ] ].
	scale = #log ifTrue: [ ^ values collect: [ :each | (BpTickLocator labelsFor: { each }) first ] ].
	^ BpTickLocator labelsFor: values
]

{ #category : 'accessing' }
BpKiviatAxis >> limits [

	^ limits
]

{ #category : 'accessing' }
BpKiviatAxis >> limits: aCollectionOrNil [
	"Set the values at the center and at the edge (first and last of aCollectionOrNil), in this order: the low values are at the edge when the first one is the highest. Nil takes the limits of my kiviat."

	limits := aCollectionOrNil.
	kiviat rebuild
]

{ #category : 'scaling' }
BpKiviatAxis >> limitsCovering: aCollectionOfNumbers count: anInteger [
	"Answer limits covering aCollectionOfNumbers such that anInteger equal steps fall on nice values."

	^ scale = #log
		  ifTrue: [ self logLimitsCovering: (aCollectionOfNumbers select: [ :each | each > 0 ]) ]
		  ifFalse: [ self linearLimitsCovering: aCollectionOfNumbers count: anInteger ]
]

{ #category : 'scaling' }
BpKiviatAxis >> linearLimitsCovering: aCollectionOfNumbers count: anInteger [
	"Answer limits starting at 0, or at the lowest value rounded down when it is negative, and anInteger nice steps wide."

	| low high step start |
	aCollectionOfNumbers ifEmpty: [ ^ #( 0 1 ) ].
	low := 0 min: aCollectionOfNumbers min.
	high := aCollectionOfNumbers max.
	high > low ifFalse: [ high := low + 1 ].
	step := BpTickLocator stepAtLeast: high - low / anInteger.
	start := (low / step) floor * step.
	[ start + (anInteger * step) >= (high - (step * 1.0e-9)) ] whileFalse: [
		step := BpTickLocator stepAtLeast: step * 1.01.
		start := (low / step) floor * step ].
	^ {
		  start.
		  (start + (anInteger * step)) }
]

{ #category : 'scaling' }
BpKiviatAxis >> logLimitsCovering: aCollectionOfPositiveNumbers [
	"Answer the powers of ten around aCollectionOfPositiveNumbers."

	| low high |
	aCollectionOfPositiveNumbers ifEmpty: [ ^ #( 1 10 ) ].
	low := ((aCollectionOfPositiveNumbers min log: 10) + 1.0e-9) floor.
	high := ((aCollectionOfPositiveNumbers max log: 10) - 1.0e-9) ceiling.
	^ {
		  (10 raisedTo: low).
		  (10 raisedTo: (high max: low + 1)) }
]

{ #category : 'labels' }
BpKiviatAxis >> magnitudeFor: aValue [
	"Answer the number whose order of magnitude says how to round aValue: the length of my axis on a linear scale, aValue on a log scale."

	^ scale = #log
		  ifTrue: [ aValue ]
		  ifFalse: [ (shownLimits last - shownLimits first) abs ]
]

{ #category : 'accessing' }
BpKiviatAxis >> name [

	^ name
]

{ #category : 'labels' }
BpKiviatAxis >> rounded: aValue [
	"Answer aValue rounded to a hundredth of the order of magnitude of my axis."

	| magnitude |
	magnitude := self magnitudeFor: aValue.
	magnitude > 0 ifFalse: [ ^ aValue ].
	^ aValue roundTo: (10 raisedTo: ((magnitude log: 10) + 1.0e-9) floor - 2)
]

{ #category : 'accessing' }
BpKiviatAxis >> scale [

	^ scale
]

{ #category : 'accessing' }
BpKiviatAxis >> scale: aSymbol [
	"Set #linear or #log."

	(#( #linear #log ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown scale: ' , aSymbol printString ].
	scale := aSymbol.
	kiviat rebuild
]

{ #category : 'initialization' }
BpKiviatAxis >> setName: aString kiviat: aKiviat [

	name := aString.
	kiviat := aKiviat
]

{ #category : 'accessing' }
BpKiviatAxis >> shownLimits [
	"Answer the values currently shown at the center and at the edge."

	^ shownLimits
]

{ #category : 'accessing' }
BpKiviatAxis >> shownLimits: aCollection [

	shownLimits := aCollection
]

{ #category : 'accessing' }
BpKiviatAxis >> tickFormatter [

	^ tickFormatter
]

{ #category : 'accessing' }
BpKiviatAxis >> tickFormatter: aBlockOrNil [
	"Set a block answering the label of a value; nil prints the values."

	tickFormatter := aBlockOrNil.
	kiviat rebuild
]

{ #category : 'scaling' }
BpKiviatAxis >> valueAt: aFraction [
	"Answer the value at aFraction of the way from the center (0) to the edge (1)."

	| low high |
	scale = #log ifFalse: [ ^ shownLimits first + (aFraction * (shownLimits last - shownLimits first)) ].
	low := shownLimits first log: 10.
	high := shownLimits last log: 10.
	^ 10 raisedTo: low + (aFraction * (high - low))
]
