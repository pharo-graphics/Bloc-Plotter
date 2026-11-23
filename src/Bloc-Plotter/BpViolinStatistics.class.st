"
I am the summary of one dataset that a `BpViolinPlot` draws: its Gaussian kernel density estimate (`densities`) at `coordinates` evenly spaced from its `minimum` to its `maximum`, its `mean`, its `median` and the `quantiles` asked for.

## Examples

```
BpViolinStatistics instanceTwoGroups
```

## Design Rationale

- The densities and the rules of their bandwidth are the ones of `BpKernelDensity`.
- Quantiles interpolate linearly between the two closest sorted values, as the quartiles of a box plot do (`BpBoxStatistics class>>percentile:of:`).

## Usage

1. `BpViolinPlot>>compute` creates one instance per dataset with `of:points:bandwidth:quantiles:`, each time the violins change.
2. `BpViolinPlot` reads it to build the body and the lines of a violin; `BpViolinPlot>>statistics` answers them.

Instances are not changed after their creation.

## Invariants and Assumptions

- The values hold at least two different numbers: equal values have no deviation, and creation raises an error.
"
Class {
	#name : 'BpViolinStatistics',
	#superclass : 'Object',
	#instVars : [
		'kernelDensity',
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

{ #category : 'instances' }
BpViolinStatistics class >> instanceTwoGroups [
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

{ #category : 'accessing' }
BpViolinStatistics >> factor [
	"Answer by what the standard deviation is multiplied to get the width of the kernel."

	^ kernelDensity factor
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
	sorted := aCollectionOfNumbers asArray sorted.
	minimum := sorted first.
	maximum := sorted last.
	minimum = maximum ifTrue: [ ^ self error: 'A violin needs at least two different values' ].
	mean := sorted sum / sorted size.
	median := BpBoxStatistics percentile: 50 of: sorted.
	quantiles := aCollectionOfFractions asArray collect: [ :each | BpBoxStatistics percentile: each * 100 of: sorted ].
	kernelDensity := BpKernelDensity of: sorted bandwidth: aSymbolOrNumber.
	coordinates := BpArtist linspaceFrom: minimum to: maximum count: anInteger.
	densities := coordinates collect: [ :each | kernelDensity densityAt: each ]
]
