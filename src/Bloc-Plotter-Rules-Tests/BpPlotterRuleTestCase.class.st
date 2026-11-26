"
I am the common superclass of the tests of the Renraku rules of Bloc-Plotter. My `setUp` builds fixture classes in a private environment, so that nothing is installed: a subclass of `BpArtist`, a subclass of `BpChart` and a class that is neither. Their methods are compiled without logging (`compile:in:`) and checked by the rule my subclass names (`ruleClass`) with `isReported:in:`.
"
Class {
	#name : 'BpPlotterRuleTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'artistClass',
		'chartClass',
		'otherClass',
		'rule'
	],
	#category : 'Bloc-Plotter-Rules-Tests',
	#package : 'Bloc-Plotter-Rules-Tests'
}

{ #category : 'testing' }
BpPlotterRuleTestCase class >> isAbstract [

	^ self == BpPlotterRuleTestCase
]

{ #category : 'private' }
BpPlotterRuleTestCase >> compile: aSource in: aBehavior [
	"Compile aSource in aBehavior without logging it, and answer the method."

	| selector |
	selector := aBehavior
		            compile: aSource
		            classified: #fixture
		            withStamp: nil
		            logSource: false.
	^ aBehavior >> selector
]

{ #category : 'private' }
BpPlotterRuleTestCase >> isReported: aSource in: aBehavior [

	^ rule basicCheck: (self compile: aSource in: aBehavior)
]

{ #category : 'private' }
BpPlotterRuleTestCase >> ruleClass [
	"Answer the class of the rule my tests check."

	^ self subclassResponsibility
]

{ #category : 'running' }
BpPlotterRuleTestCase >> setUp [

	| environment |
	super setUp.
	environment := SystemEnvironment new.
	environment codeChangeAnnouncer: Announcer new.
	environment at: #FixedLayout put: FixedLayout.
	artistClass := (BpArtist << #BpFixtureArtist)
		               environment: environment;
		               build.
	chartClass := (BpChart << #BpFixtureChart)
		              environment: environment;
		              build.
	otherClass := (Object << #BpFixtureObject)
		              environment: environment;
		              build.
	environment
		at: #BpFixtureArtist put: artistClass;
		at: #BpChart put: BpChart;
		at: #BpBarPlot put: BpBarPlot.
	self
		compile: 'instanceOne
	^ self new'
		in: artistClass class.
	rule := self ruleClass new
]
