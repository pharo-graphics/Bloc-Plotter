"
I test `BpKernelDensity`: the rules of its bandwidth and the densities it estimates.
"
Class {
	#name : 'BpKernelDensityTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpKernelDensityTest >> testBandwidthIsTheFactorOfTheSampleDeviation [

	self assert: ((BpKernelDensity of: #( 0 2 ) bandwidth: 0.5) bandwidth closeTo: 2 sqrt / 2)
]

{ #category : 'tests' }
BpKernelDensityTest >> testDensityAt [

	self assert: ((BpKernelDensity of: #( 0 2 ) bandwidth: #scott) densityAt: 0) closeTo: 0.20532372038914984 precision: 1.0e-9
]

{ #category : 'tests' }
BpKernelDensityTest >> testDensityIntegratesToOne [

	| density |
	density := BpKernelDensity of: #( 1 2 3 10 ) bandwidth: #scott.
	self
		assert: ((-30 to: 40 by: 0.1) inject: 0 into: [ :sum :each | (density densityAt: each) * 0.1 + sum ])
		closeTo: 1
		precision: 1.0e-3
]

{ #category : 'tests - errors' }
BpKernelDensityTest >> testEqualValuesRaiseError [

	self
		should: [ BpKernelDensity of: #( 2 2 2 ) bandwidth: #scott ]
		raise: Error
		whoseDescriptionIncludes: 'two different values'
		description: 'equal values have no deviation'
]

{ #category : 'tests - errors' }
BpKernelDensityTest >> testNoValuesRaiseError [

	self
		should: [ BpKernelDensity of: #(  ) bandwidth: #scott ]
		raise: Error
		whoseDescriptionIncludes: 'two different values'
		description: 'there is no value'
]

{ #category : 'tests' }
BpKernelDensityTest >> testNumberIsTheFactor [

	self assert: (BpKernelDensity of: #( 1 2 3 10 ) bandwidth: 0.5) factor equals: 0.5
]

{ #category : 'tests' }
BpKernelDensityTest >> testScottFactor [

	self assert: ((BpKernelDensity of: #( 1 2 3 10 ) bandwidth: #scott) factor closeTo: 4 ** -0.2)
]

{ #category : 'tests' }
BpKernelDensityTest >> testSilvermanFactor [

	self assert: ((BpKernelDensity of: #( 1 2 3 10 ) bandwidth: #silverman) factor closeTo: 3 ** -0.2)
]

{ #category : 'tests - errors' }
BpKernelDensityTest >> testUnknownBandwidthRaisesError [

	self
		should: [ BpKernelDensity of: #( 1 2 ) bandwidth: #wide ]
		raise: Error
		whoseDescriptionIncludes: 'Unknown bandwidth'
		description: 'the rule is unknown'
]
