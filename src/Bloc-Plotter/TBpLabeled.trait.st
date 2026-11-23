"
I give an element a label it shows only when there is room for it, in black or white, whichever is the easiest to read on the color of the element.

## Design Rationale

- A label is hidden, not cut: a part of a number would be read as another number.
- `Color>>contrastingBlackAndWhiteColor` is not used: it chooses white up to a luminance of 0.5, while black has the highest contrast above 0.179.

## Usage

1. `BpHeatmap` and `BpTreeMap` give a label to the elements that use me (`BpHeatmapCell` and `BpTreeMapBox`), once painted, with `showCenteredLabel:` or `showLabel:placedBy:`.
2. During its measure pass, the element compares `labelExtent` with its room and sends itself `labelVisible:`. Hiding an element does not request a layout, so it is safe then.
"
Trait {
	#name : 'TBpLabeled',
	#instVars : [
		'label'
	],
	#category : 'Bloc-Plotter-Chart',
	#package : 'Bloc-Plotter',
	#tag : 'Chart'
}

{ #category : 'labeling' }
TBpLabeled >> label [
	"Answer the element of my label, nil without one."

	^ label
]

{ #category : 'labeling' }
TBpLabeled >> labelExtent [
	"Measure my label and answer the room it needs."

	label measure: BlExtentMeasurementSpec unspecified.
	^ label measuredExtent
]

{ #category : 'labeling' }
TBpLabeled >> labelVisible: aBoolean [

	label visibility: (aBoolean
		 ifTrue: [ BlVisibility visible ]
		 ifFalse: [ BlVisibility hidden ])
]

{ #category : 'labeling' }
TBpLabeled >> readableColorOn: aColor [
	"Answer black or white, the one with the highest contrast on aColor: both have the same contrast on a luminance of 0.179 (WCAG 2)."

	^ (aColor isTransparent or: [ aColor relativeLuminance > 0.179 ])
		  ifTrue: [ Color black ]
		  ifFalse: [ Color white ]
]

{ #category : 'labeling' }
TBpLabeled >> showCenteredLabel: aString [
	"Write aString at my center."

	self showLabel: aString placedBy: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ]
]

{ #category : 'labeling' }
TBpLabeled >> showLabel: aString placedBy: aBlock [
	"Write aString in me, in black or white, the one that can be read on my background, which must be set. aBlock receives the constraints of my label in a `BlFrameLayout`."

	label := BlTextElement new
		         labelMeasurement;
		         text: (aString asRopedText
			          fontSize: 11;
			          foreground: (self readableColorOn: self background paint color));
		         constraintsDo: [ :c | aBlock value: c ];
		         preventMeAndChildrenMouseEvents;
		         yourself.
	self
		layout: BlFrameLayout new;
		addChild: label
]
