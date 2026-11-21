"
I am an artist of a `BpAxes`: something drawn from data, such as a histogram (`BpHistogram`), a scatter plot (`BpScatterplot`) or a line plot (`BpLine`), as matplotlib artists. I compute what my data show and build patches (`BpPatch`) that my axes place in their plot area; `whenPatch:do:` adds an interaction handler to all my patches.

## Examples

```
BpArtist scriptArtistsInOneAxes
```

## Design Rationale

- I only know what my axes need: my patches (`allPatches`), my legend entries, the values autoscaling must not go past (`stickyValuesOn:`), the axes I put on a log scale (`logAxes`) and how many colors of the color cycle I take (`colorCount`), and whether my patches are drawn above the grid (`isAboveGrid`). The axes ignore the kind of plot.
- Each change recomputes everything (`refresh`): subclasses define `compute` and `newPatches`, and new patches replace the previous ones. Handlers given to `whenPatch:do:` are kept and given to each new patch.
- Style settings take one value or one per dataset or point (`setting:at:`), as matplotlib arguments.

## Usage

1. A plotting method of `BpAxes` (`hist:`, `scatterX:y:`, `plotX:y:`) creates the artist, and `BpAxes>>addArtist:` gives it its axes and its colors of the color cycle (`defaultColors:`).
2. Each setter calls `refresh`, which tells the axes (`BpAxes>>artistChanged:`); they rebuild their limits, patches, legend and ticks.

- I am mutable: keep me, not my patches, which are replaced at each change.
"
Class {
	#name : 'BpArtist',
	#superclass : 'Object',
	#instVars : [
		'axes',
		'patchHandlers',
		'patches',
		'defaultColors',
		'alpha',
		'label'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'accessing' }
BpArtist class >> pixelsPerPoint [
	"Answer how many pixels a typographic point (1/72 inch) takes: matplotlib draws its default figures at 100 dots per inch."

	^ 100 / 72
]

{ #category : 'script' }
BpArtist class >> scriptArtistsInOneAxes [
	"Show two kinds of artists in the same axes: a histogram of normal samples and, above it, a scatter plot of their counts; each takes the next color of the cycle and the axes scale to cover both."

	<example>
	| random samples axes figure histogram |
	random := Random seed: 19680801.
	samples := (1 to: 500) collect: [ :each | random nextNormal ].
	figure := BpFigure new.
	axes := figure axes first.
	histogram := (axes hist: samples)
		             bins: 15;
		             yourself.
	(axes
		 scatterX: ((1 to: 15) collect: [ :index | (histogram binEdges at: index) + (histogram binEdges at: index + 1) / 2 ])
		 y: histogram counts)
		marker: 'D';
		s: 50;
		label: 'counts'.
	axes
		title: 'BpHistogram and BpScatterplot';
		legend;
		grid: true.
	^ figure show: 'Artists'
]

{ #category : 'interaction' }
BpArtist >> addHandler: anAssociation to: aPatch [

	aPatch addEventHandler: (BlEventHandler
		 on: anAssociation key
		 do: [ :event | anAssociation value cull: event cull: aPatch ])
]

{ #category : 'axes' }
BpArtist >> allPatches [
	"Answer all my patches, as a flat collection."

	^ patches
]

{ #category : 'accessing - style' }
BpArtist >> alpha: aNumberOrNil [
	"Set the opacity of my patches, between 0 and 1 (nil for opaque)."

	alpha := aNumberOrNil.
	self refresh
]

{ #category : 'axes' }
BpArtist >> axes [

	^ axes
]

{ #category : 'axes' }
BpArtist >> axes: anAxes [

	axes := anAxes
]

{ #category : 'axes' }
BpArtist >> colorCount [
	"Answer how many colors of the color cycle of my axes I take."

	^ 1
]

{ #category : 'private - style' }
BpArtist >> colorOf: aColorOrName [
	"Answer the color aColorOrName names (a `Color` or a matplotlib name), made transparent by my alpha."

	| color |
	color := aColorOrName isColor
		         ifTrue: [ aColorOrName ]
		         ifFalse: [ BpColors named: aColorOrName ].
	^ alpha ifNil: [ color ] ifNotNil: [ color alpha: alpha ]
]

{ #category : 'private - computing' }
BpArtist >> compute [
	"Compute what my patches show from my data and settings."

	self subclassResponsibility
]

{ #category : 'axes' }
BpArtist >> defaultColors: aCollectionOfColors [
	"Set the colors my axes give me from their color cycle, one per color I need (colorCount)."

	defaultColors := aCollectionOfColors.
	self refresh
]

{ #category : 'initialization' }
BpArtist >> initialize [

	super initialize.
	patchHandlers := OrderedCollection new.
	patches := #(  ).
	defaultColors := BpColors tab10
]

{ #category : 'axes' }
BpArtist >> isAboveGrid [
	"Answer whether my patches are drawn above the grid. matplotlib draws the grid above patches and collections (bars, scatter points) and below lines."

	^ false
]

{ #category : 'accessing - style' }
BpArtist >> label: aStringOrCollection [
	"Set the label shown in the legend: one string, or one per dataset for a histogram of several datasets."

	label := aStringOrCollection.
	self refresh
]

{ #category : 'axes' }
BpArtist >> legendEntries [
	"Answer my legend entries: associations from a label to a swatch element."

	^ #(  )
]

{ #category : 'axes' }
BpArtist >> logAxes [
	"Answer the axes (#x, #y) I put on a log scale."

	^ #(  )
]

{ #category : 'private - computing' }
BpArtist >> newPatches [
	"Answer new patches showing my last computation."

	^ self subclassResponsibility
]

{ #category : 'accessing' }
BpArtist >> patches [
	"Answer the patches I currently draw."

	^ patches
]

{ #category : 'private - computing' }
BpArtist >> refresh [
	"Recompute my data and my patches, and let my axes show them."

	self compute.
	patches := self newPatches.
	axes ifNotNil: [ axes artistChanged: self ]
]

{ #category : 'private - style' }
BpArtist >> setting: aValueOrCollection at: anIndex [
	"Answer a style setting for one dataset or point: the setting itself, or its element at anIndex when it is a collection (one per dataset or point)."

	^ (aValueOrCollection isCollection and: [ aValueOrCollection isString not ])
		  ifTrue: [ aValueOrCollection at: anIndex ]
		  ifFalse: [ aValueOrCollection ]
]

{ #category : 'axes' }
BpArtist >> stickyValuesOn: anAxis [
	"Answer the values autoscaling margins must not go past on anAxis (#x or #y), as matplotlib sticky edges."

	^ #(  )
]

{ #category : 'interaction' }
BpArtist >> whenPatch: anEventClass do: aBlock [
	"Evaluate aBlock with the event and the patch each time one of my patches receives an event of anEventClass. The handler is kept when my patches are rebuilt."

	patchHandlers add: anEventClass -> aBlock.
	self allPatches do: [ :each | self addHandler: anEventClass -> aBlock to: each ]
]
