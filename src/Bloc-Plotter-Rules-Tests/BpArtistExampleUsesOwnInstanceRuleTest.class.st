"
I check `BpArtistExampleUsesOwnInstanceRule` on the fixture classes of `BpPlotterRuleTestCase`.
"
Class {
	#name : 'BpArtistExampleUsesOwnInstanceRuleTest',
	#superclass : 'BpPlotterRuleTestCase',
	#category : 'Bloc-Plotter-Rules-Tests',
	#package : 'Bloc-Plotter-Rules-Tests'
}

{ #category : 'private' }
BpArtistExampleUsesOwnInstanceRuleTest >> ruleClass [

	^ BpArtistExampleUsesOwnInstanceRule
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testClassSideMethodThatIsNotAnExampleIsNotChecked [

	self deny: (self
		 isReported: 'demoData
	^ BpChart instanceHistogram'
		 in: artistClass class)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testExampleOfAClassThatIsNotAnArtistIsNotChecked [

	self deny: (self
		 isReported: 'exampleOne
	^ BpChart instanceHistogram'
		 in: otherClass class)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testExampleSendingAnInstanceItsClassDoesNotDefineIsReported [

	self assert: (self
		 isReported: 'exampleOne
	^ self instanceUnknown'
		 in: artistClass class)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testExampleSendingAnInstanceToItsClassIsAccepted [

	self deny: (self
		 isReported: 'exampleOne
	^ BpFixtureArtist instanceOne'
		 in: artistClass class)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testExampleSendingAnInstanceToSelfIsAccepted [

	self deny: (self
		 isReported: 'exampleOne
	^ self instanceOne'
		 in: artistClass class)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testExampleUsingOnlyAnInstanceOfAnotherClassIsReported [

	self assert: (self
		 isReported: 'exampleOne
	^ BpChart instanceHistogram'
		 in: artistClass class)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testInstanceSideExampleIsNotChecked [

	self deny: (self
		 isReported: 'exampleOne
	^ BpChart instanceHistogram'
		 in: artistClass)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testMethodWithTheExamplePragmaIsChecked [

	self assert: (self
		 isReported: 'showOne
	<example>
	^ BpChart instanceHistogram'
		 in: artistClass class)
]

{ #category : 'tests' }
BpArtistExampleUsesOwnInstanceRuleTest >> testRuleIsVisibleToRenraku [

	self assert: (ReRuleManager visibleRuleClasses includes: BpArtistExampleUsesOwnInstanceRule)
]
