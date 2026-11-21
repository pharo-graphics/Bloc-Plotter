"
I compute the bins of a histogram as numpy does: the edges (`numpy.histogram_bin_edges`), the count of values in each bin and the densities (`numpy.histogram`). My `bins` are a number of equal bins, explicit edges, or the name of a strategy computing the bin width (#auto, #fd, #doane, #scott, #rice, #sturges, #sqrt).

## Examples

```
BpHistogramBinning exampleSturges
```

## Usage

1. `BpHistogram>>compute` creates me with `bins:` and `range:`, and asks me the edges of all its values.
2. It then uses my class-side `countsOf:weights:in:` and `density:in:` for each dataset.

- I only hold my settings, so I can compute the edges of several datasets; I keep no result between calls.

## Invariants and Assumptions

- Every bin is half-open except the last one, which is closed; values outside the edges are not counted.
- Strategies cannot be used with weights, as in numpy.
"
Class {
	#name : 'BpHistogramBinning',
	#superclass : 'Object',
	#instVars : [
		'bins',
		'range'
	],
	#category : 'Bloc-Plotter-Histogram',
	#package : 'Bloc-Plotter',
	#tag : 'Histogram'
}

{ #category : 'counting' }
BpHistogramBinning class >> binIndexOf: aValue in: anArrayOfEdges [
	"Answer the index of the bin holding aValue, which is between the first and the last edge: a binary search for the last edge not after aValue, the last edge belonging to the last bin."

	| low high |
	low := 1.
	high := anArrayOfEdges size.
	[ high - low > 1 ] whileTrue: [
		| middle |
		middle := low + high // 2.
		(anArrayOfEdges at: middle) <= aValue
			ifTrue: [ low := middle ]
			ifFalse: [ high := middle ] ].
	^ low
]

{ #category : 'instance creation' }
BpHistogramBinning class >> bins: anIntegerOrEdgesOrStrategy [

	^ self new
		  bins: anIntegerOrEdgesOrStrategy;
		  yourself
]

{ #category : 'counting' }
BpHistogramBinning class >> countsOf: aCollectionOfValues weights: aCollectionOrNil in: anArrayOfEdges [
	"Answer the number of values (or the sum of their weights) in each bin, as numpy.histogram: every bin is half-open except the last one, which is closed. Values outside the edges are ignored."

	| counts |
	counts := Array new: anArrayOfEdges size - 1 withAll: 0.
	aCollectionOfValues withIndexDo: [ :each :index |
		(each between: anArrayOfEdges first and: anArrayOfEdges last) ifTrue: [
			| bin |
			bin := self binIndexOf: each in: anArrayOfEdges.
			counts at: bin put: (counts at: bin) + (aCollectionOrNil ifNil: [ 1 ] ifNotNil: [ aCollectionOrNil at: index ]) ] ].
	^ counts
]

{ #category : 'counting' }
BpHistogramBinning class >> density: anArrayOfCounts in: anArrayOfEdges [
	"Answer the counts divided by their total and by the width of their bin, so that the area of the histogram is 1, as numpy.histogram with density=True."

	| total |
	total := anArrayOfCounts inject: 0 into: [ :sum :each | sum + each ].
	total = 0 ifTrue: [ ^ anArrayOfCounts collect: [ :each | 0 ] ].
	^ anArrayOfCounts withIndexCollect: [ :each :index |
		  each / total / ((anArrayOfEdges at: index + 1) - (anArrayOfEdges at: index)) ]
]

{ #category : 'examples' }
BpHistogramBinning class >> exampleSturges [
	"Answer a binning whose number of bins follows the Sturges rule."

	<sampleInstance>
	^ self bins: #sturges
]

{ #category : 'private' }
BpHistogramBinning >> autoWidth: anArray [
	"Answer the smaller of the Freedman-Diaconis and Sturges widths, Sturges when Freedman-Diaconis gives 0, as numpy."

	| fd |
	fd := self freedmanDiaconisWidth: anArray.
	^ fd > 0
		  ifTrue: [ fd min: (self sturgesWidth: anArray) ]
		  ifFalse: [ self sturgesWidth: anArray ]
]

{ #category : 'private' }
BpHistogramBinning >> binCountFor: aCollectionOfValues from: aFirst to: aLast [
	"Answer the number of equal bins between aFirst and aLast: my bins when they are a number, otherwise the number of bins of the width my strategy computes from the values in range."

	| width |
	bins isString ifFalse: [ ^ bins ].
	width := self binWidthFor: (aCollectionOfValues select: [ :each | each between: aFirst and: aLast ]) asArray.
	width > 0 ifFalse: [ ^ 1 ].
	^ (aLast - aFirst / width) ceiling max: 1
]

{ #category : 'private' }
BpHistogramBinning >> binWidthFor: anArray [
	"Answer the bin width my strategy computes for anArray, as numpy.histogram_bin_edges. A width of 0 means one bin."

	anArray size < 2 ifTrue: [ ^ 0 ].
	bins = #sqrt ifTrue: [ ^ (self peakToPeak: anArray) / anArray size sqrt ].
	bins = #sturges ifTrue: [ ^ self sturgesWidth: anArray ].
	bins = #rice ifTrue: [ ^ (self peakToPeak: anArray) / (2 * (anArray size raisedTo: 1 / 3)) ].
	bins = #scott ifTrue: [ ^ (24 * Float pi sqrt / anArray size raisedTo: 1 / 3) * (self standardDeviation: anArray) ].
	bins = #fd ifTrue: [ ^ self freedmanDiaconisWidth: anArray ].
	bins = #doane ifTrue: [ ^ self doaneWidth: anArray ].
	bins = #auto ifTrue: [ ^ self autoWidth: anArray ].
	^ self error: 'Unknown bin strategy: ' , bins printString
]

{ #category : 'accessing' }
BpHistogramBinning >> bins [

	^ bins
]

{ #category : 'accessing' }
BpHistogramBinning >> bins: anIntegerOrEdgesOrStrategy [
	"Set the bins as numpy does: a number of equal bins, a collection of edges, or the name of a strategy computing the bin width from the data (#auto, #fd, #doane, #scott, #rice, #sturges, #sqrt)."

	bins := anIntegerOrEdgesOrStrategy
]

{ #category : 'private' }
BpHistogramBinning >> checkedEdges [
	"Answer my bins, the edges given explicitly, once checked to be increasing."

	bins size < 2 ifTrue: [ ^ self error: 'At least two bin edges are needed' ].
	bins overlappingPairsDo: [ :a :b | a <= b ifFalse: [ ^ self error: 'Bin edges must increase monotonically' ] ].
	^ bins asArray
]

{ #category : 'private' }
BpHistogramBinning >> doaneWidth: anArray [
	"Answer the Doane width, Sturges corrected by the skewness of the data."

	| n sigma mean skewness skewnessDeviation |
	n := anArray size.
	n > 2 ifFalse: [ ^ 0 ].
	sigma := self standardDeviation: anArray.
	sigma > 0 ifFalse: [ ^ 0 ].
	mean := (anArray inject: 0 into: [ :sum :each | sum + each ]) / n.
	skewness := (anArray inject: 0 into: [ :sum :each | sum + (each - mean / sigma raisedTo: 3) ]) / n.
	skewnessDeviation := (6 * (n - 2) / (n + 1 * (n + 3))) sqrt.
	^ (self peakToPeak: anArray) / (1 + (n log: 2) + (1 + (skewness abs / skewnessDeviation) log: 2))
]

{ #category : 'computing' }
BpHistogramBinning >> edgesFor: aCollectionOfValues [

	^ self edgesFor: aCollectionOfValues weights: nil
]

{ #category : 'computing' }
BpHistogramBinning >> edgesFor: aCollectionOfValues weights: aCollectionOrNil [
	"Answer the bin edges for aCollectionOfValues, as numpy.histogram_bin_edges."

	| limits |
	bins isString ifTrue: [
		aCollectionOrNil ifNotNil: [ ^ self error: 'Automated estimation of the number of bins is not supported for weighted data' ] ].
	(bins isString not and: [ bins isCollection ]) ifTrue: [ ^ self checkedEdges ].
	limits := self limitsFor: aCollectionOfValues.
	^ self edgesFrom: limits first to: limits last count: (self binCountFor: aCollectionOfValues from: limits first to: limits last)
]

{ #category : 'private' }
BpHistogramBinning >> edgesFrom: aFirst to: aLast count: anInteger [

	^ (0 to: anInteger) collect: [ :index |
		  index = anInteger
			  ifTrue: [ aLast ]
			  ifFalse: [ aFirst + (index * (aLast - aFirst) / anInteger) ] ]
]

{ #category : 'private' }
BpHistogramBinning >> freedmanDiaconisWidth: anArray [

	^ 2 * ((self percentile: 75 of: anArray) - (self percentile: 25 of: anArray)) * (anArray size raisedTo: -1 / 3)
]

{ #category : 'initialization' }
BpHistogramBinning >> initialize [

	super initialize.
	bins := 10
]

{ #category : 'computing' }
BpHistogramBinning >> limitsFor: aCollectionOfValues [
	"Answer the first and last edges: my range, or the smallest and largest values (0 and 1 without values), widened by 0.5 on each side when they are equal."

	| limits |
	limits := range ifNil: [
		          aCollectionOfValues ifEmpty: [ #( 0 1 ) ] ifNotEmpty: [
			          {
				          aCollectionOfValues min.
				          aCollectionOfValues max } ] ].
	limits first = limits last ifTrue: [
		^ {
			  (limits first - 0.5).
			  (limits last + 0.5) } ].
	^ {
		  limits first.
		  limits last }
]

{ #category : 'private' }
BpHistogramBinning >> peakToPeak: anArray [

	^ anArray max - anArray min
]

{ #category : 'private' }
BpHistogramBinning >> percentile: aPercent of: anArray [
	"Answer the percentile with linear interpolation between the closest values, as numpy.percentile."

	| sorted position low fraction |
	sorted := anArray asArray sorted.
	position := aPercent / 100 * (sorted size - 1) + 1.
	low := position floor.
	fraction := position - low.
	low >= sorted size ifTrue: [ ^ sorted last ].
	^ (sorted at: low) + (fraction * ((sorted at: low + 1) - (sorted at: low)))
]

{ #category : 'accessing' }
BpHistogramBinning >> range [

	^ range
]

{ #category : 'accessing' }
BpHistogramBinning >> range: aCollectionOrNil [
	"Set the lower and upper values (first and last of aCollectionOrNil) covered by equal bins. Without range, the bins cover the data. Ignored when the bins are edges."

	range := aCollectionOrNil
]

{ #category : 'private' }
BpHistogramBinning >> standardDeviation: anArray [
	"Answer the population standard deviation, as numpy.std."

	| mean |
	mean := (anArray inject: 0 into: [ :sum :each | sum + each ]) / anArray size.
	^ ((anArray inject: 0 into: [ :sum :each | sum + (each - mean) squared ]) / anArray size) sqrt
]

{ #category : 'private' }
BpHistogramBinning >> sturgesWidth: anArray [

	^ (self peakToPeak: anArray) / ((anArray size log: 2) + 1)
]
