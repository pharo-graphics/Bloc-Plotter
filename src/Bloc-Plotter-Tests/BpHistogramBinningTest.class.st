"
I test `BpHistogramBinning` against the results of numpy: edges from a number of bins, a range, explicit edges and bin strategies, counts with half-open and closed bins, weights and densities.
"
Class {
	#name : 'BpHistogramBinningTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testAutoStrategyTakesTheSmallerWidth [
	"Freedman-Diaconis gives a width of 5.95, Sturges 3: auto takes Sturges."

	self assert: ((BpHistogramBinning bins: #auto) edgesFor: (1 to: 16)) size - 1 equals: 5
]

{ #category : 'tests - errors' }
BpHistogramBinningTest >> testDecreasingEdgesRaiseError [

	self should: [ (BpHistogramBinning bins: #( 3 2 1 )) edgesFor: #( 1 2 3 ) ] raise: Error
]

{ #category : 'tests - counts' }
BpHistogramBinningTest >> testDensityIntegratesToOne [

	self assert: (BpHistogramBinning density: #( 1 3 ) in: #( 0 2 4 )) equals: #( 0.125 0.375 )
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testFreedmanDiaconisStrategy [

	self assert: ((BpHistogramBinning bins: #fd) edgesFor: (1 to: 16)) size - 1 equals: 3
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testIntegerBinsAroundASingleValue [

	self assert: ((BpHistogramBinning bins: 2) edgesFor: #( 3 3 )) equals: #( 2.5 3 3.5 )
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testIntegerBinsSpanTheData [

	self assert: ((BpHistogramBinning bins: 4) edgesFor: #( 1 2 3 4 5 )) equals: #( 1 2 3 4 5 )
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testIntegerBinsSpanTheRange [

	self
		assert: ((BpHistogramBinning bins: 5)
			 range: #( 0 10 );
			 edgesFor: #( 3 4 ))
		equals: #( 0 2 4 6 8 10 )
]

{ #category : 'tests - counts' }
BpHistogramBinningTest >> testLastBinIsClosed [

	self assert: (BpHistogramBinning countsOf: #( 1 2 3 4 5 ) weights: nil in: #( 1 2 3 4 5 )) equals: #( 1 1 1 2 )
]

{ #category : 'tests - counts' }
BpHistogramBinningTest >> testOtherBinsAreHalfOpen [

	self assert: (BpHistogramBinning countsOf: #( 0 0.5 1 2.9 3 ) weights: nil in: #( 0 1 3 )) equals: #( 2 3 )
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testRiceStrategy [

	self assert: ((BpHistogramBinning bins: #rice) edgesFor: (1 to: 16)) size - 1 equals: 6
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testScottStrategy [

	self assert: ((BpHistogramBinning bins: #scott) edgesFor: (1 to: 16)) size - 1 equals: 3
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testSequenceBinsAreTheEdges [

	self assert: ((BpHistogramBinning bins: #( 100 150 180 )) edgesFor: #( 1 2 )) equals: #( 100 150 180 )
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testSqrtStrategy [

	self assert: ((BpHistogramBinning bins: #sqrt) edgesFor: (1 to: 16)) size - 1 equals: 4
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testStrategyEdgesAreEquallySpaced [

	| edges |
	edges := (BpHistogramBinning bins: #sturges) edgesFor: (1 to: 16).
	self assert: edges first equals: 1.
	self assert: edges last equals: 16.
	self assert: edges second equals: 4
]

{ #category : 'tests - errors' }
BpHistogramBinningTest >> testStrategyWithWeightsRaisesError [

	self should: [ (BpHistogramBinning bins: #auto) edgesFor: #( 1 2 3 ) weights: #( 1 1 1 ) ] raise: Error
]

{ #category : 'tests - edges' }
BpHistogramBinningTest >> testSturgesStrategy [

	self assert: ((BpHistogramBinning bins: #sturges) edgesFor: (1 to: 16)) size - 1 equals: 5
]

{ #category : 'tests - errors' }
BpHistogramBinningTest >> testUnknownStrategyRaisesError [

	self should: [ (BpHistogramBinning bins: #unknown) edgesFor: #( 1 2 3 ) ] raise: Error
]

{ #category : 'tests - counts' }
BpHistogramBinningTest >> testValuesOutsideTheEdgesAreIgnored [

	self assert: (BpHistogramBinning countsOf: #( -1 1 11 ) weights: nil in: #( 0 5 10 )) equals: #( 1 0 )
]

{ #category : 'tests - counts' }
BpHistogramBinningTest >> testWeightsReplaceTheCount [

	self assert: (BpHistogramBinning countsOf: #( 1 2 ) weights: #( 0.5 2 ) in: #( 0 3 )) equals: #( 2.5 )
]
