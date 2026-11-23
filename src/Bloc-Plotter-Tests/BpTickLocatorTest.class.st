"
I test `BpTickLocator`: nice tick steps, log ticks and the decimals of the labels.
"
Class {
	#name : 'BpTickLocatorTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpTickLocatorTest >> testLabelsOfIntegersHaveNoDecimals [

	self assert: (BpTickLocator labelsFor: #( 100 150 200 )) equals: #( '100' '150' '200' )
]

{ #category : 'tests' }
BpTickLocatorTest >> testLabelsOfMultiplesOfTwentyFiveHaveNoDecimals [

	self assert: (BpTickLocator labelsFor: #( 0 25 50 75 )) equals: #( '0' '25' '50' '75' )
]

{ #category : 'tests' }
BpTickLocatorTest >> testLabelsOfTwoAndAHalfStepsKeepTheirDecimal [

	self assert: (BpTickLocator labelsFor: #( 0 2.5 5 )) equals: #( '0.0' '2.5' '5.0' )
]

{ #category : 'tests' }
BpTickLocatorTest >> testLabelsShareTheirDecimals [

	self assert: (BpTickLocator labelsFor: #( 0 0.005 0.01 )) equals: #( '0.000' '0.005' '0.010' )
]

{ #category : 'tests' }
BpTickLocatorTest >> testLogLabels [

	self assert: (BpTickLocator logLabelsFor: #( 1 10 100 0.01 )) equals: #( '10⁰' '10¹' '10²' '10⁻²' )
]

{ #category : 'tests' }
BpTickLocatorTest >> testLogTicksArePowersOfTen [

	self assert: (BpTickLocator logTicksFrom: 0.5 to: 2000) equals: #( 1 10 100 1000 )
]

{ #category : 'tests' }
BpTickLocatorTest >> testStepAtLeastAnswersTheNextNiceStep [

	self assert: (BpTickLocator stepAtLeast: 0.9) equals: 1.
	self assert: (BpTickLocator stepAtLeast: 1.2) equals: 2.
	self assert: (BpTickLocator stepAtLeast: 2.2) equals: 5 / 2.
	self assert: (BpTickLocator stepAtLeast: 30) equals: 50
]

{ #category : 'tests' }
BpTickLocatorTest >> testStepAtLeastKeepsANiceStep [

	self assert: (BpTickLocator stepAtLeast: 5) equals: 5
]

{ #category : 'tests' }
BpTickLocatorTest >> testTicksStayInsideTheLimits [

	self assert: (BpTickLocator linearTicksFrom: 93.5 to: 306.5 count: 5) equals: #( 100 150 200 250 300 )
]

{ #category : 'tests' }
BpTickLocatorTest >> testTicksUseNiceSteps [

	self assert: (BpTickLocator linearTicksFrom: 0 to: 10 count: 5) equals: #( 0 2 4 6 8 10 )
]

{ #category : 'tests' }
BpTickLocatorTest >> testTicksWithTwoAndAHalfSteps [

	self
		assert: (BpTickLocator linearTicksFrom: 0 to: 0.02 count: 8)
		equals: #( 0.0 0.0025 0.005 0.0075 0.01 0.0125 0.015 0.0175 0.02 )
]
