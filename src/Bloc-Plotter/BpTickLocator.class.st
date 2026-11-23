"
I choose where the ticks of an axis go and how they are labeled: multiples of a nice step (1, 2, 2.5 or 5 times a power of ten) on linear axes, powers of ten on log axes, and labels printed with just the decimals the ticks need.

## Examples

```
BpTickLocator exampleTicks
```

## Usage

I have no instances: `BpAxes>>newTicksOn:` and `BpAxes>>defaultLabelsFor:on:` use my class-side methods.
"
Class {
	#name : 'BpTickLocator',
	#superclass : 'Object',
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'ticks' }
BpTickLocator class >> clean: aNumber [
	"Answer aNumber as an integer when it is one, otherwise as a float."

	^ aNumber isInteger
		  ifTrue: [ aNumber ]
		  ifFalse: [ aNumber asFloat ]
]

{ #category : 'labels' }
BpTickLocator class >> decimalsFor: aCollectionOfTicks [
	"Answer the smallest number of decimals that prints every tick exactly."

	^ (0 to: 10)
		  detect: [ :decimals |
			  | scale |
			  scale := 10 raisedTo: decimals.
			  aCollectionOfTicks allSatisfy: [ :each | (each * scale - (each * scale) rounded) abs < 1.0e-6 ] ]
		  ifNone: [ 10 ]
]

{ #category : 'examples' }
BpTickLocator class >> exampleTicks [
	"Answer the ticks and labels chosen for a few ranges: nice steps for linear axes, powers of ten for log axes."

	<example>
	^ {
		  (self labelsFor: (self linearTicksFrom: 93.5 to: 306.5 count: 6)).
		  (self labelsFor: (self linearTicksFrom: 0 to: 0.027 count: 8)).
		  (self logLabelsFor: (self logTicksFrom: 0.5 to: 2000)) } inspect
]

{ #category : 'labels' }
BpTickLocator class >> labelsFor: aCollectionOfTicks [
	"Answer the labels of linear ticks, all printed with the number of decimals their step needs."

	| decimals |
	decimals := self decimalsFor: aCollectionOfTicks.
	^ aCollectionOfTicks asArray collect: [ :each |
		  decimals = 0
			  ifTrue: [ each rounded printString ]
			  ifFalse: [ each printShowingDecimalPlaces: decimals ] ]
]

{ #category : 'ticks' }
BpTickLocator class >> linearTicksFrom: aMinimum to: aMaximum count: anInteger [
	"Answer at most anInteger + 1 ticks between aMinimum and aMaximum, multiples of a nice step (1, 2, 2.5 or 5 times a power of ten)."

	| raw scale step first last |
	aMaximum > aMinimum ifFalse: [ ^ { aMinimum } ].
	raw := aMaximum - aMinimum / anInteger.
	scale := 10 raisedTo: (raw log: 10) floor.
	step := ({
		         1.
		         2.
		         (5 / 2).
		         5.
		         10 } collect: [ :each | each * scale ]) detect: [ :each | each >= (raw * (1 - 1.0e-9)) ].
	first := (aMinimum / step - 1.0e-9) ceiling.
	last := (aMaximum / step + 1.0e-9) floor.
	^ (first to: last) collect: [ :each | self clean: each * step ]
]

{ #category : 'labels' }
BpTickLocator class >> logLabelsFor: aCollectionOfTicks [
	"Answer the labels of powers of ten: 10 with the exponent written in superscript."

	^ aCollectionOfTicks asArray collect: [ :each |
		  '10' , ((each log: 10) rounded printString collect: [ :char | self superscriptOf: char ]) ]
]

{ #category : 'ticks' }
BpTickLocator class >> logTicksFrom: aMinimum to: aMaximum [
	"Answer the powers of ten between aMinimum and aMaximum, both positive."

	^ (((aMinimum log: 10) - 1.0e-9) ceiling to: ((aMaximum log: 10) + 1.0e-9) floor) collect: [ :each | 10 raisedTo: each ]
]

{ #category : 'labels' }
BpTickLocator class >> superscriptOf: aCharacter [

	^ aCharacter = $-
		  ifTrue: [ Character value: 16r207B ]
		  ifFalse: [ '⁰¹²³⁴⁵⁶⁷⁸⁹' at: aCharacter digitValue + 1 ]
]
