"
I am the inside of a `BpAxes`: the white rectangle framed by the spines, where the patches of the artists, the grid lines and the legend are shown, clipped to my bounds (`showChildren`). From bottom to top: the patches of bars and scatter points, the grid lines, the patches of lines (`BpArtist>>isAboveGrid`), then the legend, as matplotlib z-orders. My `BpPlotAreaLayout` places the patches where their data are.

## Examples

```
BpPlotArea exampleOfHistogram
```

## Usage

1. `BpAxes>>initialize` creates me and gives me its `BpDataTransform`.
2. `BpAxes>>rebuild` gives me the patches of its artists (`patches:`), its legend (`legend:`) and its grid lines (`gridLines:`), replacing the previous ones.
"
Class {
	#name : 'BpPlotArea',
	#superclass : 'BlElement',
	#instVars : [
		'transform',
		'patches',
		'legend',
		'gridLines'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'examples' }
BpPlotArea class >> exampleOfHistogram [

	<sampleInstance>
	^ BpAxes exampleHistogram plotArea
]

{ #category : 'accessing' }
BpPlotArea >> dataTransform [

	^ transform
]

{ #category : 'accessing' }
BpPlotArea >> dataTransform: aDataTransform [

	transform := aDataTransform
]

{ #category : 'accessing' }
BpPlotArea >> gridLines [

	^ gridLines
]

{ #category : 'accessing' }
BpPlotArea >> gridLines: aCollectionOfGridLines [
	"Show aCollectionOfGridLines instead of my current ones, above the patches as in matplotlib."

	gridLines := aCollectionOfGridLines asArray.
	self showChildren
]

{ #category : 'initialization' }
BpPlotArea >> initialize [

	super initialize.
	patches := #(  ).
	gridLines := #(  ).
	self
		layout: BpPlotAreaLayout new;
		background: Color white;
		border: (BlBorder paint: Color black width: 1);
		clipChildren: true
]

{ #category : 'accessing' }
BpPlotArea >> legend [

	^ legend
]

{ #category : 'accessing' }
BpPlotArea >> legend: aLegendOrNil [

	legend := aLegendOrNil.
	self showChildren
]

{ #category : 'accessing' }
BpPlotArea >> patches [

	^ patches
]

{ #category : 'accessing' }
BpPlotArea >> patches: aCollectionOfPatches [
	"Show aCollectionOfPatches instead of my current patches."

	patches := aCollectionOfPatches asArray.
	self showChildren
]

{ #category : 'private - children' }
BpPlotArea >> showChildren [
	"Show the patches drawn below the grid, my grid lines, the patches drawn above it (lines), then my legend above them all."

	| isAbove |
	isAbove := [ :each | each artist isNotNil and: [ each artist isAboveGrid ] ].
	self removeChildren.
	self addChildren: (patches reject: isAbove) , gridLines , (patches select: isAbove).
	legend ifNotNil: [ self addChild: legend ]
]
