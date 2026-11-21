"
I test the `Random` extensions of Bloc-Plotter, `Random>>nextNormal` and `Random>>nextNormalMean:deviation:`: the mean, the deviation and the bell shape of many samples, and the same samples for the same seed.
"
Class {
	#name : 'BpRandomNormalTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'private' }
BpRandomNormalTest >> deviationOf: aCollection [

	| mean |
	mean := self meanOf: aCollection.
	^ ((aCollection inject: 0 into: [ :sum :each | sum + (each - mean) squared ]) / aCollection size) sqrt
]

{ #category : 'private' }
BpRandomNormalTest >> meanOf: aCollection [

	^ (aCollection inject: 0 into: [ :sum :each | sum + each ]) / aCollection size
]

{ #category : 'tests' }
BpRandomNormalTest >> testNextNormalFollowsTheBellCurve [
	"About 68% of normal samples are within one deviation of the mean, 95% within two."

	| random samples |
	random := Random seed: 42.
	samples := (1 to: 20000) collect: [ :each | random nextNormal ].
	self assert: ((samples count: [ :each | each abs < 1 ]) / samples size closeTo: 0.6827 precision: 0.02).
	self assert: ((samples count: [ :each | each abs < 2 ]) / samples size closeTo: 0.9545 precision: 0.01)
]

{ #category : 'tests' }
BpRandomNormalTest >> testNextNormalHasMeanZeroAndDeviationOne [

	| random samples |
	random := Random seed: 42.
	samples := (1 to: 20000) collect: [ :each | random nextNormal ].
	self assert: (self meanOf: samples) abs < 0.03.
	self assert: ((self deviationOf: samples) closeTo: 1 precision: 0.03)
]

{ #category : 'tests' }
BpRandomNormalTest >> testNextNormalIsReproducibleWithASeed [

	| first second |
	first := Random seed: 19680801.
	second := Random seed: 19680801.
	self assert: ((1 to: 10) collect: [ :each | first nextNormal ]) equals: ((1 to: 10) collect: [ :each | second nextNormal ])
]

{ #category : 'tests' }
BpRandomNormalTest >> testNextNormalMeanDeviationScalesTheSamples [

	| random samples |
	random := Random seed: 42.
	samples := (1 to: 20000) collect: [ :each | random nextNormalMean: 200 deviation: 25 ].
	self assert: ((self meanOf: samples) closeTo: 200 precision: 1).
	self assert: ((self deviationOf: samples) closeTo: 25 precision: 1)
]
