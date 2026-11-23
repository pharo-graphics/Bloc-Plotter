"
I am a line plot with error bars, added by `BpAxes>>errorBarX:y:yErr:` and `BpAxes>>errorBarX:y:xErr:yErr:`: around each point, a bar on y (`yErr:`), on x (`xErr:`) or both shows the uncertainty of the measure. As a `BpLine`, I draw the points with my line and markers (`format:`, `color:`, `marker:`, ...; `format: 'none'` draws only the bars). The bars can end with caps (`capSize:`), and a value can be marked as a limit, which draws its bar on one side only with an arrow (`lowerLimits:`, `upperLimits:`, `xLowerLimits:`, `xUpperLimits:`).

## Examples

```
BpErrorBar scriptPlotType.
BpErrorBar scriptErrorbarFunction.
BpErrorBar scriptErrorbarFeatures.
BpErrorBar scriptLimits.
BpErrorBar scriptSubsample.
BpErrorBar scriptInteraction.
BpErrorBar exampleMeasures
```

## Design Rationale

- I am a `BpLine` rather than an artist holding one: the points keep all the settings, the format string and the legend of a line plot, and I only add the bars.
- An error is a number for every point, one number per point, or two collections, the lower errors then the upper ones; they are lengths, never negative.
- A lower limit means the true value is above the point: its bar goes only up and ends with an arrow pointing up (`caret:`); an upper limit is the opposite. Limits are booleans for all points or one per point.
- The bars, caps and arrows take the color and width of my line unless `errorColor:` and `errorLineWidth:` are given, and are drawn below my line and markers unless `barsAbove: true`. Caps and arrows are 1 point thick (`capThick:`).
- With many points, `errorEvery:` draws one bar in n, and `errorEvery:startingAt:` shifts them so that two series sharing x values do not hide each other's bars.

## Usage

1. `BpAxes>>errorBarX:y:yErr:` and `BpAxes>>errorBarX:y:xErr:yErr:` create me (`BpLine class>>x:y:`) and add me to the axes; see `BpArtist` for the rest of the life cycle.
2. Each setter rebuilds my patches: `barPatches` (`BpPolygonPatch`es whose `dataset` is the index of their point) and `capPatches` (`BpMarkerPatch`es for caps and arrows), then those of my line.
3. My legend entry is the swatch of my line crossed by an error bar.

## Implementation Notes

- My patches are the x bars then the y bars, then the caps: at both ends of the bars that are not limits, then the arrows of the lower limits, then those of the upper limits, each followed by a cap on its point when I have caps.
- Arrows are open markers whose base is at the end of the bar, so they point away from it.
- I have one slot and setter per option, hence many slots.

## Invariants and Assumptions

- Errors and limit collections have one value per point; errors are checked each time I am rebuilt.
"
Class {
	#name : 'BpErrorBar',
	#superclass : 'BpLine',
	#instVars : [
		'xErr',
		'yErr',
		'errorColor',
		'errorLineWidth',
		'capSize',
		'capThick',
		'errorStep',
		'errorStart',
		'barsAbove',
		'lowerLimits',
		'upperLimits',
		'xLowerLimits',
		'xUpperLimits',
		'barPatches',
		'capPatches'
	],
	#category : 'Bloc-Plotter-ErrorBar',
	#package : 'Bloc-Plotter',
	#tag : 'ErrorBar'
}

{ #category : 'private - demo' }
BpErrorBar class >> addLimitSeriesTo: anAxes [
	"Draw in anAxes the four series of the gallery limits demo: no limits, upper limits, both limits, and alternate limits."

	| x y yErr shifted |
	x := 0 to: 9.
	y := x collect: [ :each | (each / 20 * Float pi) sin * 2.5 ].
	yErr := self linspaceFrom: 0.05 to: 0.2 count: 10.
	shifted := [ :offset | anAxes errorBarX: x y: (y collect: [ :each | each + offset ]) yErr: yErr ].
	(shifted value: 3) label: 'both limits (default)'.
	(shifted value: 2)
		upperLimits: true;
		label: 'upperLimits: true'.
	(shifted value: 1)
		upperLimits: true;
		lowerLimits: true;
		label: 'upperLimits: true, lowerLimits: true'.
	(shifted value: 0)
		upperLimits: ((1 to: 10) collect: [ :each | each odd ]);
		lowerLimits: ((1 to: 10) collect: [ :each | each even ]);
		label: 'subsets of upperLimits and lowerLimits'
]

{ #category : 'markers' }
BpErrorBar class >> caret: aSymbol [
	"Answer the arrow drawn at the end of the error bar of a limit, pointing #up, #down, #left or #right, with its base on the end of the bar."

	| up directions |
	up := {
		      (-0.5 @ 0).
		      (0 @ 0.75).
		      (0.5 @ 0) }.
	directions := Dictionary new
		              at: #up put: up;
		              at: #down put: (up collect: [ :each | each x @ each y negated ]);
		              at: #right put: (up collect: [ :each | each y @ each x ]);
		              at: #left put: (up collect: [ :each | each y negated @ each x ]);
		              yourself.
	^ BpMarker kind: #lines vertices: (directions at: aSymbol ifAbsent: [ ^ self error: 'Unknown caret: ' , aSymbol printString ])
]

{ #category : 'examples' }
BpErrorBar class >> exampleErrorbarFeatures [
	"Gallery: Different ways of specifying error bars (errorbar_features): symmetric errors varying with x, then asymmetric x errors on a log scale."

	<sampleInstance>
	| figure x y error symmetric asymmetric |
	figure := BpFigure rows: 2 columns: 1.
	figure extent: 640 @ 640.
	x := self arangeFrom: 0.1 to: 4 by: 0.5.
	y := x collect: [ :each | each negated exp ].
	error := x collect: [ :each | 0.2 * each + 0.1 ].
	symmetric := figure axesAtRow: 1 column: 1.
	(symmetric errorBarX: x y: y yErr: error) format: '-o'.
	symmetric title: 'variable, symmetric error'.
	asymmetric := figure axesAtRow: 2 column: 1.
	(asymmetric
		 errorBarX: x
		 y: y
		 xErr: {
			 (error collect: [ :each | each * 0.4 ]).
			 error }
		 yErr: nil) format: 'o'.
	asymmetric
		title: 'variable, asymmetric error';
		yScale: #log.
	^ figure
]

{ #category : 'examples' }
BpErrorBar class >> exampleErrorbarFunction [
	"Gallery: Errorbar function (errorbar), the same error on every point: 0.2 in x and 0.4 in y."

	<sampleInstance>
	| figure axes x |
	figure := BpFigure new.
	axes := figure axes first.
	x := self arangeFrom: 0.1 to: 4 by: 0.5.
	axes
		errorBarX: x
		y: (x collect: [ :each | each negated exp ])
		xErr: 0.2
		yErr: 0.4.
	axes title: 'Simplest errorbars, 0.2 in x, 0.4 in y'.
	^ figure
]

{ #category : 'examples' }
BpErrorBar class >> exampleInteractiveErrorBars [
	"Measures with error bars: hovering a bar thickens it, clicking it shows the measure in the title."

	<sampleInstance>
	| figure axes measures errors errorBar |
	figure := BpFigure new.
	axes := figure axes first.
	axes title: 'Click an error bar'.
	measures := #( 2.1 3.4 3.0 4.6 5.2 ).
	errors := #( 0.3 0.5 0.4 0.6 0.3 ).
	errorBar := (axes errorBarX: (1 to: 5) y: measures yErr: errors)
		            format: 'o';
		            capSize: 5;
		            yourself.
	errorBar
		whenPatch: BlMouseEnterEvent
		do: [ :event :patch |
			(errorBar barPatches includes: patch) ifTrue: [ patch border: (BlBorder paint: patch border paint width: 5) ] ];
		whenPatch: BlMouseLeaveEvent
		do: [ :event :patch |
			(errorBar barPatches includes: patch) ifTrue: [ patch border: (BlBorder paint: patch border paint width: 2) ] ];
		whenPatch: BlClickEvent do: [ :event :patch |
			(errorBar barPatches includes: patch) ifTrue: [
				axes title: ('measure {1}: {2} ± {3}' format: {
					 patch dataset.
					 (measures at: patch dataset).
					 (errors at: patch dataset) }) ] ].
	^ figure
]

{ #category : 'examples' }
BpErrorBar class >> exampleLimits [
	"Gallery: Including upper and lower limits in error bars (errorbar_limits_simple), first figure: limits on all points, on both sides, or on some points only."

	<sampleInstance>
	| figure |
	figure := BpFigure new.
	self addLimitSeriesTo: figure axes first.
	figure axes first legend.
	^ figure
]

{ #category : 'examples' }
BpErrorBar class >> exampleMeasures [
	"Answer five measures drawn as circles with error bars and caps, in new axes."

	<sampleInstance>
	^ ((BpAxes new
		    extent: 400 @ 300;
		    yourself) errorBarX: (1 to: 5) y: #( 2.1 3.4 3.0 4.6 5.2 ) yErr: #( 0.3 0.5 0.4 0.6 0.3 ))
		  format: 'o';
		  capSize: 4;
		  yourself
]

{ #category : 'examples' }
BpErrorBar class >> examplePlotType [
	"Plot types: errorbar(x, y, yerr, xerr), three circles with 2 point wide error bars and caps, with fixed limits and ticks."

	<sampleInstance>
	| figure axes |
	figure := BpFigure new.
	axes := figure axes first.
	(axes errorBarX: #( 2 4 6 ) y: #( 3.6 5 4.2 ) yErr: #( 0.9 1.2 0.5 ))
		format: 'o';
		lineWidth: 2;
		capSize: 6.
	axes
		xLimits: #( 0 8 );
		xTicks: (1 to: 7);
		yLimits: #( 0 8 );
		yTicks: (1 to: 7).
	^ figure
]

{ #category : 'examples' }
BpErrorBar class >> exampleSubsample [
	"Gallery: Errorbar subsampling (errorbar_subsample): all error bars, one in six, then the second series shifted by three points."

	<sampleInstance>
	| figure |
	figure := BpFigure rows: 1 columns: 3.
	figure extent: 1000 @ 360.
	1 to: 3 do: [ :column | self subsampleIn: (figure axesAtRow: 1 column: column) column: column ].
	^ figure
]

{ #category : 'script' }
BpErrorBar class >> scriptErrorbarFeatures [
	"Reproduce the gallery 'Different ways of specifying error bars': symmetric and asymmetric errors."

	<example>
	^ self exampleErrorbarFeatures show: 'errorbar_features'
]

{ #category : 'script' }
BpErrorBar class >> scriptErrorbarFunction [
	"Reproduce the gallery 'Errorbar function': the same errors on every point."

	<example>
	^ self exampleErrorbarFunction show: 'errorbar'
]

{ #category : 'script' }
BpErrorBar class >> scriptInteraction [
	"Interaction handlers on error bars: hover a bar to thicken it, click it to see its measure."

	<example>
	^ self exampleInteractiveErrorBars show: 'Error bar interaction'
]

{ #category : 'script' }
BpErrorBar class >> scriptLimits [
	"Reproduce the gallery 'Including upper and lower limits in error bars'."

	<example>
	^ self exampleLimits show: 'errorbar_limits_simple'
]

{ #category : 'script' }
BpErrorBar class >> scriptPlotType [
	"Reproduce the plot type errorbar(x, y, yerr, xerr)."

	<example>
	^ self examplePlotType show: 'errorbar(x, y, yerr, xerr)'
]

{ #category : 'script' }
BpErrorBar class >> scriptSubsample [
	"Reproduce the gallery 'Errorbar subsampling': draw one error bar in six, shifted between two series."

	<example>
	^ self exampleSubsample show: 'errorbar_subsample'
]

{ #category : 'private - demo' }
BpErrorBar class >> subsampleIn: anAxes column: anInteger [
	"Draw in anAxes the two series of the gallery subsampling demo: with all their error bars in the first column, one in six in the second one, one in six shifted by three points for the second series in the third one."

	| x first second |
	x := self arangeFrom: 0.1 to: 4 by: 0.1.
	first := anAxes errorBarX: x y: (x collect: [ :each | each negated exp ]) yErr: (x collect: [ :each | 0.1 * each sqrt + 0.1 ]).
	second := anAxes
		          errorBarX: x
		          y: (x collect: [ :each | (each / -2) exp ])
		          yErr: (x collect: [ :each | 0.1 * (each / 2) sqrt + 0.1 ]).
	anInteger = 1 ifTrue: [ ^ anAxes title: 'all errorbars' ].
	first errorEvery: 6.
	anInteger = 2 ifTrue: [
		second errorEvery: 6.
		^ anAxes title: 'only every 6th errorbar' ].
	second errorEvery: 6 startingAt: 4.
	anAxes title: 'second series shifted by 3'
]

{ #category : 'private - patches' }
BpErrorBar >> addCapsOf: someEnds on: anAxis lowers: someLowerIndices uppers: someUpperIndices [
	"Add the caps of the error bars whose ends are someEnds (index -> ends): at both ends of the bars that are not limits, then the arrows of the lower limits at their upper end and those of the upper limits at their lower end."

	| cap free |
	cap := self capOn: anAxis.
	free := someEnds reject: [ :each | (someLowerIndices includes: each key) or: [ someUpperIndices includes: each key ] ].
	capSize > 0 ifTrue: [
		#( 1 2 ) do: [ :end | capPatches addAll: (free collect: [ :each | self newCap: cap at: (each value at: end) index: each key ]) ] ].
	self
		addLimitsOf: (someEnds select: [ :each | someLowerIndices includes: each key ])
		at: 2
		arrow: (self arrowsOn: anAxis) first
		cap: cap.
	self
		addLimitsOf: (someEnds select: [ :each | someUpperIndices includes: each key ])
		at: 1
		arrow: (self arrowsOn: anAxis) last
		cap: cap
]

{ #category : 'private - patches' }
BpErrorBar >> addErrorsOn: anAxis [
	"Add the error bars on anAxis (#x or #y) of the points to draw, then their caps. The bar of a lower limit goes only up from its point, the bar of an upper limit only down."

	| errors lowers uppers ends |
	errors := self errorsOf: (self errorOn: anAxis) named: anAxis , 'Err'.
	errors ifNil: [ ^ self ].
	lowers := self limitIndicesOf: (self lowerLimitsOn: anAxis).
	uppers := self limitIndicesOf: (self upperLimitsOn: anAxis).
	lowers do: [ :each |
		errors at: each put: {
			0.
			(errors at: each) last } ].
	uppers do: [ :each |
		errors at: each put: {
			(errors at: each) first.
			0 } ].
	ends := self errorIndices collect: [ :each | each -> (self endsOf: each on: anAxis errors: (errors at: each)) ].
	barPatches addAll: (ends collect: [ :each | self newBarFrom: each value first to: each value last index: each key ]).
	self
		addCapsOf: ends
		on: anAxis
		lowers: lowers
		uppers: uppers
]

{ #category : 'private - patches' }
BpErrorBar >> addLimitsOf: someEnds at: anEndIndex arrow: aDirection cap: aMarker [
	"Add an arrow pointing to aDirection at one end (1 for the lower one, 2 for the upper one) of the error bars of limits someEnds (index -> ends), and a cap on their points when I have caps."

	| arrow |
	arrow := self class caret: aDirection.
	capPatches addAll: (someEnds collect: [ :each | self newCap: arrow at: (each value at: anEndIndex) index: each key ]).
	capSize > 0 ifTrue: [
		capPatches addAll: (someEnds collect: [ :each | self newCap: aMarker at: (points at: each key) index: each key ]) ]
]

{ #category : 'private - computing' }
BpErrorBar >> arrowsOn: anAxis [
	"Answer the directions of the arrows of the lower and of the upper limits on anAxis."

	^ anAxis = #y
		  ifTrue: [ #( #up #down ) ]
		  ifFalse: [ #( #right #left ) ]
]

{ #category : 'accessing' }
BpErrorBar >> barPatches [

	^ barPatches
]

{ #category : 'accessing' }
BpErrorBar >> barsAbove: aBoolean [
	"Draw the error bars above my line and markers (false by default: below them)."

	barsAbove := aBoolean.
	self refresh
]

{ #category : 'private - computing' }
BpErrorBar >> capOn: anAxis [
	"Answer the marker of the caps of the error bars on anAxis: across the bars."

	^ BpMarker on: (anAxis = #y
		   ifTrue: [ '_' ]
		   ifFalse: [ '|' ])
]

{ #category : 'accessing' }
BpErrorBar >> capPatches [

	^ capPatches
]

{ #category : 'accessing' }
BpErrorBar >> capSize: aNumberOfPoints [
	"Set the length of the caps at the ends of the error bars in points, on each side of the bar (0, no caps, by default)."

	capSize := aNumberOfPoints.
	self refresh
]

{ #category : 'accessing' }
BpErrorBar >> capThick: aNumberOfPoints [
	"Set the thickness of the caps and limit arrows in points (1 by default)."

	capThick := aNumberOfPoints.
	self refresh
]

{ #category : 'private - computing' }
BpErrorBar >> compute [
	"Compute my points, and check my errors."

	super compute.
	self errorsOf: xErr named: 'xErr'.
	self errorsOf: yErr named: 'yErr'
]

{ #category : 'private - computing' }
BpErrorBar >> endsOf: anIndex on: anAxis errors: aPair [
	"Answer the two ends of the error bar of the point anIndex on anAxis, aPair holding its lower and upper errors."

	| point value |
	point := points at: anIndex.
	value := anAxis = #y
		         ifTrue: [ point y ]
		         ifFalse: [ point x ].
	^ {
		  (self point: anIndex on: anAxis at: value - aPair first).
		  (self point: anIndex on: anAxis at: value + aPair last) }
]

{ #category : 'accessing' }
BpErrorBar >> errorColor: aColorOrName [
	"Set the color of the error bars and caps (the color of my line by default)."

	errorColor := aColorOrName.
	self refresh
]

{ #category : 'private - patches' }
BpErrorBar >> errorColorValue [
	"Answer the color of my error bars: the error color, else the color of my line."

	^ errorColor ifNil: [ self lineColor ] ifNotNil: [ self colorOf: errorColor ]
]

{ #category : 'accessing' }
BpErrorBar >> errorEvery: anInteger [
	"Draw the error bars of one point in anInteger only, from the first point."

	self errorEvery: anInteger startingAt: 1
]

{ #category : 'accessing' }
BpErrorBar >> errorEvery: anInteger startingAt: anIndex [
	"Draw the error bars of one point in anInteger only, from the point at anIndex, so that the bars of several series sharing x values do not overlap."

	errorStep := anInteger.
	errorStart := anIndex.
	self refresh
]

{ #category : 'private - computing' }
BpErrorBar >> errorIndices [
	"Answer the indices of the points whose error bars are drawn."

	^ errorStart to: points size by: errorStep
]

{ #category : 'accessing' }
BpErrorBar >> errorLineWidth: aNumberOfPoints [
	"Set the width of the error bars in points (the width of my line by default)."

	errorLineWidth := aNumberOfPoints.
	self refresh
]

{ #category : 'private - computing' }
BpErrorBar >> errorOn: anAxis [

	^ anAxis = #y
		  ifTrue: [ yErr ]
		  ifFalse: [ xErr ]
]

{ #category : 'private - computing' }
BpErrorBar >> errorsOf: anErrorOrNil named: aString [
	"Answer the lower and upper errors of each point, as pairs, or nil when there are none."

	| bounds |
	anErrorOrNil ifNil: [ ^ nil ].
	bounds := self lowersAndUppersOf: anErrorOrNil named: aString.
	(bounds allSatisfy: [ :each | each size = points size ]) ifFalse: [
		^ self error: ('{1} has {2} values for {3} points' format: {
			   aString.
			   bounds first size.
			   points size }) ].
	(bounds first , bounds last anySatisfy: [ :each | each negative ]) ifTrue: [ ^ self error: aString , ' must not be negative' ].
	^ bounds first with: bounds last collect: [ :lower :upper |
		  {
			  lower.
			  upper } ]
]

{ #category : 'accessing - format' }
BpErrorBar >> format: aString [
	"Set my format as `BpLine>>format:` does; 'none' draws neither line nor markers, only the error bars."

	aString = 'none' ifFalse: [ ^ super format: aString ].
	marker := nil.
	lineStyle := #none.
	self refresh
]

{ #category : 'initialization' }
BpErrorBar >> initialize [

	super initialize.
	capSize := 0.
	errorStep := 1.
	errorStart := 1.
	barsAbove := false.
	barPatches := #(  ).
	capPatches := #(  )
]

{ #category : 'private - computing' }
BpErrorBar >> isLimit: aBooleanOrCollection at: anIndex [

	aBooleanOrCollection ifNil: [ ^ false ].
	^ self setting: aBooleanOrCollection at: anIndex
]

{ #category : 'private - computing' }
BpErrorBar >> limitIndicesOf: aBooleanOrCollection [
	"Answer the indices of the drawn points that aBooleanOrCollection marks as limits."

	^ self errorIndices select: [ :each | self isLimit: aBooleanOrCollection at: each ]
]

{ #category : 'accessing' }
BpErrorBar >> lowerLimits: aBooleanOrCollection [
	"Mark y values as lower limits, all of them or one boolean per point: their error bar goes only up, and ends with an arrow pointing up."

	lowerLimits := aBooleanOrCollection.
	self refresh
]

{ #category : 'private - computing' }
BpErrorBar >> lowerLimitsOn: anAxis [

	^ anAxis = #y
		  ifTrue: [ lowerLimits ]
		  ifFalse: [ xLowerLimits ]
]

{ #category : 'private - computing' }
BpErrorBar >> lowersAndUppersOf: anError named: aString [
	"Answer the lower errors and the upper errors of anError: a number for every point, one number per point, or the lower then the upper errors."

	| all |
	(self isMany: anError) ifFalse: [
		all := Array new: points size withAll: anError.
		^ {
			  all.
			  all } ].
	(anError isEmpty or: [ anError first isNumber ]) ifTrue: [
		^ {
			  anError asArray.
			  anError asArray } ].
	anError size = 2 ifFalse: [ ^ self error: aString , ' needs the lower then the upper errors' ].
	^ {
		  anError first asArray.
		  anError second asArray }
]

{ #category : 'private - patches' }
BpErrorBar >> newBarFrom: aPoint to: anotherPoint index: anIndex [
	"Answer the error bar of the point anIndex, between two points in data coordinates."

	| bar |
	bar := BpPolygonPatch new
		       artist: self;
		       dataset: anIndex;
		       closed: false;
		       dataVertices: {
			       aPoint.
			       anotherPoint };
		       yourself.
	bar border: (self strokeColor: self errorColorValue width: (errorLineWidth ifNil: [ lineWidth ]) style: #solid).
	patchHandlers do: [ :each | self addHandler: each to: bar ].
	^ bar
]

{ #category : 'private - patches' }
BpErrorBar >> newCap: aMarker at: aPoint index: anIndex [
	"Answer a cap or limit arrow of the point anIndex, at aPoint in data coordinates."

	| cap size |
	size := capSize > 0
		        ifTrue: [ 2 * capSize ]
		        ifFalse: [ self class defaultMarkerSize ].
	cap := BpMarkerPatch new
		       artist: self;
		       index: anIndex;
		       dataPoint: aPoint;
		       area: size squared;
		       marker: aMarker;
		       yourself.
	cap updateShape.
	cap
		background: Color transparent;
		border: (BlBorder paint: self errorColorValue width: (capThick ifNil: [ 1 ]) * self class pixelsPerPoint).
	patchHandlers do: [ :each | self addHandler: each to: cap ].
	^ cap
]

{ #category : 'private - computing' }
BpErrorBar >> newPatches [
	"Answer my error bars and caps, below my line and markers unless my bars are above."

	| line |
	line := super newPatches.
	barPatches := OrderedCollection new.
	capPatches := OrderedCollection new.
	self addErrorsOn: #x.
	self addErrorsOn: #y.
	barPatches := barPatches asArray.
	capPatches := capPatches asArray.
	^ barsAbove
		  ifTrue: [ line , barPatches , capPatches ]
		  ifFalse: [ barPatches , capPatches , line ]
]

{ #category : 'private - computing' }
BpErrorBar >> newSwatch [
	"Answer the swatch of my line and marker, crossed by an error bar: vertical when I have y errors, horizontal otherwise."

	| swatch extent |
	swatch := super newSwatch.
	(xErr isNil and: [ yErr isNil ]) ifTrue: [ ^ swatch ].
	extent := self class swatchExtent.
	swatch
		addChild: (BlElement new
			 geometry: (yErr
				  ifNil: [ BlLineGeometry from: 0 @ (extent y / 2) to: extent x @ (extent y / 2) ]
				  ifNotNil: [ BlLineGeometry from: extent x / 2 @ 0 to: extent x / 2 @ extent y ]);
			 border: (self strokeColor: self errorColorValue width: (errorLineWidth ifNil: [ lineWidth ]) style: #solid);
			 extent: extent;
			 yourself)
		at: 1.
	^ swatch
]

{ #category : 'private - computing' }
BpErrorBar >> point: anIndex on: anAxis at: aValue [
	"Answer the point anIndex moved to aValue on anAxis (#x or #y)."

	| point |
	point := points at: anIndex.
	^ anAxis = #y
		  ifTrue: [ point x @ aValue ]
		  ifFalse: [ aValue @ point y ]
]

{ #category : 'accessing' }
BpErrorBar >> upperLimits: aBooleanOrCollection [
	"Mark y values as upper limits, all of them or one boolean per point: their error bar goes only down, and ends with an arrow pointing down."

	upperLimits := aBooleanOrCollection.
	self refresh
]

{ #category : 'private - computing' }
BpErrorBar >> upperLimitsOn: anAxis [

	^ anAxis = #y
		  ifTrue: [ upperLimits ]
		  ifFalse: [ xUpperLimits ]
]

{ #category : 'accessing' }
BpErrorBar >> xErr: anErrorOrNil [
	"Set the errors on x, given as the errors on y (see `yErr:`)."

	xErr := anErrorOrNil.
	self refresh
]

{ #category : 'accessing' }
BpErrorBar >> xLowerLimits: aBooleanOrCollection [
	"Mark x values as lower limits, all of them or one boolean per point: their error bar goes only right, and ends with an arrow pointing right."

	xLowerLimits := aBooleanOrCollection.
	self refresh
]

{ #category : 'accessing' }
BpErrorBar >> xUpperLimits: aBooleanOrCollection [
	"Mark x values as upper limits, all of them or one boolean per point: their error bar goes only left, and ends with an arrow pointing left."

	xUpperLimits := aBooleanOrCollection.
	self refresh
]

{ #category : 'accessing' }
BpErrorBar >> yErr: anErrorOrNil [
	"Set the errors on y: a number for every point, one number per point, or two collections, the lower then the upper errors (nil for no y error bars)."

	yErr := anErrorOrNil.
	self refresh
]
