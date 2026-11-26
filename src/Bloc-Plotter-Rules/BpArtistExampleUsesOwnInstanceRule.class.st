"
I am a Renraku rule checking that the examples of an artist are built on its own instances: an `example…` method on the class side of a subclass of `BpArtist` must send, to `self` or to its class, at least one `instance…` method that its class defines. A plot is documented by the class of its artists, not by `BpFigure` or `BpChart`, whose instances are optional.

## Examples

```
BpArtistExampleUsesOwnInstanceRule exampleExamplesBreakingTheRule
```

## Design Rationale

- The rule is about where the instances used by an example are defined, not how many there are: one instance of the class is enough, whatever else the example builds (charts, figures, other artists).
- An example is a class-side method whose selector starts with `example` or that has the `<example>` pragma; an instance method is a method whose selector starts with `instance` or that has the `<sampleInstance>` pragma, as the conventions of the package name them.
- The instance must be defined by the class itself (`includesSelector:`): an inherited one does not document it.
- The receiver must be `self` or the class itself: `BpChart instanceLinePlotType` does not count even when the artist class defines a method with the same selector.

## Usage

1. Renraku creates me, as every rule whose class answers true to `checksMethod`, and runs me on the methods it criticizes (for instance `ReCriticEngine critiquesOf: aMethod`); I am in the group Bloc-Plotter.
2. Renraku sends me `basicCheck:` with a compiled method, and reports a critique when I answer true.

- I hold no state between checks.

## Implementation Notes

- Renraku caches its rules: after loading me in a running image, `ReRuleManager reset` makes me run.
"
Class {
	#name : 'BpArtistExampleUsesOwnInstanceRule',
	#superclass : 'ReAbstractRule',
	#category : 'Bloc-Plotter-Rules',
	#package : 'Bloc-Plotter-Rules'
}

{ #category : 'testing - interest' }
BpArtistExampleUsesOwnInstanceRule class >> checksMethod [

	^ true
]

{ #category : 'examples' }
BpArtistExampleUsesOwnInstanceRule class >> exampleExamplesBreakingTheRule [
	"Inspect the examples of the artists that do not use an instance method of their class."

	<example>
	| rule |
	rule := self instanceRule.
	^ ((BpArtist withAllSubclasses flatCollect: [ :each | each class methods ]) select: [ :each | rule basicCheck: each ]) inspect
]

{ #category : 'accessing' }
BpArtistExampleUsesOwnInstanceRule class >> group [

	^ 'Bloc-Plotter'
]

{ #category : 'instances' }
BpArtistExampleUsesOwnInstanceRule class >> instanceRule [
	"Answer the rule, ready to check methods with basicCheck:."

	<sampleInstance>
	^ self new
]

{ #category : 'manifest' }
BpArtistExampleUsesOwnInstanceRule class >> uniqueIdentifierName [
	"This name should be unique and should change only when the rule completely changes semantics."

	^ 'BpArtistExampleUsesOwnInstanceRule'
]

{ #category : 'running' }
BpArtistExampleUsesOwnInstanceRule >> basicCheck: aMethod [
	"Answer whether aMethod is an example of an artist that sends no instance method of its class."

	^ (self isArtistExample: aMethod) and: [ (self usesAnInstanceOfItsClass: aMethod) not ]
]

{ #category : 'private - testing' }
BpArtistExampleUsesOwnInstanceRule >> isArtistExample: aMethod [
	"Answer whether aMethod is a class-side example of an artist: its selector starts with example, or it has the example pragma."

	| class |
	class := aMethod methodClass.
	class isClassSide ifFalse: [ ^ false ].
	(class instanceSide includesBehavior: BpArtist) ifFalse: [ ^ false ].
	^ (aMethod selector beginsWith: 'example') or: [ aMethod hasPragmaNamed: #example ]
]

{ #category : 'private - testing' }
BpArtistExampleUsesOwnInstanceRule >> isClass: aMetaclass receiverOf: aMessageNode [
	"Answer whether aMessageNode is sent to self or to the class of aMetaclass, named by its global."

	| receiver |
	receiver := aMessageNode receiver.
	receiver isSelfVariable ifTrue: [ ^ true ].
	^ receiver isGlobalVariable and: [ receiver variable value == aMetaclass instanceSide ]
]

{ #category : 'private - testing' }
BpArtistExampleUsesOwnInstanceRule >> isInstanceMethod: aMethod [
	"Answer whether aMethod answers a sample instance: its selector starts with instance, or it has the sampleInstance pragma."

	^ (aMethod selector beginsWith: 'instance') or: [ aMethod hasPragmaNamed: #sampleInstance ]
]

{ #category : 'accessing' }
BpArtistExampleUsesOwnInstanceRule >> rationale [

	^ 'The examples of an artist (a subclass of BpArtist) document it: they build their charts and figures on the instance methods (instance... or <sampleInstance>) that the artist class defines, not on instances of BpFigure or BpChart.'
]

{ #category : 'accessing' }
BpArtistExampleUsesOwnInstanceRule >> ruleName [

	^ 'Example of an artist without an instance method of its class'
]

{ #category : 'private - testing' }
BpArtistExampleUsesOwnInstanceRule >> usesAnInstanceOfItsClass: aMethod [
	"Answer whether aMethod sends, to itself or to its class, an instance method that its class defines."

	| class |
	class := aMethod methodClass.
	^ aMethod ast sendNodes anySatisfy: [ :node |
		  (self isClass: class receiverOf: node) and: [
			  (class includesSelector: node selector) and: [ self isInstanceMethod: class >> node selector ] ] ]
]
