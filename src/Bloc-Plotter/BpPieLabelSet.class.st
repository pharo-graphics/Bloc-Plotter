"
I am a set of texts of a `BpPie`, one per wedge, at the same distance from the center and with the same style. I am what `BpPie>>addLabels:` adds, and also how the pie shows its `labels` and `autoPct` percentages.

## Examples

```
BpPieLabelSet instancePercents
```

## Usage

1. `BpPie>>addLabels:distance:rotate:textStyle:` creates me with `labels:distance:` and keeps me; `BpPie>>allLabelSets` creates the sets of its labels (`labels:distance:`) and percentages (`percent:distance:`) at each rebuild.
2. At each rebuild the pie asks me `textsFor:` its wedges, and I answer a new `BpPieText` for each.

- `labels:distance:` takes a collection of strings, a format string using `{absval}` and `{frac}`, or a block receiving the wedge; `percent:distance:` takes a printf string or a block receiving the percentage. `BpTextFormatter` formats both.
"
Class {
	#name : 'BpPieLabelSet',
	#superclass : 'Object',
	#instVars : [
		'textBlock',
		'distance',
		'rotate',
		'textStyle'
	],
	#category : 'Bloc-Plotter-Pie',
	#package : 'Bloc-Plotter',
	#tag : 'Pie'
}

{ #category : 'instances' }
BpPieLabelSet class >> instancePercents [
	"Answer a label set showing the percentage of each wedge with one decimal, at 0.7 times the radius."

	<sampleInstance>
	^ self labels: '{frac:.1%}' distance: 0.7
]

{ #category : 'instance creation' }
BpPieLabelSet class >> labels: aSource distance: aNumber [
	"Answer a label set as `BpPie>>addLabels:` adds. aSource is a collection of strings (one per wedge), a format string using {absval} and {frac} (see BpTextFormatter class>>format:absVal:frac:), or a block receiving the wedge."

	| block |
	block := aSource isString
		         ifTrue: [ [ :wedge | BpTextFormatter format: aSource absVal: wedge amount frac: wedge fraction ] ]
		         ifFalse: [
			         aSource isCollection
				         ifTrue: [ [ :wedge | aSource at: wedge index ] ]
				         ifFalse: [ aSource ] ].
	^ self new
		  textBlock: block;
		  distance: aNumber;
		  yourself
]

{ #category : 'instance creation' }
BpPieLabelSet class >> percent: aSource distance: aNumber [
	"Answer a label set showing the percentage of each wedge (see `BpPie>>autoPct:`). aSource is a printf format string (see BpTextFormatter class>>printf:with:) or a block receiving the percentage."

	| block |
	block := aSource isString
		         ifTrue: [ [ :wedge | BpTextFormatter printf: aSource with: wedge fraction * 100 ] ]
		         ifFalse: [ [ :wedge | aSource value: wedge fraction * 100 ] ].
	^ self new
		  textBlock: block;
		  distance: aNumber;
		  yourself
]

{ #category : 'accessing' }
BpPieLabelSet >> distance [

	^ distance
]

{ #category : 'accessing' }
BpPieLabelSet >> distance: aNumber [

	distance := aNumber
]

{ #category : 'initialization' }
BpPieLabelSet >> initialize [

	super initialize.
	distance := 0.6.
	rotate := false
]

{ #category : 'accessing' }
BpPieLabelSet >> rotate [

	^ rotate
]

{ #category : 'accessing' }
BpPieLabelSet >> rotate: aBoolean [

	rotate := aBoolean
]

{ #category : 'accessing' }
BpPieLabelSet >> textBlock: aBlock [
	"aBlock answers the string shown for the wedge it receives."

	textBlock := aBlock
]

{ #category : 'building' }
BpPieLabelSet >> textFor: aWedge [
	"Answer a new text element showing my string for aWedge."

	| text |
	text := (textBlock value: aWedge) asString asRopedText.
	textStyle ifNotNil: [ textStyle value: text ].
	^ BpPieText new
		  text: text;
		  wedge: aWedge distance: distance rotate: rotate;
		  yourself
]

{ #category : 'accessing' }
BpPieLabelSet >> textStyle [

	^ textStyle
]

{ #category : 'accessing' }
BpPieLabelSet >> textStyle: aBlockOrNil [
	"aBlockOrNil receives the BlText of each of my texts, to set its font, size or color."

	textStyle := aBlockOrNil
]

{ #category : 'building' }
BpPieLabelSet >> textsFor: aCollectionOfWedges [

	^ aCollectionOfWedges collect: [ :each | self textFor: each ]
]
