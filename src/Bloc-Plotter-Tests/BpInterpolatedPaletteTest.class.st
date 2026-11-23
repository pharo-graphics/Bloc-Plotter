"
I test `BpInterpolatedPalette`: the ends of viridis, the interpolation between anchors and the clipping of the fractions.
"
Class {
	#name : 'BpInterpolatedPaletteTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpInterpolatedPaletteTest >> testColorAtInterpolatesBetweenAnchors [

	| middle |
	middle := BpInterpolatedPalette viridis colorAt: 0.05.
	self assert: middle red closeTo: 68 + 72 / 2 / 255 precision: 0.01
]

{ #category : 'tests' }
BpInterpolatedPaletteTest >> testFractionsAreClippedBetweenZeroAndOne [

	| palette |
	palette := BpInterpolatedPalette viridis.
	self assert: (palette colorAt: -1) equals: (palette colorAt: 0).
	self assert: (palette colorAt: 2) equals: (palette colorAt: 1)
]

{ #category : 'tests' }
BpInterpolatedPaletteTest >> testSampleColorsAreEvenlySpacedFromEndToEnd [

	| palette samples |
	palette := BpInterpolatedPalette viridis.
	samples := palette sampleColors: 15.
	self assert: samples size equals: 15.
	self assert: samples first equals: (palette colorAt: 0).
	self assert: (samples at: 8) equals: (palette colorAt: 0.5).
	self assert: samples last equals: (palette colorAt: 1)
]

{ #category : 'tests' }
BpInterpolatedPaletteTest >> testViridisEnds [

	self assert: (BpInterpolatedPalette viridis colorAt: 0) equals: (Color
		 r: 68
		 g: 1
		 b: 84
		 range: 255).
	self assert: (BpInterpolatedPalette viridis colorAt: 1) equals: (Color
		 r: 253
		 g: 231
		 b: 37
		 range: 255)
]
