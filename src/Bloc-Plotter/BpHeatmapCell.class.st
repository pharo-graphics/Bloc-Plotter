"
I am a cell of a `BpHeatmap`: the rectangle showing the number of a `row` and a `column`, which may be written in me (`TBpLabeled`). See `BpPatch` for the life cycle.

## Examples

```
BpHeatmapCell instanceOfHarvest
```

## Usage

`BpHeatmap>>newCellAtRow:column:formatter:` creates me. Each layout hides my label when it does not fit in me.

## Implementation Notes

- My border is centered on my sides: it covers the seam an antialiased side would leave with the next cell.
"
Class {
	#name : 'BpHeatmapCell',
	#superclass : 'BpRectanglePatch',
	#traits : 'TBpLabeled',
	#classTraits : 'TBpLabeled classTrait',
	#instVars : [
		'row',
		'column'
	],
	#category : 'Bloc-Plotter-Heatmap',
	#package : 'Bloc-Plotter',
	#tag : 'Heatmap'
}

{ #category : 'instances' }
BpHeatmapCell class >> instanceBar [
	"Answer a bar of my kind: the first cell of a heatmap."

	<sampleInstance>
	^ self instanceOfHarvest
]

{ #category : 'instances' }
BpHeatmapCell class >> instanceOfHarvest [
	"Answer the first cell of a heatmap."

	<sampleInstance>
	^ (BpHeatmap instanceHarvest
		   showAmounts: true;
		   yourself) patches first
]

{ #category : 'accessing' }
BpHeatmapCell >> column [
	"Answer my column, counted from 1 on the left."

	^ column
]

{ #category : 'accessing' }
BpHeatmapCell >> column: anInteger [

	column := anInteger
]

{ #category : 'initialization' }
BpHeatmapCell >> initialize [

	super initialize.
	self outskirts: BlOutskirts centered
]

{ #category : 'layout' }
BpHeatmapCell >> measureWith: aTransform [
	"Compute my bounds, and hide my label when it does not fit in them."

	super measureWith: aTransform.
	label ifNotNil: [ self labelVisible: self labelExtent <= pixelBounds extent ]
]

{ #category : 'accessing' }
BpHeatmapCell >> row [
	"Answer my row, counted from 1 at the top."

	^ row
]

{ #category : 'accessing' }
BpHeatmapCell >> row: anInteger [

	row := anInteger
]
