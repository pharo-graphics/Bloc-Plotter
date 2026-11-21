"
I test `BpColors`: the color cycle, named colors and the viridis colormap.
"
Class {
	#name : 'BpColorsTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpColorsTest >> testCommonCssNames [

	self assert: (BpColors named: 'black') equals: Color black.
	self assert: (BpColors named: 'white') equals: Color white.
	self assert: (BpColors named: 'orange') equals: (Color fromHexString: 'ffa500')
]

{ #category : 'tests' }
BpColorsTest >> testCycleNamesIndexTheColorCycle [

	self assert: (BpColors named: 'C0') equals: BpColors tab10 first.
	self assert: (BpColors named: 'C9') equals: BpColors tab10 last
]

{ #category : 'tests' }
BpColorsTest >> testNamedColor [

	self assert: (BpColors named: 'g') equals: (Color fromHexString: '008000')
]

{ #category : 'tests' }
BpColorsTest >> testTab10StartsWithBlueAndOrange [

	self assert: (BpColors tab10 first: 2) equals: {
		(Color fromHexString: '1f77b4').
		(Color fromHexString: 'ff7f0e') }
]

{ #category : 'tests' }
BpColorsTest >> testTableauNamesAreTheColorCycle [

	self
		assert:
			(#( 'tab:blue' 'tab:orange' 'tab:green' 'tab:red' 'tab:purple' 'tab:brown' 'tab:pink' 'tab:gray' 'tab:olive' 'tab:cyan' )
				 collect: [ :each | BpColors named: each ])
		equals: BpColors tab10 asArray
]

{ #category : 'tests' }
BpColorsTest >> testViridisEnds [

	self assert: (BpColors viridis: 0) equals: (Color fromHexString: '440154').
	self assert: (BpColors viridis: 1) equals: (Color fromHexString: 'fde725')
]

{ #category : 'tests' }
BpColorsTest >> testViridisInterpolates [

	| middle |
	middle := BpColors viridis: 0.05.
	self assert: middle red closeTo: (Color fromHexString: '440154') red + (Color fromHexString: '482475') red / 2 precision: 0.01
]
