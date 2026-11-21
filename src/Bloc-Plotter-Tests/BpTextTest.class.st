"
I check that `BpText` shows one line per line break and that a `BpAxes` title uses it.
"
Class {
	#name : 'BpTextTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpTextTest >> testAxesTitleWithALineBreakHasTwoLines [

	| axes |
	axes := BpAxes new.
	axes title: (String cr join: #( 'a' 'b' )).
	self assert: axes titleElement children size equals: 2.
	self assert: axes title equals: (String cr join: #( 'a' 'b' ))
]

{ #category : 'tests' }
BpTextTest >> testOneLinePerLineBreak [

	| text |
	text := BpText new
		        text: (String cr join: #( 'change outlier' 'point symbols' )) asRopedText;
		        yourself.
	self assert: (text children collect: [ :each | each text asString ] as: Array) equals: #( 'change outlier' 'point symbols' )
]

{ #category : 'tests' }
BpTextTest >> testTextWithoutLineBreakIsOneLine [

	self
		assert: (BpText new
			 text: 'title' asRopedText;
			 yourself) children size
		equals: 1
]
