"
I am the Gaussian kernel density estimate of a collection of numbers: the mean of normal densities, one centered on each number. `densityAt:` answers it at any number.

## Examples

```
BpKernelDensity instanceTwoGroups
```

## Design Rationale

- The deviation of the normal densities, my `bandwidth`, is the sample standard deviation of the numbers times a `factor`: Scott's rule n^(-1/5) (#scott), Silverman's rule (3n/4)^(-1/5) (#silverman), or a given number. A larger factor gives a smoother curve.

## Usage

1. `BpDensityPlot>>compute` and `BpViolinStatistics` create me with `of:bandwidth:` each time their data or settings change.
2. They send me `densityAt:` for each point of their curves.

Instances are not changed after their creation.

## Implementation Notes

- The densities are computed directly, by summing one kernel per number: n numbers at p points cost n·p evaluations, which is fine for the size of plotted data.

## Invariants and Assumptions

- The numbers hold at least two different ones: equal numbers have no deviation, and creation raises an error.
"
Class {
	#name : 'BpKernelDensity',
	#superclass : 'Object',
	#instVars : [
		'values',
		'factor',
		'deviation'
	],
	#category : 'Bloc-Plotter-Density',
	#package : 'Bloc-Plotter',
	#tag : 'Density'
}

{ #category : 'instances' }
BpKernelDensity class >> instanceTwoGroups [
	"Answer the density of values gathered in two groups, around 1 and around 5, with Scott's rule."

	<sampleInstance>
	^ self of: #( 0.5 1 1 1.5 2 4 4.5 5 5 5.5 6 ) bandwidth: #scott
]

{ #category : 'instance creation' }
BpKernelDensity class >> of: aCollectionOfNumbers bandwidth: aSymbolOrNumber [
	"Answer the Gaussian kernel density estimate of aCollectionOfNumbers, whose kernel width follows the rule #scott or #silverman, or is the sample standard deviation multiplied by a number."

	^ self new
		  setValues: aCollectionOfNumbers bandwidth: aSymbolOrNumber;
		  yourself
]

{ #category : 'accessing' }
BpKernelDensity >> bandwidth [
	"Answer the width of the kernel: the standard deviation of the normal densities."

	^ deviation * factor
]

{ #category : 'estimating' }
BpKernelDensity >> densityAt: aNumber [
	"Answer the density estimated at aNumber: the mean of normal densities, one centered on each value."

	| width |
	width := self bandwidth.
	^ (values inject: 0 into: [ :sum :each | sum + ((aNumber - each / width) squared / -2) exp ])
	  / (values size * width * (2 * Float pi) sqrt)
]

{ #category : 'accessing' }
BpKernelDensity >> factor [
	"Answer by what the sample standard deviation is multiplied to get the width of the kernel."

	^ factor
]

{ #category : 'private - computing' }
BpKernelDensity >> factorFor: aSymbolOrNumber [
	"Answer the factor of the standard deviation giving the kernel width: Scott's rule n^(-1/5), Silverman's rule (3n/4)^(-1/5), or the given number."

	aSymbolOrNumber isNumber ifTrue: [ ^ aSymbolOrNumber ].
	aSymbolOrNumber = #scott ifTrue: [ ^ values size ** -0.2 ].
	aSymbolOrNumber = #silverman ifTrue: [ ^ values size * 3 / 4 ** -0.2 ].
	^ self error: 'Unknown bandwidth: ' , aSymbolOrNumber printString
]

{ #category : 'private - computing' }
BpKernelDensity >> sampleDeviation [

	| mean |
	mean := values sum / values size.
	^ ((values inject: 0 into: [ :sum :each | sum + (each - mean) squared ]) / (values size - 1)) sqrt
]

{ #category : 'private - computing' }
BpKernelDensity >> setValues: aCollectionOfNumbers bandwidth: aSymbolOrNumber [

	values := aCollectionOfNumbers asArray.
	values asSet size > 1 ifFalse: [ ^ self error: 'A density needs at least two different values' ].
	deviation := self sampleDeviation.
	factor := self factorFor: aSymbolOrNumber
]
