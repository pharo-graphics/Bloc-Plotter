"
I am a violin plot of a `BpChart`: for each dataset, a body showing the estimated density of its values on both sides of its position, with lines at its extrema and, on demand, at its mean, median and quantiles. Where a `BpBoxPlot` summarizes a dataset by its quartiles, I show the shape of its distribution, such as two groups of values. A `BpViolinStatistics` per dataset computes what I draw; I draw it with `BpPolygonPatch`es that `parts` gives by role.

## Examples

```
BpViolinPlot examplePlotType.
BpViolinPlot exampleViolinPlotBasics.
BpViolinPlot exampleSplitViolins.
BpViolinPlot exampleInteraction
```

## Design Rationale

- Each body is scaled on its own: its highest density is half its width (`widths:`, 0.5 by default) away from its position. Bodies show shapes, not densities that could be compared across violins.
- The body spans only the values of the dataset, from its minimum to its maximum, even though the density estimate goes on beyond them.
- `side: #low` or `#high` draws only half of each violin, so that two `BpViolinPlot`s at the same positions compare two groups side by side.
- All violins share one color of the palette of their chart: the bodies are filled with it at 0.3 opacity (`alpha:` changes it) and the lines are drawn with it opaque. `faceColor:` and `lineColor:` take one color, or one per violin.
- The extrema are shown by default, the means, medians and quantiles are not: `showExtrema:`, `showMeans:`, `showMedians:` and `quantiles:` choose them. `quantiles:` takes fractions for all violins, or one collection of fractions per violin.

## Usage

1. `BpViolinPlot class>>x:` (positions 1, 2, 3, ...) and `BpViolinPlot class>>x:positions:` create me with my data, and `BpChart>>addArtist:` adds me to a chart (see `BpArtist`), which gives me one color of its palette.
2. Each setter recomputes my statistics and rebuilds my patches.
3. My chart reads my patches for autoscaling and my `legendEntries` (a rectangle filled as my bodies).

## Implementation Notes

- My patches are drawn bodies first, then the lines: means, maxima, minima, bars, medians and quantiles.
- I have one slot and setter per option, hence many slots.
- Not supported yet: a callable bandwidth, and ticks named after the datasets as a box plot has.

## Invariants and Assumptions

- There is one position and, when widths are a collection, one width per dataset; set the data before them.
- Each dataset has at least two different values, otherwise its density cannot be estimated.
"
Class {
	#name : 'BpViolinPlot',
	#superclass : 'BpArtist',
	#instVars : [
		'datasets',
		'statistics',
		'positions',
		'widths',
		'orientation',
		'side',
		'showMeans',
		'showExtrema',
		'showMedians',
		'quantiles',
		'points',
		'bandwidth',
		'faceColor',
		'lineColor',
		'parts',
		'lineWidth'
	],
	#category : 'Bloc-Plotter-Violin',
	#package : 'Bloc-Plotter',
	#tag : 'Violin'
}

{ #category : 'private - demo' }
BpViolinPlot class >> basicsData [
	"Answer the data of the gallery violin plot basics: 100 normal samples of mean 0 for each deviation 1, 2, 4, 5, 7 and 8."

	| random |
	random := Random seed: 19680801.
	^ #( 1 2 4 5 7 8 ) collect: [ :each |
		  self
			  normalSamples: 100
			  mean: 0
			  deviation: each
			  random: random ]
]

{ #category : 'private - demo' }
BpViolinPlot class >> customViolins: anInteger horizontal: aBoolean [
	"Answer the violins anInteger (1, 2 or 4) of the gallery violin plot basics, vertical or horizontal."

	| violins |
	violins := self x: self basicsData positions: #( 1 2 4 5 7 8 ).
	aBoolean ifTrue: [ violins orientation: #horizontal ].
	anInteger = 1 ifTrue: [
		violins
			points: 20;
			widths: 0.3;
			showMeans: true;
			showMedians: true ].
	anInteger = 2 ifTrue: [
		violins
			points: 40;
			widths: 0.5;
			showMeans: true;
			showMedians: true;
			bandwidth: #silverman ].
	anInteger = 4 ifTrue: [
		violins
			points: 60;
			widths: 0.7;
			showMeans: true;
			showMedians: true;
			quantiles: #( #( 0.1 ) #(  ) #(  ) #( 0.175 0.954 ) #( 0.75 ) #( 0.25 ) );
			bandwidth: 0.5 ].
	^ violins
]

{ #category : 'examples' }
BpViolinPlot class >> exampleInteraction [
	"Interaction handlers on violins: hover one to make it opaque, click it to see its median in the title."

	<example>
	| figure chart violins isBody |
	figure := BpFigure new.
	chart := BpChart new.
	chart title: 'Click a violin'.
	violins := chart addArtist: self instanceThreeViolins.
	isBody := [ :patch | (violins parts at: #bodies) includes: patch ].
	violins
		whenPatch: BlMouseEnterEvent
		do: [ :event :patch | (isBody value: patch) ifTrue: [ patch background: (patch background paint color alpha: 0.8) ] ];
		whenPatch: BlMouseLeaveEvent
		do: [ :event :patch | (isBody value: patch) ifTrue: [ violins paintBody: patch dataset: patch dataset ] ];
		whenPatch: BlClickEvent do: [ :event :patch |
			chart title: ('violin {1}: median {2}' format: {
				 patch dataset.
				 ((violins statistics at: patch dataset) median printShowingDecimalPlaces: 2) }) ].
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Violin interaction'
]

{ #category : 'examples' }
BpViolinPlot class >> examplePlotType [
	"Reproduce the plot type violinplot(D): three wide violins in a chart of fixed limits and ticks."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart addArtist: self instanceWideViolins.
	chart
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7).
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'violinplot(D)'
]

{ #category : 'examples' }
BpViolinPlot class >> exampleSplitViolins [
	"Compare two groups with half violins on each side of the same positions."

	<example>
	| figure chart |
	figure := BpFigure new.
	chart := BpChart new.
	chart
		addArtist: self instanceLowHalves;
		addArtist: self instanceHighHalves;
		title: 'Split violins';
		legend.
	figure chartAtRow: 1 column: 1 put: chart.
	^ figure show: 'Split violins'
]

{ #category : 'examples' }
BpViolinPlot class >> exampleViolinPlotBasics [
	"Reproduce the gallery 'Violin plot basics': points, widths, means, medians, bandwidths and quantiles, vertical and horizontal."

	<example>
	| figure |
	figure := BpFigure rows: 2 columns: 3.
	figure extent: 1000 @ 600.
	{
		{
			1.
			self instanceCustomOne.
			self instanceHorizontalCustomOne }.
		{
			2.
			self instanceCustomTwo.
			self instanceHorizontalCustomTwo }.
		{
			4.
			self instanceCustomFour.
			self instanceHorizontalCustomFour } } withIndexDo: [ :each :column |
			| title |
			title := 'Custom violin {1}' format: { each first }.
			figure
				chartAtRow: 1 column: column put: (BpChart new
					 addArtist: each second;
					 title: title;
					 yourself);
				chartAtRow: 2 column: column put: (BpChart new
					 addArtist: each third;
					 title: title;
					 yourself) ].
	^ figure show: 'violinplot'
]

{ #category : 'private - demo' }
BpViolinPlot class >> halvesOf: someDatasets side: aSymbol label: aString [
	"Answer the half violins of someDatasets on the side aSymbol, with their medians and without extrema."

	^ (self x: someDatasets)
		  side: aSymbol;
		  showExtrema: false;
		  showMedians: true;
		  label: aString;
		  yourself
]

{ #category : 'instances' }
BpViolinPlot class >> instanceCustomFour [
	"Gallery: Violin plot basics (violinplot), custom violin 4: 60 points, 0.7 wide, a bandwidth factor of 0.5 and quantiles (see `BpViolinPlot>>quantiles:`)."

	<sampleInstance>
	^ self customViolins: 4 horizontal: false
]

{ #category : 'instances' }
BpViolinPlot class >> instanceCustomOne [
	"Gallery: Violin plot basics (violinplot), custom violin 1: 20 points, 0.3 wide, with means and medians."

	<sampleInstance>
	^ self customViolins: 1 horizontal: false
]

{ #category : 'instances' }
BpViolinPlot class >> instanceCustomTwo [
	"Gallery: Violin plot basics (violinplot), custom violin 2: 40 points, 0.5 wide, the Silverman bandwidth."

	<sampleInstance>
	^ self customViolins: 2 horizontal: false
]

{ #category : 'instances' }
BpViolinPlot class >> instanceHighHalves [
	"Answer four half violins on the high side of their positions, the group after of the split violins demo."

	<sampleInstance>
	^ self halvesOf: self splitGroups last side: #high label: 'after'
]

{ #category : 'instances' }
BpViolinPlot class >> instanceHorizontalCustomFour [
	"Gallery: Violin plot basics (violinplot), custom violin 4 drawn horizontally."

	<sampleInstance>
	^ self customViolins: 4 horizontal: true
]

{ #category : 'instances' }
BpViolinPlot class >> instanceHorizontalCustomOne [
	"Gallery: Violin plot basics (violinplot), custom violin 1 drawn horizontally."

	<sampleInstance>
	^ self customViolins: 1 horizontal: true
]

{ #category : 'instances' }
BpViolinPlot class >> instanceHorizontalCustomTwo [
	"Gallery: Violin plot basics (violinplot), custom violin 2 drawn horizontally."

	<sampleInstance>
	^ self customViolins: 2 horizontal: true
]

{ #category : 'instances' }
BpViolinPlot class >> instanceLowHalves [
	"Answer four half violins on the low side of their positions, the group before of the split violins demo (see `BpViolinPlot>>side:`)."

	<sampleInstance>
	^ self halvesOf: self splitGroups first side: #low label: 'before'
]

{ #category : 'instances' }
BpViolinPlot class >> instanceThreeViolins [
	"Answer three violins of growing spread, with their medians."

	<sampleInstance>
	| random |
	random := Random seed: 3.
	^ (self x: ((1 to: 3) collect: [ :each |
		    self
			    normalSamples: 200
			    mean: each
			    deviation: each / 2
			    random: random ]))
		  showMedians: true;
		  yourself
]

{ #category : 'instances' }
BpViolinPlot class >> instanceViolins [
	"Answer two violins, with their medians."

	<sampleInstance>
	| random |
	random := Random seed: 42.
	^ (self x: {
		   (self
			    normalSamples: 200
			    mean: 0
			    deviation: 1
			    random: random).
		   (self
			    normalSamples: 200
			    mean: 2
			    deviation: 2
			    random: random) })
		  showMedians: true;
		  yourself
]

{ #category : 'instances' }
BpViolinPlot class >> instanceWideViolins [
	"Plot types: violinplot(D), three violins 2 wide at 2, 4 and 6, without lines, nearly opaque."

	<sampleInstance>
	| random |
	random := Random seed: 10.
	^ (self
		   x: {
			   (self
				    normalSamples: 200
				    mean: 3
				    deviation: 0.75
				    random: random).
			   (self
				    normalSamples: 200
				    mean: 5
				    deviation: 1
				    random: random).
			   (self
				    normalSamples: 200
				    mean: 4
				    deviation: 0.75
				    random: random) }
		   positions: #( 2 4 6 ))
		  widths: 2;
		  showExtrema: false;
		  alpha: 0.9;
		  yourself
]

{ #category : 'private - demo' }
BpViolinPlot class >> normalSamples: anInteger mean: aMean deviation: aDeviation random: aRandom [
	"Answer anInteger samples of a normal distribution drawn from aRandom."

	^ (1 to: anInteger) collect: [ :each | aRandom nextNormalMean: aMean deviation: aDeviation ]
]

{ #category : 'private - demo' }
BpViolinPlot class >> splitGroups [
	"Answer the data of the split violins demo: the four datasets before, then the four datasets after, drawn from the same generator."

	| random before after |
	random := Random seed: 7.
	before := (1 to: 4) collect: [ :each |
		          self
			          normalSamples: 150
			          mean: each
			          deviation: 1
			          random: random ].
	after := (1 to: 4) collect: [ :each |
		         self
			         normalSamples: 150
			         mean: each + 1
			         deviation: 0.6
			         random: random ].
	^ {
		  before.
		  after }
]

{ #category : 'instance creation' }
BpViolinPlot class >> x: aCollection [
	"Answer violins of the data aCollection (a collection of numbers for one violin, or one collection per violin) at the positions 1, 2, 3, ..."

	^ self new
		  x: aCollection;
		  yourself
]

{ #category : 'instance creation' }
BpViolinPlot class >> x: aCollection positions: someNumbers [
	"Answer violins of the data aCollection (a collection of numbers for one violin, or one collection per violin) at the positions someNumbers, one per violin."

	^ (self x: aCollection)
		  positions: someNumbers;
		  yourself
]

{ #category : 'private - computing' }
BpViolinPlot >> addPartsOf: aStatistics dataset: anIndex [
	"Add the body of the violin anIndex and the lines that are shown."

	| position halfWidth span line |
	position := self positions at: anIndex.
	halfWidth := (self setting: widths at: anIndex) / 2.
	(parts at: #bodies) add: (self
		 newBodyOf: aStatistics
		 at: position
		 halfWidth: halfWidth
		 dataset: anIndex).
	span := self lineSpanAt: position halfWidth: halfWidth.
	line := [ :role :value | (parts at: role) add: (self newLineFrom: span first @ value to: span last @ value dataset: anIndex) ].
	showMeans ifTrue: [ line value: #means value: aStatistics mean ].
	showExtrema ifTrue: [
		line value: #maxima value: aStatistics maximum.
		line value: #minima value: aStatistics minimum.
		(parts at: #bars) add: (self newLineFrom: position @ aStatistics minimum to: position @ aStatistics maximum dataset: anIndex) ].
	showMedians ifTrue: [ line value: #medians value: aStatistics median ].
	aStatistics quantiles do: [ :each | line value: #quantiles value: each ]
]

{ #category : 'accessing' }
BpViolinPlot >> bandwidth: aSymbolOrNumber [
	"Set the width of the kernel of the density estimates: #scott (the default), #silverman, or a number multiplying the standard deviation of the data (see `BpViolinStatistics`)."

	bandwidth := aSymbolOrNumber.
	self refresh
]

{ #category : 'private - style' }
BpViolinPlot >> bodyColorAt: anIndex [

	^ (self setting: (faceColor ifNil: [ defaultColors first ]) at: anIndex) alpha: (alpha ifNil: [ 0.3 ])
]

{ #category : 'private - computing' }
BpViolinPlot >> compute [

	| fractions |
	statistics := datasets withIndexCollect: [ :each :index |
		              fractions := (quantiles isNotEmpty and: [ quantiles first isNumber ])
			                           ifTrue: [ quantiles ]
			                           ifFalse: [ quantiles at: index ifAbsent: [ #(  ) ] ].
		              BpViolinStatistics
			              of: each
			              points: points
			              bandwidth: bandwidth
			              quantiles: fractions ]
]

{ #category : 'accessing' }
BpViolinPlot >> faceColor: aColorOrCollection [
	"Set the color of the bodies: one for all violins or one per violin."

	faceColor := aColorOrCollection.
	self refresh
]

{ #category : 'initialization' }
BpViolinPlot >> initialize [

	super initialize.
	datasets := #(  ).
	statistics := #(  ).
	widths := 0.5.
	orientation := #vertical.
	side := #both.
	showMeans := false.
	showExtrema := true.
	showMedians := false.
	quantiles := #(  ).
	points := 100.
	bandwidth := #scott
]

{ #category : 'axes' }
BpViolinPlot >> legendEntries [
	"Answer my label with a rectangle filled as my bodies."

	(label isNil or: [ statistics isEmpty ]) ifTrue: [ ^ #(  ) ].
	^ { (label asString -> (BlElement new
		    extent: 20 @ 10;
		    in: [ :swatch | self paintBody: swatch dataset: 1 ];
		    yourself)) }
]

{ #category : 'accessing' }
BpViolinPlot >> lineColor: aColorOrCollection [
	"Set the color of the lines (extrema, means, medians and quantiles): one for all violins or one per violin."

	lineColor := aColorOrCollection.
	self refresh
]

{ #category : 'private - computing' }
BpViolinPlot >> lineSpanAt: aPosition halfWidth: aNumber [
	"Answer where the lines across a violin start and end on the position axis: half the width of the violin centered on it, or from its position to its edge when only one side is drawn."

	side = #low ifTrue: [
		^ {
			  (aPosition - aNumber).
			  aPosition } ].
	side = #high ifTrue: [
		^ {
			  aPosition.
			  (aPosition + aNumber) } ].
	^ {
		  (aPosition - (aNumber / 2)).
		  (aPosition + (aNumber / 2)) }
]

{ #category : 'accessing' }
BpViolinPlot >> lineWidth: aNumberOfPoints [
	"Set the width of the lines in points (1.5 by default)."

	lineWidth := aNumberOfPoints.
	self refresh
]

{ #category : 'private - patches' }
BpViolinPlot >> newBodyOf: aStatistics at: aPosition halfWidth: aNumber dataset: anIndex [
	"Answer the body of a violin: a polygon up one side of the density estimate, scaled so that its highest density is aNumber away from aPosition, and down the other side."

	| scale lows highs |
	scale := aNumber / aStatistics densities max.
	lows := aStatistics coordinates with: aStatistics densities collect: [ :value :density |
		        (side = #high
			         ifTrue: [ aPosition ]
			         ifFalse: [ aPosition - (density * scale) ]) @ value ].
	highs := aStatistics coordinates with: aStatistics densities collect: [ :value :density |
		         (side = #low
			          ifTrue: [ aPosition ]
			          ifFalse: [ aPosition + (density * scale) ]) @ value ].
	^ self
		  newPatch: (BpPolygonPatch new closed: true)
		  through: lows , highs reversed
		  dataset: anIndex
		  style: [ :patch | self paintBody: patch dataset: anIndex ]
]

{ #category : 'private - patches' }
BpViolinPlot >> newLineFrom: aPoint to: anotherPoint dataset: anIndex [
	"Answer a line between two points given as (position @ value)."

	^ self
		  newPatch: (BpPolygonPatch new closed: false)
		  through: {
			  aPoint.
			  anotherPoint }
		  dataset: anIndex
		  style: [ :patch | self paintLine: patch dataset: anIndex ]
]

{ #category : 'private - patches' }
BpViolinPlot >> newPatch: aPolygon through: somePoints dataset: anIndex style: aBlock [

	aPolygon
		artist: self;
		dataset: anIndex;
		dataVertices: (somePoints collect: [ :each | self oriented: each ]).
	aBlock value: aPolygon.
	patchHandlers do: [ :each | self addHandler: each to: aPolygon ].
	^ aPolygon
]

{ #category : 'private - computing' }
BpViolinPlot >> newPatches [
	"Build the parts of each violin, then answer them in drawing order: the bodies, then the lines above them."

	| roles |
	roles := #( #bodies #means #maxima #minima #bars #medians #quantiles ).
	parts := Dictionary new.
	roles do: [ :each | parts at: each put: OrderedCollection new ].
	statistics withIndexDo: [ :each :index | self addPartsOf: each dataset: index ].
	roles do: [ :each | parts at: each put: (parts at: each) asArray ].
	^ roles flatCollect: [ :each | parts at: each ]
]

{ #category : 'accessing' }
BpViolinPlot >> orientation: aSymbol [
	"Set #vertical violins (the default) or #horizontal ones, whose values are on the x axis."

	(#( #vertical #horizontal ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown orientation: ' , aSymbol printString ].
	orientation := aSymbol.
	self refresh
]

{ #category : 'private - computing' }
BpViolinPlot >> oriented: aPoint [
	"Answer aPoint, given as (position @ value), in data coordinates: swapped when I am horizontal."

	^ orientation = #horizontal
		  ifTrue: [ aPoint y @ aPoint x ]
		  ifFalse: [ aPoint ]
]

{ #category : 'private - style' }
BpViolinPlot >> paintBody: anElement dataset: anIndex [
	"Fill anElement with the face color of the violin anIndex, made transparent by my alpha (0.3 by default), and outline it in the same color."

	| color |
	color := self bodyColorAt: anIndex.
	anElement
		background: color;
		border: (BlBorder paint: color width: self class pixelsPerPoint)
]

{ #category : 'private - style' }
BpViolinPlot >> paintLine: anElement dataset: anIndex [
	"Stroke anElement in the line color of the violin anIndex, without my alpha: it makes only the bodies transparent."

	anElement border: (self
		 strokeColor: (self setting: (lineColor ifNil: [ defaultColors first ]) at: anIndex)
		 width: (lineWidth ifNil: [ 1.5 ])
		 style: #solid)
]

{ #category : 'accessing' }
BpViolinPlot >> parts [
	"Answer my patches by role: #bodies, #means, #maxima, #minima, #bars, #medians and #quantiles."

	^ parts
]

{ #category : 'accessing' }
BpViolinPlot >> points: anInteger [
	"Set at how many points the density of each violin is estimated (100 by default)."

	points := anInteger.
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> positions [
	"Answer where the violins are on the position axis: the given positions, or 1, 2, 3, ..."

	^ positions ifNil: [ (1 to: datasets size) asArray ]
]

{ #category : 'accessing' }
BpViolinPlot >> positions: aCollectionOfNumbersOrNil [
	"Set where the violins are on the position axis, one per violin (1, 2, 3, ... by default)."

	(aCollectionOfNumbersOrNil isNil or: [ aCollectionOfNumbersOrNil size = datasets size ]) ifFalse: [
		^ self error: 'One position per violin is needed' ].
	positions := aCollectionOfNumbersOrNil ifNotNil: [ aCollectionOfNumbersOrNil asArray ].
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> quantiles: aCollection [
	"Draw a line at each quantile, given as fractions between 0 and 1: one collection for all violins, or one collection per violin."

	quantiles := aCollection.
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> showExtrema: aBoolean [
	"Draw lines at the minimum and maximum of each violin and a bar between them (true by default)."

	showExtrema := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> showMeans: aBoolean [
	"Draw a line at the mean of each violin (false by default)."

	showMeans := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> showMedians: aBoolean [
	"Draw a line at the median of each violin (false by default)."

	showMedians := aBoolean.
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> side: aSymbol [
	"Set which half of the violins to draw: #both (the default), #low (below or left of the positions) or #high (above or right of them)."

	(#( #both #low #high ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown side: ' , aSymbol printString ].
	side := aSymbol.
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> statistics [
	"Answer the `BpViolinStatistics` of each violin."

	^ statistics
]

{ #category : 'accessing' }
BpViolinPlot >> widths: aNumberOrCollection [
	"Set the largest width of the violins, in data units: one number for all (0.5 by default) or one per violin."

	((self isMany: aNumberOrCollection) and: [ aNumberOrCollection size ~= datasets size ]) ifTrue: [
		^ self error: 'One width per violin is needed' ].
	widths := aNumberOrCollection.
	self refresh
]

{ #category : 'accessing' }
BpViolinPlot >> x: aCollection [
	"Set the data: a collection of numbers for one violin, or one collection of numbers per violin."

	datasets := (aCollection isNotEmpty and: [ aCollection first isNumber ])
		            ifTrue: [ { aCollection asArray } ]
		            ifFalse: [ aCollection collect: [ :each | each asArray ] as: Array ].
	self refresh
]
