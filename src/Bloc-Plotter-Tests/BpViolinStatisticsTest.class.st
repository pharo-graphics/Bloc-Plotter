"
I check `BpViolinStatistics`: the coordinates, the densities with each bandwidth rule, the factor, the mean, median, extrema and quantiles.

## Implementation Notes

- The expected densities were computed separately with the kernel density formula, to 1e-9.
"
Class {
	#name : 'BpViolinStatisticsTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpViolinStatisticsTest >> assertDensities: someNumbers equal: expectedNumbers [

	self assert: someNumbers size equals: expectedNumbers size.
	someNumbers with: expectedNumbers do: [ :each :expected | self assert: (each closeTo: expected precision: 1.0e-9) ]
]

{ #category : 'tests' }
BpViolinStatisticsTest >> statisticsOf: aCollection bandwidth: aBandwidth [

	^ BpViolinStatistics
		  of: aCollection
		  points: 3
		  bandwidth: aBandwidth
		  quantiles: #(  )
]

{ #category : 'tests' }
BpViolinStatisticsTest >> testCoordinatesSpanTheValuesEvenly [

	self
		assert: (BpViolinStatistics
			 of: #( 0 2 )
			 points: 5
			 bandwidth: #scott
			 quantiles: #(  )) coordinates asArray
		equals: #( 0 0.5 1 1.5 2 )
]

{ #category : 'tests - errors' }
BpViolinStatisticsTest >> testEqualValuesRaiseError [

	self should: [ self statisticsOf: #( 2 2 2 ) bandwidth: #scott ] raise: Error
]

{ #category : 'tests' }
BpViolinStatisticsTest >> testNumberBandwidthIsTheFactor [

	| statistics |
	statistics := self statisticsOf: #( 1 2 3 10 ) bandwidth: 0.5.
	self assert: statistics factor equals: 0.5.
	self assertDensities: statistics densities equal: #( 0.12243225350544042 0.04291716889003619 0.049022312345767025 )
]

{ #category : 'tests' }
BpViolinStatisticsTest >> testQuantilesInterpolateTheSortedValues [

	self
		assertDensities: (BpViolinStatistics
			 of: #( 5 1 4 2 3 )
			 points: 3
			 bandwidth: #scott
			 quantiles: #( 0.25 0.75 0.1 )) quantiles
		equal: #( 2 4 1.4 )
]

{ #category : 'tests' }
BpViolinStatisticsTest >> testScottDensities [

	self
		assertDensities: (BpViolinStatistics
			 of: #( 0 2 )
			 points: 3
			 bandwidth: #scott
			 quantiles: #(  )) densities
		equal: #( 0.20532372038914984 0.23299001857548163 0.20532372038914984 )
]

{ #category : 'tests' }
BpViolinStatisticsTest >> testScottFactor [

	self assert: ((self statisticsOf: #( 1 2 3 10 ) bandwidth: #scott) factor closeTo: 4 ** -0.2)
]

{ #category : 'tests' }
BpViolinStatisticsTest >> testSilvermanDensities [

	self
		assertDensities: (self statisticsOf: #( 1 2 3 10 ) bandwidth: #silverman) densities
		equal: #( 0.08544564879573494 0.06366673096176025 0.03578980604439308 )
]

{ #category : 'tests' }
BpViolinStatisticsTest >> testSummaryValues [

	| statistics |
	statistics := self statisticsOf: #( 10 1 3 2 ) bandwidth: #scott.
	self assert: statistics mean equals: 4.
	self assert: statistics median equals: 5 / 2.
	self assert: statistics minimum equals: 1.
	self assert: statistics maximum equals: 10
]

{ #category : 'tests - errors' }
BpViolinStatisticsTest >> testUnknownBandwidthRaisesError [

	self should: [ self statisticsOf: #( 1 2 ) bandwidth: #wide ] raise: Error
]
