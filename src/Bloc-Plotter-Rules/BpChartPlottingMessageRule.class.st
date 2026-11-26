"
I am a Renraku rule reporting the sends of the plotting messages of `BpChart` (`plotX:y:`, `hist:`, `barX:height:`…, listed by `BpChartPlottingMessageRule class>>plottingSelectors`). They duplicate the creation of the artists and will be removed: an artist is created by its own class (`BpLine x: … y: …`), usually in an `instance…` method of that class, and added to a chart with `BpChart>>addArtist:`, as in `BpBarPlot class>>exampleBarColors`.

## Examples

```
BpChartPlottingMessageRule exampleMethodsSendingPlottingMessages
```

## Design Rationale

- I report everywhere: examples, instances, helpers and tests. When I report nothing, the plotting messages can be removed from `BpChart`.
- The selectors are listed in my class rather than read from a protocol of `BpChart`, so I keep reporting the senders after the methods are removed.
- Some creation messages of the artists have the same selector as a plotting message (`BpBarPlot class>>barX:height:`, `BpStemPlot class>>stem:`…). A send to an artist class, or to `self` on the class side of an artist, is therefore accepted.
- The methods of `BpChart` and its subclasses are not checked: they implement the plotting messages (`plotX:y:format:` sends `plotX:y:`) until these are removed. Their class-side methods, such as `BpChart class>>instanceHistogram`, are checked.

## Usage

1. Renraku creates me, as every rule whose class answers true to `checksMethod`, and runs me on the methods it criticizes (for instance `ReCriticEngine critiquesOf: aMethod`); I am in the group Bloc-Plotter.
2. Renraku sends me `basicCheck:` with a compiled method, and reports a critique when I answer true.

- I hold no state between checks.

## Implementation Notes

- The receiver is checked syntactically: a plotting message sent to a variable holding an artist is still reported, which is right since artists do not understand them.
- Renraku caches its rules: after loading me in a running image, `ReRuleManager reset` makes me run.
"
Class {
	#name : 'BpChartPlottingMessageRule',
	#superclass : 'ReAbstractRule',
	#category : 'Bloc-Plotter-Rules',
	#package : 'Bloc-Plotter-Rules'
}

{ #category : 'testing - interest' }
BpChartPlottingMessageRule class >> checksMethod [

	^ true
]

{ #category : 'examples' }
BpChartPlottingMessageRule class >> exampleMethodsSendingPlottingMessages [
	"Inspect the methods of the Bloc-Plotter packages that still send a plotting message of BpChart."

	<example>
	| rule packages |
	rule := self instanceRule.
	packages := self packageOrganizer packages select: [ :each | each name beginsWith: 'Bloc-Plotter' ].
	^ (packages flatCollect: [ :each | each methods select: [ :method | rule basicCheck: method ] ]) inspect
]

{ #category : 'accessing' }
BpChartPlottingMessageRule class >> group [

	^ 'Bloc-Plotter'
]

{ #category : 'instances' }
BpChartPlottingMessageRule class >> instanceRule [
	"Answer the rule, ready to check methods with basicCheck:."

	<sampleInstance>
	^ self new
]

{ #category : 'accessing' }
BpChartPlottingMessageRule class >> plottingSelectors [
	"Answer the plotting messages of BpChart that duplicate the creation of the artists, to be removed."

	^ #( #barX:height: #barhY:width: #boxPlot: #densityPlot: #errorBarX:y:xErr:yErr: #errorBarX:y:yErr: #fillBetweenX:y1:
	     #fillBetweenX:y1:y2: #fillBetweenY:x1: #fillBetweenY:x1:x2: #heatmap: #hexbinX:y: #hist: #plotX:y: #plotX:y:format:
	     #scatterX:y: #stackPlotX:ys: #stairs: #stairs:edges: #stem: #stemLocations:heads: #violinPlot: #violinPlot:positions: )
]

{ #category : 'manifest' }
BpChartPlottingMessageRule class >> uniqueIdentifierName [
	"This name should be unique and should change only when the rule completely changes semantics."

	^ 'BpChartPlottingMessageRule'
]

{ #category : 'running' }
BpChartPlottingMessageRule >> basicCheck: aMethod [
	"Answer whether aMethod, outside the implementation of a chart, sends a plotting message of BpChart."

	(aMethod methodClass includesBehavior: BpChart) ifTrue: [ ^ false ].
	^ aMethod ast sendNodes anySatisfy: [ :node |
		  (self isPlotting: node) and: [ (self isSentToAnArtistClass: node in: aMethod) not ] ]
]

{ #category : 'private - testing' }
BpChartPlottingMessageRule >> isPlotting: aMessageNode [

	^ self class plottingSelectors includes: aMessageNode selector
]

{ #category : 'private - testing' }
BpChartPlottingMessageRule >> isSentToAnArtistClass: aMessageNode in: aMethod [
	"Answer whether aMessageNode goes to the class side of an artist: to an artist class named by its global, or to self in a class-side method of an artist. Some creation messages of the artists have the same selector as a plotting message."

	| receiver |
	receiver := aMessageNode receiver.
	receiver isSelfVariable ifTrue: [
		^ aMethod methodClass isClassSide and: [ aMethod methodClass instanceSide includesBehavior: BpArtist ] ].
	^ receiver isGlobalVariable and: [
		  | value |
		  value := receiver variable value.
		  value isClass and: [ value includesBehavior: BpArtist ] ]
]

{ #category : 'accessing' }
BpChartPlottingMessageRule >> rationale [

	^ 'The plotting messages of BpChart (plotX:y:, hist:, barX:height:...) duplicate the creation of the artists and will be removed. Create the artist with its class (BpLine x:y:, BpBarPlot barX:height:...), usually through an instance method of the artist class, and add it to the chart with addArtist:.'
]

{ #category : 'accessing' }
BpChartPlottingMessageRule >> ruleName [

	^ 'Plotting message of BpChart'
]
