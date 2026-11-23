"
I am the summary of one dataset that a `BpViolinPlot` draws: its Gaussian kernel density estimate (`densities`) at `coordinates` evenly spaced from its `minimum` to its `maximum`, its `mean`, its `median` and the `quantiles` asked for.

## Examples

```
BpViolinStatistics exampleTwoGroups
```

## Design Rationale

- The kernel is a normal density whose deviation is the sample standard deviation of the values times a `factor`: Scott's rule n^(-1/5) (#scott, the default), Silverman's rule (3n/4)^(-1/5) (#silverman), or a given number. A larger factor gives a smoother shape.
- Quantiles interpolate linearly between the two closest sorted values, as the quartiles of a box plot do (`BpBoxStatistics class>>percentile:of:`).

## Usage

1. `BpViolinPlot>>compute` creates one instance per dataset with `of:points:bandwidth:quantiles:`, each time the violins change.
2. `BpViolinPlot` reads it to build the body and the lines of a violin; `BpViolinPlot>>statistics` answers them.

Instances are not changed after their creation.

## Implementation Notes

- The densities are computed directly, by summing one kernel per value at each coordinate: n values at p points cost n·p evaluations, which is fine for the size of plotted data.

## Invariants and Assumptions

- The values hold at least two different numbers: equal values have no deviation, and creation raises an error.
"
Class {
	#name : 'BpViolinStatistics',
	#superclass : 'Object',
	#instVars : [
		'values',
		'factor',
		'coordinates',
		'densities',
		'mean',
		'median',
		'minimum',
		'maximum',
		'quantiles'
	],
	#category : 'Bloc-Plotter-Violin',
	#package : 'Bloc-Plotter',
	#tag : 'Violin'
}

{ #category : 'examples' }
BpViolinStatistics class >> exampleTwoGroups [
	"Answer the statistics of values gathered in two groups, around 1 and around 5, estimated at 50 points with Scott's rule."

	<sampleInstance>
	^ self
		  of: #( 0.5 1 1 1.5 2 4 4.5 5 5 5.5 6 )
		  points: 50
		  bandwidth: #scott
		  quantiles: #( 0.25 0.75 )
]

{ #category : 'instance creation' }
BpViolinStatistics class >> of: aCollectionOfNumbers points: anInteger bandwidth: aSymbolOrNumber quantiles: aCollectionOfFractions [
	"Answer the statistics of a violin: the kernel density estimate of aCollectionOfNumbers at anInteger points evenly spaced from its minimum to its maximum, with the bandwidth rule #scott, #silverman or a number as factor, and the quantiles at aCollectionOfFractions (between 0 and 1)."

	^ self new
		  setValues: aCollectionOfNumbers
		  points: anInteger
		  bandwidth: aSymbolOrNumber
		  quantiles: aCollectionOfFractions;
		  yourself
]

{ #category : 'accessing' }
BpViolinStatistics >> coordinates [

	^ coordinates
]

{ #category : 'accessing' }
BpViolinStatistics >> densities [

	^ densities
]

{ #category : 'private - computing' }
BpViolinStatistics >> densitiesAt: someCoordinates [
	"Answer the Gaussian kernel density estimate of my values at someCoordinates: the mean of normal densities centered on each value, whose deviation is the sample standard deviation of the values times my factor."

	| deviation scale |
	deviation := ((values inject: 0 into: [ :sum :each | sum + (each - mean) squared ]) / (values size - 1)) sqrt * factor.
	scale := values size * deviation * (2 * Float pi) sqrt.
	^ someCoordinates collect: [ :x |
		  (values inject: 0 into: [ :sum :each | sum + ((x - each / deviation) squared / -2) exp ]) / scale ]
]

{ #category : 'accessing' }
BpViolinStatistics >> factor [

	^ factor
]

{ #category : 'private - computing' }
BpViolinStatistics >> factorFor: aSymbolOrNumber [
	"Answer the factor of the standard deviation giving the kernel width: Scott's rule n^(-1/5), Silverman's rule (3n/4)^(-1/5), or the given number."

	aSymbolOrNumber isNumber ifTrue: [ ^ aSymbolOrNumber ].
	aSymbolOrNumber = #scott ifTrue: [ ^ values size ** -0.2 ].
	aSymbolOrNumber = #silverman ifTrue: [ ^ values size * 3 / 4 ** -0.2 ].
	^ self error: 'Unknown bandwidth: ' , aSymbolOrNumber printString
]

{ #category : 'accessing' }
BpViolinStatistics >> maximum [

	^ maximum
]

{ #category : 'accessing' }
BpViolinStatistics >> mean [

	^ mean
]

{ #category : 'accessing' }
BpViolinStatistics >> median [

	^ median
]

{ #category : 'accessing' }
BpViolinStatistics >> minimum [

	^ minimum
]

{ #category : 'accessing' }
BpViolinStatistics >> quantiles [

	^ quantiles
]

{ #category : 'private - computing' }
BpViolinStatistics >> setValues: aCollectionOfNumbers points: anInteger bandwidth: aSymbolOrNumber quantiles: aCollectionOfFractions [

	| sorted |
	values := aCollectionOfNumbers asArray.
	sorted := values sorted.
	minimum := sorted first.
	maximum := sorted last.
	minimum = maximum ifTrue: [ ^ self error: 'A violin needs at least two different values' ].
	mean := values sum / values size.
	median := BpBoxStatistics percentile: 50 of: sorted.
	quantiles := aCollectionOfFractions asArray collect: [ :each | BpBoxStatistics percentile: each * 100 of: sorted ].
	factor := self factorFor: aSymbolOrNumber.
	coordinates := BpArtist linspaceFrom: minimum to: maximum count: anInteger.
	densities := self densitiesAt: coordinates
]
