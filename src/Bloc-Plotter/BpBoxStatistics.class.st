"
I am the summary of one dataset that a box plot draws, matplotlib `cbook.boxplot_stats`: the quartiles (`q1`, `median`, `q3`), the `mean`, the whisker ends (`whiskerLow`, `whiskerHigh`), the `fliers` beyond them, and the confidence interval of the median used by notches (`confidenceLow`, `confidenceHigh`).

## Examples

```
BpBoxStatistics exampleWithOutlier
```

## Design Rationale

- Percentiles use linear interpolation between the closest ranks (`percentile:of:`), the numpy default used by matplotlib, so the boxes match those of matplotlib.
- Whiskers are given as a factor of the interquartile range (1.5 by default) or a pair of percentiles. A whisker ends on the most extreme datum within its limit, not on the limit; with no datum there, it stays on the quartile.
- The notch is the median plus or minus 1.57 interquartile ranges divided by the square root of the size.

## Usage

1. `BpBoxPlot>>compute` creates me with `of:whiskers:`, once per dataset, at each rebuild of the box plot.
2. `BpBoxPlot` reads my values to place its parts; `BpBoxPlot>>statistics` hands me to its users, for instance to show the numbers of a clicked box.

- I am computed once when created and never change afterwards.

## Invariants and Assumptions

- I keep my values sorted. `whiskerLow <= q1 <= median <= q3 <= whiskerHigh`, and every flier is outside the whiskers.
- A dataset without any value is rejected with an error.
"
Class {
	#name : 'BpBoxStatistics',
	#superclass : 'Object',
	#instVars : [
		'values',
		'median',
		'q1',
		'q3',
		'whiskerLow',
		'whiskerHigh',
		'fliers',
		'mean',
		'confidenceLow',
		'confidenceHigh'
	],
	#category : 'Bloc-Plotter-Box',
	#package : 'Bloc-Plotter',
	#tag : 'Box'
}

{ #category : 'computing' }
BpBoxStatistics class >> defaultWhiskers [

	^ 1.5
]

{ #category : 'examples' }
BpBoxStatistics class >> exampleWithOutlier [
	"Answer the statistics of 1 to 9 and an outlier, 100, beyond the upper whisker."

	<sampleInstance>
	^ self of: #( 1 2 3 4 5 6 7 8 9 100 )
]

{ #category : 'instance creation' }
BpBoxStatistics class >> of: aCollectionOfNumbers [
	"Answer the statistics of a box plot of aCollectionOfNumbers, with whiskers reaching 1.5 times the interquartile range (Tukey, the matplotlib default)."

	^ self of: aCollectionOfNumbers whiskers: self defaultWhiskers
]

{ #category : 'instance creation' }
BpBoxStatistics class >> of: aCollectionOfNumbers whiskers: aNumberOrPair [
	"Answer the statistics of a box plot of aCollectionOfNumbers (matplotlib cbook.boxplot_stats). aNumberOrPair is matplotlib whis: a number of interquartile ranges, or the two percentiles where the whiskers end."

	aCollectionOfNumbers isEmpty ifTrue: [ ^ self error: 'A box plot needs at least one value' ].
	^ self new
		  setValues: aCollectionOfNumbers asArray sorted whiskers: aNumberOrPair;
		  yourself
]

{ #category : 'computing' }
BpBoxStatistics class >> percentile: aNumber of: aSortedArray [
	"Answer the aNumber-th percentile of aSortedArray, interpolating linearly between its two closest ranks, as numpy percentile."

	| rank low fraction |
	rank := aNumber / 100 * (aSortedArray size - 1).
	low := rank floor.
	fraction := rank - low.
	fraction isZero ifTrue: [ ^ aSortedArray at: low + 1 ].
	^ (aSortedArray at: low + 1) + (fraction * ((aSortedArray at: low + 2) - (aSortedArray at: low + 1)))
]

{ #category : 'accessing' }
BpBoxStatistics >> confidenceHigh [

	^ confidenceHigh
]

{ #category : 'accessing' }
BpBoxStatistics >> confidenceLow [

	^ confidenceLow
]

{ #category : 'accessing' }
BpBoxStatistics >> fliers [

	^ fliers
]

{ #category : 'private - computing' }
BpBoxStatistics >> highestValueBelow: aLimit [
	"Answer the end of the upper whisker: my highest value up to aLimit, or the third quartile when there is none above it."

	^ values reversed detect: [ :each | each <= aLimit ] ifFound: [ :each | each max: q3 ] ifNone: [ q3 ]
]

{ #category : 'accessing' }
BpBoxStatistics >> iqr [
	"Answer the interquartile range, from the first to the third quartile."

	^ q3 - q1
]

{ #category : 'private - computing' }
BpBoxStatistics >> lowestValueAbove: aLimit [
	"Answer the end of the lower whisker: my lowest value from aLimit on, or the first quartile when there is none below it."

	^ values detect: [ :each | each >= aLimit ] ifFound: [ :each | each min: q1 ] ifNone: [ q1 ]
]

{ #category : 'accessing' }
BpBoxStatistics >> mean [

	^ mean
]

{ #category : 'accessing' }
BpBoxStatistics >> median [

	^ median
]

{ #category : 'accessing' }
BpBoxStatistics >> percentile: aNumber [
	"Answer the aNumber-th percentile of my values."

	^ self class percentile: aNumber of: values
]

{ #category : 'accessing' }
BpBoxStatistics >> q1 [

	^ q1
]

{ #category : 'accessing' }
BpBoxStatistics >> q3 [

	^ q3
]

{ #category : 'initialization' }
BpBoxStatistics >> setValues: aSortedArray whiskers: aNumberOrPair [

	| limits |
	values := aSortedArray.
	q1 := self percentile: 25.
	median := self percentile: 50.
	q3 := self percentile: 75.
	mean := values sum / values size.
	confidenceLow := median - (1.57 * self iqr / values size sqrt).
	confidenceHigh := median + (1.57 * self iqr / values size sqrt).
	limits := self whiskerLimitsFor: aNumberOrPair.
	whiskerLow := self lowestValueAbove: limits first.
	whiskerHigh := self highestValueBelow: limits last.
	fliers := values select: [ :each | each < whiskerLow or: [ each > whiskerHigh ] ]
]

{ #category : 'accessing' }
BpBoxStatistics >> values [

	^ values
]

{ #category : 'accessing' }
BpBoxStatistics >> whiskerHigh [

	^ whiskerHigh
]

{ #category : 'private - computing' }
BpBoxStatistics >> whiskerLimitsFor: aNumberOrPair [
	"Answer the lowest and highest values the whiskers may reach: percentiles for a pair, otherwise a factor of the interquartile range beyond the quartiles."

	aNumberOrPair isCollection ifTrue: [
		^ {
			  (self percentile: aNumberOrPair first).
			  (self percentile: aNumberOrPair last) } ].
	^ {
		  (q1 - (aNumberOrPair * self iqr)).
		  (q3 + (aNumberOrPair * self iqr)) }
]

{ #category : 'accessing' }
BpBoxStatistics >> whiskerLow [

	^ whiskerLow
]
