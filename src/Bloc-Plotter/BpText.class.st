"
I am a text of a plot on one or several lines: each line break of my text starts a new line, centered under the previous one. A `BpAxes` shows its title with me, so a title can be written on two lines.

## Examples

```
BpText exampleTwoLines
```

## Design Rationale

- `BlTextElement` draws a single line, so I show one `BlTextElement` per line in a vertical linear layout, each keeping the attributes (font size, color) of its part of my text.
- I do not receive mouse events, so a click on me reaches the element under me.

## Usage

1. `BpAxes>>initialize` creates me as its title element; `BpAxes>>title:` sets my text. `BpPieText`, my subclass, places pie labels.
2. `text:` replaces my lines: I am mutable, and my size follows my text.
"
Class {
	#name : 'BpText',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'text'
	],
	#category : 'Bloc-Plotter-Text',
	#package : 'Bloc-Plotter',
	#tag : 'Text'
}

{ #category : 'examples' }
BpText class >> exampleTwoLines [
	"Answer a text of two centered lines."

	<sampleInstance>
	^ self new
		  text: ((String cr join: #( 'change outlier' 'point symbols' )) asRopedText fontSize: 14);
		  yourself
]

{ #category : 'initialization' }
BpText >> initialize [

	super initialize.
	text := '' asRopedText.
	self
		layout: BlLinearLayout vertical alignCenter;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		preventMeAndChildrenMouseEvents
]

{ #category : 'private - building' }
BpText >> lineElementFor: aBlText from: aStart to: anEnd [

	^ BlTextElement new
		  labelMeasurement;
		  text: (anEnd < aStart
			   ifTrue: [ '' asRopedText ]
			   ifFalse: [ aBlText from: aStart to: anEnd ]);
		  yourself
]

{ #category : 'private - building' }
BpText >> linesOf: aBlText [
	"Answer a text element for each line of aBlText, keeping its attributes."

	| lines start string |
	string := aBlText asString.
	lines := OrderedCollection new.
	start := 1.
	string withIndexDo: [ :char :index |
		char = Character cr ifTrue: [
			lines add: (self lineElementFor: aBlText from: start to: index - 1).
			start := index + 1 ] ].
	lines add: (self lineElementFor: aBlText from: start to: string size).
	^ lines
]

{ #category : 'accessing' }
BpText >> text [

	^ text
]

{ #category : 'accessing' }
BpText >> text: aBlText [
	"Show aBlText, one line per line break, each line centered."

	text := aBlText.
	self removeChildren.
	self addChildren: (self linesOf: aBlText) asArray
]
