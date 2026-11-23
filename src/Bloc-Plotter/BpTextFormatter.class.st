"
I format numbers the way pies expect: C printf strings for `BpPie>>autoPct:` (`printf:with:`, e.g. `'%1.1f%%'`) and Python replacement fields for `BpPie>>addLabels:` (`format:absVal:frac:`, e.g. `'{absval:d}\n{frac:.1%}'`, where the two characters `\n` stand for a line break).

## Examples

```
BpTextFormatter exampleFormats
```

## Usage

I have no instances: `BpPieLabelSet class>>labels:distance:` and `BpPieLabelSet class>>percent:distance:` use my class-side methods.

## Invariants and Assumptions

- I only know the part of these formats that pies use: the conversions `d`, `f` with a precision, and `%`, and the fields `absval` and `frac`. An unknown field raises `KeyNotFound`.
"
Class {
	#name : 'BpTextFormatter',
	#superclass : 'Object',
	#category : 'Bloc-Plotter-Support',
	#package : 'Bloc-Plotter',
	#tag : 'Support'
}

{ #category : 'examples' }
BpTextFormatter class >> exampleFormats [
	"Show the two format families: printf strings (`BpPie>>autoPct:`) applied to a percentage, and Python replacement fields (`BpPie>>addLabels:`) applied to a value and its fraction. Answers the formatted strings."

	<example>
	^ {
		  (self printf: '%1.1f%%' with: 15).
		  (self printf: '%.0f%%' with: 30.4).
		  (self format: '{absval:.1f}' absVal: 36 frac: 0.45).
		  (self format: '{frac:.1%}' absVal: 36 frac: 0.45).
		  (self format: '{absval:d}\n{frac:.1%}' absVal: 36 frac: 0.45) } inspect
]

{ #category : 'formatting' }
BpTextFormatter class >> format: aPattern absVal: anAbsoluteValue frac: aFraction [
	"Answer aPattern where each Python replacement field {absval} or {frac}, with an optional format spec (d, .Nf, .N%), is replaced by the corresponding value. The two characters \n stand for a line break. This is the format of the labels of `BpPie>>addLabels:`."

	| in values |
	values := Dictionary new
		          at: 'absval' put: anAbsoluteValue;
		          at: 'frac' put: aFraction;
		          yourself.
	in := (aPattern copyReplaceAll: '\n' with: String cr) readStream.
	^ String streamContents: [ :out |
		  [ in atEnd ] whileFalse: [
			  | char |
			  char := in next.
			  char = ${
				  ifTrue: [ self printField: (in upTo: $}) from: values on: out ]
				  ifFalse: [ out nextPut: char ] ] ]
]

{ #category : 'private' }
BpTextFormatter class >> precisionIn: aSpec [
	"Answer the number of decimals given after the dot of aSpec, or 6 (the C and Python default) when there is none."

	| digits |
	digits := aSpec copyAfter: $..
	^ digits ifEmpty: [ 6 ] ifNotEmpty: [ digits asNumber ]
]

{ #category : 'private' }
BpTextFormatter class >> print: aNumber conversion: aCharacter precision: anInteger [
	"Answer aNumber printed following the conversion character of a printf or Python format spec: d (rounded integer), f (fixed decimals) or % (percent of a fraction)."

	aCharacter = $d ifTrue: [ ^ aNumber rounded printString ].
	aCharacter = $f ifTrue: [ ^ aNumber printShowingDecimalPlaces: anInteger ].
	aCharacter = $% ifTrue: [ ^ (aNumber * 100 printShowingDecimalPlaces: anInteger) , '%' ].
	^ aNumber printString
]

{ #category : 'private' }
BpTextFormatter class >> printConversionFrom: aStream of: aNumber on: anOutStream [
	"Read a printf conversion (after its percent sign) from aStream and print aNumber with it on anOutStream."

	| spec conversion |
	spec := String streamContents: [ :s |
		        [ aStream atEnd not and: [ '0123456789.' includes: aStream peek ] ] whileTrue: [ s nextPut: aStream next ] ].
	conversion := aStream atEnd
		              ifTrue: [ $% ]
		              ifFalse: [ aStream next ].
	conversion = $% ifTrue: [ ^ anOutStream nextPut: $% ].
	anOutStream nextPutAll: (self print: aNumber conversion: conversion precision: (self precisionIn: spec))
]

{ #category : 'private' }
BpTextFormatter class >> printField: aField from: aDictionary on: anOutStream [
	"Print on anOutStream the value named by aField (name, optionally followed by a colon and a format spec) taken from aDictionary."

	| value spec |
	value := aDictionary at: (aField copyUpTo: $:).
	spec := aField copyAfter: $:.
	anOutStream nextPutAll: (spec
		 ifEmpty: [ value printString ]
		 ifNotEmpty: [ self print: value conversion: spec last precision: (self precisionIn: spec allButLast) ])
]

{ #category : 'formatting' }
BpTextFormatter class >> printf: aPattern with: aNumber [
	"Answer aPattern where each C printf conversion (%f with an optional width and precision, %d, and %% for a percent sign) is replaced by aNumber. This is the format of `BpPie>>autoPct:`."

	| in |
	in := aPattern readStream.
	^ String streamContents: [ :out |
		  [ in atEnd ] whileFalse: [
			  | char |
			  char := in next.
			  char = $%
				  ifTrue: [ self printConversionFrom: in of: aNumber on: out ]
				  ifFalse: [ out nextPut: char ] ] ]
]
