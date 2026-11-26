"
I check `BpChartPlottingMessageRule` on the fixture classes of `BpPlotterRuleTestCase`.
"
Class {
	#name : 'BpChartPlottingMessageRuleTest',
	#superclass : 'BpPlotterRuleTestCase',
	#category : 'Bloc-Plotter-Rules-Tests',
	#package : 'Bloc-Plotter-Rules-Tests'
}

{ #category : 'private' }
BpChartPlottingMessageRuleTest >> ruleClass [

	^ BpChartPlottingMessageRule
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testCreationMessageSentToAnArtistClassIsAccepted [

	self deny: (self
		 isReported: 'demo
	^ BpBarPlot barX: #( 1 2 ) height: #( 3 4 )'
		 in: otherClass)
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testCreationMessageSentToSelfOnTheClassSideOfAnArtistIsAccepted [

	self deny: (self
		 isReported: 'instanceTwo
	^ self stem: #( 1 2 )'
		 in: artistClass class)
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testImplementationInAChartIsNotChecked [

	self deny: (self
		 isReported: 'plotTwice
	^ self plotX: #( 1 ) y: #( 2 )'
		 in: chartClass)
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testMethodWithoutPlottingMessageIsAccepted [

	self deny: (self
		 isReported: 'demo
	^ BpChart new title: ''none'''
		 in: otherClass)
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testPlottingMessageInAnExampleOfAnArtistIsReported [

	self assert: (self
		 isReported: 'exampleOne
	| chart |
	chart := BpChart new.
	chart hist: #( 1 2 3 ).
	^ chart'
		 in: artistClass class)
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testPlottingMessageInAnInstanceOfAChartClassIsReported [

	self assert: (self
		 isReported: 'instanceOne
	| chart |
	chart := self new.
	chart scatterX: #( 1 ) y: #( 2 ).
	^ chart'
		 in: chartClass class)
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testPlottingMessageSentToAChartIsReported [

	self assert: (self
		 isReported: 'demo
	^ BpChart new plotX: #( 1 2 ) y: #( 3 4 )'
		 in: otherClass)
]

{ #category : 'tests' }
BpChartPlottingMessageRuleTest >> testRuleIsVisibleToRenraku [

	self assert: (ReRuleManager visibleRuleClasses includes: BpChartPlottingMessageRule)
]
