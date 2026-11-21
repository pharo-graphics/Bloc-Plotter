"
I am the legend of a `BpAxes`: one row per labeled dataset, a swatch drawn like its patches followed by its label, as matplotlib `Axes.legend`.

## Examples

```
BpLegend exampleTwoEntries
```

## Usage

1. `BpAxes>>newLegend` creates me with `entries:` once `BpAxes>>legend` was sent, from the `legendEntries` of its artists.
2. `BpPlotArea>>legend:` shows me, and the axes replace me at each rebuild.
"
Class {
	#name : 'BpLegend',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'instance creation' }
BpLegend class >> entries: aCollectionOfAssociations [

	^ self new
		  entries: aCollectionOfAssociations;
		  yourself
]

{ #category : 'examples' }
BpLegend class >> exampleTwoEntries [

	<sampleInstance>
	^ self entries: (#( 'red' 'tan' ) collect: [ :each |
		   each -> (BlElement new
			    background: (BpColors named: each);
			    extent: 20 @ 10;
			    yourself) ])
]

{ #category : 'accessing' }
BpLegend >> entries: aCollectionOfAssociations [
	"Show one row per association: its value, a swatch element, followed by its key, the label."

	self removeChildren.
	aCollectionOfAssociations do: [ :each | self addChild: (self rowFor: each key swatch: each value) ]
]

{ #category : 'initialization' }
BpLegend >> initialize [

	super initialize.
	self
		layout: (BlLinearLayout vertical cellSpacing: 3);
		padding: (BlInsets all: 5);
		background: (Color white alpha: 0.8);
		border: (BlBorder paint: (Color gray: 0.8) width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ]
]

{ #category : 'accessing' }
BpLegend >> labels [

	^ self children collect: [ :each | each children second text asString ]
]

{ #category : 'accessing' }
BpLegend >> rowFor: aString swatch: anElement [

	^ BlElement new
		  layout: (BlLinearLayout horizontal cellSpacing: 6) alignCenterLeft;
		  constraintsDo: [ :c |
			  c horizontal fitContent.
			  c vertical fitContent ];
		  addChildren: {
			  anElement.
			  (BlTextElement new
				   labelMeasurement;
				   text: (aString asRopedText fontSize: 11);
				   yourself) };
		  yourself
]
