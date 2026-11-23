"
I am an artist of a `BpAxes`: something drawn from data, such as a histogram (`BpHistogram`), a scatter plot (`BpScatterPlot`), a line plot (`BpLine`), a box plot (`BpBoxPlot`), a bar plot (`BpBarPlot`), a stem plot (`BpStemPlot`) the area between two curves (`BpFillBetween`) or a stack plot (`BpStackPlot`). I compute what my data show and build patches (`BpPatch`) that my axes place in their plot area; `whenPatch:do:` adds an interaction handler to all my patches.

## Examples

```
BpArtist scriptArtistsInOneAxes
```

## Design Rationale

- I only know what my axes need: my patches (`allPatches`), my legend entries, the values autoscaling must cover besides my patches (`requiredValuesOn:`) and must not go past (`stickyValuesOn:`), the ticks I place myself (`managedTicksOn:`), the axes I put on a log scale (`logAxes`), how many colors of the color cycle I take (`colorCount`), and whether my patches are drawn above the grid (`isAboveGrid`). The axes ignore the kind of plot.
- Each change recomputes everything (`refresh`): subclasses define `compute` and `newPatches`, and new patches replace the previous ones. Handlers given to `whenPatch:do:` are kept and given to each new patch.
- Style settings take one value or one per dataset or point (`setting:at:`).
- My Live inspector pane (`TBpLiveInspection`) shows the figure of my axes, or a new figure holding me when I have no axes yet.

## Usage

1. A plotting method of `BpAxes` (`hist:`, `scatterX:y:`, `plotX:y:`, `boxPlot:`, `barX:height:`, `barhY:width:`, `stem:`, `stemLocations:heads:`, `fillBetweenX:y1:y2:`, `fillBetweenY:x1:x2:`, `stackPlotX:ys:`) creates the artist, and `BpAxes>>addArtist:` gives it its axes and its colors of the color cycle (`defaultColors:`).
2. Each setter calls `refresh`, which tells the axes (`BpAxes>>artistChanged:`); they rebuild their limits, patches, legend and ticks.

- I am mutable: keep me, not my patches, which are replaced at each change.
"
Class {
	#name : 'BpArtist',
	#superclass : 'Object',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
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

{ #category : 'private - demo' }
BpArtist class >> arangeFrom: aNumber to: anotherNumber by: aStep [
	"Answer the numbers from aNumber by aStep, below anotherNumber (excluded), as numpy arange, to write gallery examples."

	^ (0 to: (anotherNumber - aNumber / aStep) ceiling - 1) collect: [ :index | aNumber + (index * aStep) ]
]

{ #category : 'constants' }
BpArtist class >> dashPatterns [
	"Answer the dash pattern of each line style in points for a line one point wide."

	^ Dictionary new
		  at: #solid put: #(  );
		  at: #dashed put: #( 3.7 1.6 );
		  at: #dashdot put: #( 6.4 1.6 1 1.6 );
		  at: #dotted put: #( 1 1.65 );
		  yourself
]

{ #category : 'constants' }
BpArtist class >> lineStyleNames [
	"Answer the line style of each line style string."

	^ Dictionary new
		  at: '-' put: #solid;
		  at: '--' put: #dashed;
		  at: '-.' put: #dashdot;
		  at: ':' put: #dotted;
		  at: 'solid' put: #solid;
		  at: 'dashed' put: #dashed;
		  at: 'dashdot' put: #dashdot;
		  at: 'dotted' put: #dotted;
		  at: 'None' put: #none;
		  at: 'none' put: #none;
		  at: '' put: #none;
		  at: ' ' put: #none;
		  yourself
]

{ #category : 'constants' }
BpArtist class >> lineStyleOf: aSymbolOrString [
	"Answer the line style #solid, #dashed, #dashdot, #dotted or #none named by aSymbolOrString, a symbol or a string ('-', '--', '-.', ':', 'None', ...)."

	^ self dashPatterns
		  at: aSymbolOrString asSymbol
		  ifPresent: [ :pattern | aSymbolOrString asSymbol ]
		  ifAbsent: [
		  self lineStyleNames
			  at: aSymbolOrString asString
			  ifAbsent: [ self error: 'Unknown line style: ' , aSymbolOrString printString ] ]
]

{ #category : 'private - demo' }
BpArtist class >> linspaceFrom: aNumber to: anotherNumber count: anInteger [
	"Answer anInteger numbers evenly spaced from aNumber to anotherNumber included, as numpy linspace, to write gallery examples."

	anInteger = 1 ifTrue: [ ^ { aNumber } ].
	^ (0 to: anInteger - 1) collect: [ :index | aNumber + (index * (anotherNumber - aNumber) / (anInteger - 1)) ]
]

{ #category : 'accessing' }
BpArtist class >> pixelsPerPoint [
	"Answer how many pixels a typographic point (1/72 inch) takes: figures are drawn at 100 dots per inch."

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
		title: 'BpHistogram and BpScatterPlot';
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
	"Answer the color aColorOrName names (a `Color` or a name known by `BpColors`), made transparent by my alpha."

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
	"Answer whether my patches are drawn above the grid: the patches of bars and scatter points are drawn below it, lines above it."

	^ false
]

{ #category : 'private - style' }
BpArtist >> isColorName: aString [
	"Answer whether aString is a color name known by BpColors ('tan', 'C1', 'tab:red'), rather than a format string."

	^ [
		  BpColors named: aString.
		  true ]
		  on: Error
		  do: [ false ]
]

{ #category : 'private - style' }
BpArtist >> isMany: aValue [
	"Answer whether aValue gives one value per dataset, point or item rather than one for all: a collection other than a string."

	^ aValue isCollection and: [ aValue isString not ]
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

{ #category : 'inspector extensions' }
BpArtist >> liveElement [
	"Answer the figure showing me. When I have no axes yet, I am added to the axes of a new figure."

	| figure |
	axes ifNotNil: [ ^ axes liveElement ].
	figure := BpFigure new.
	figure axes first addArtist: self.
	^ figure
]

{ #category : 'axes' }
BpArtist >> logAxes [
	"Answer the axes (#x, #y) I put on a log scale."

	^ #(  )
]

{ #category : 'axes' }
BpArtist >> managedTicksOn: anAxis [
	"Answer the ticks I place on anAxis, as location -> label associations, or nil to let my axes choose them."

	^ nil
]

{ #category : 'private - computing' }
BpArtist >> newPatches [
	"Answer new patches showing my last computation."

	^ self subclassResponsibility
]

{ #category : 'private - style' }
BpArtist >> paintOf: aColorOrName [
	"Answer the color of aColorOrName with my alpha, transparent for 'none'."

	(aColorOrName isNil or: [ aColorOrName = 'none' ]) ifTrue: [ ^ Color transparent ].
	^ self colorOf: aColorOrName
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

{ #category : 'axes' }
BpArtist >> requiredValuesOn: anAxis [
	"Answer values on anAxis (#x or #y) that autoscaling must cover besides my patches."

	^ #(  )
]

{ #category : 'private - style' }
BpArtist >> setting: aValueOrCollection at: anIndex [
	"Answer a style setting for one dataset or point: the setting itself, or its element at anIndex when it is a collection (one per dataset or point)."

	^ (self isMany: aValueOrCollection)
		  ifTrue: [ aValueOrCollection at: anIndex ]
		  ifFalse: [ aValueOrCollection ]
]

{ #category : 'axes' }
BpArtist >> stickyValuesOn: anAxis [
	"Answer the values autoscaling margins must not go past on anAxis (#x or #y)."

	^ #(  )
]

{ #category : 'private - style' }
BpArtist >> strokeColor: aColor width: aNumberOfPoints style: aLineStyle [
	"Answer the stroke of a line of aColor, aNumberOfPoints wide, in aLineStyle (#solid, #dashed, #dashdot or #dotted): the dashes scale with the width, solid lines have projecting caps and dashed ones butt caps."

	| width builder |
	width := aNumberOfPoints * self class pixelsPerPoint.
	builder := BlBorder builder
		           paint: aColor;
		           width: width;
		           joinRound;
		           yourself.
	aLineStyle = #solid
		ifTrue: [ builder capSquare ]
		ifFalse: [
			builder
				capButt;
				dashArray: ((self class dashPatterns at: aLineStyle) collect: [ :each | each * width ]) ].
	^ builder build
]

{ #category : 'interaction' }
BpArtist >> whenPatch: anEventClass do: aBlock [
	"Evaluate aBlock with the event and the patch each time one of my patches receives an event of anEventClass. The handler is kept when my patches are rebuilt."

	patchHandlers add: anEventClass -> aBlock.
	self allPatches do: [ :each | self addHandler: anEventClass -> aBlock to: each ]
]
