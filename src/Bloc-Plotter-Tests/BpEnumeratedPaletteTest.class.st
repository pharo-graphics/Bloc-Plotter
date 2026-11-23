"
I test `BpEnumeratedPalette` and the factories of its subclasses: the sizes and names of the schemes, the order of their colors, the wrap around of `colorAt:` and the errors for unknown sizes.
"
Class {
	#name : 'BpEnumeratedPaletteTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testColorAtWrapsAround [

	| palette |
	palette := BpQualitativePalette set1.
	self assert: (palette colorAt: palette size + 2) equals: (palette colorAt: 2)
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testColorsAreColors [

	self assert: (BpQualitativePalette set1 colors allSatisfy: [ :each | each isColor ])
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testDefaultIsTab10 [

	self assert: BpPalette default colors equals: BpQualitativePalette tab10 colors
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testDivergingPaletteHasTheAskedSize [

	self assert: ((3 to: 11) allSatisfy: [ :each | (BpDivergingPalette rdbu: each) size = each ])
]

{ #category : 'tests - errors' }
BpEnumeratedPaletteTest >> testDivergingPaletteOfAnUnknownSizeRaisesError [

	self should: [ BpDivergingPalette rdbu: 2 ] raise: Error
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testEverySchemeHasItsSizes [

	self assert: (BpSequentialPalette schemes allSatisfy: [ :each |
		 (3 to: 9) allSatisfy: [ :size | (BpSequentialPalette perform: each with: size) size = size ] ]).
	self assert: (BpDivergingPalette schemes allSatisfy: [ :each |
		 (3 to: 11) allSatisfy: [ :size | (BpDivergingPalette perform: each with: size) size = size ] ])
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testNameIsTheOneOfTheScheme [

	self assert: BpQualitativePalette set1 name equals: 'set1'.
	self assert: (BpSequentialPalette blues: 5) name equals: 'blues'
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testSequentialPaletteGoesFromLightToDark [

	| palette |
	palette := BpSequentialPalette greys: 9.
	self assert: (palette colorAt: 1) equals: Color white.
	self assert: (palette colorAt: 9) equals: Color black
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testSequentialPaletteHasTheAskedSize [

	self assert: ((3 to: 9) allSatisfy: [ :each | (BpSequentialPalette blues: each) size = each ])
]

{ #category : 'tests - errors' }
BpEnumeratedPaletteTest >> testSequentialPaletteOfAnUnknownSizeRaisesError [

	self should: [ BpSequentialPalette blues: 10 ] raise: Error
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testSmallSequentialPaletteIsNotTheStartOfTheLargeOne [

	self deny: (BpSequentialPalette blues: 3) colors equals: ((BpSequentialPalette blues: 9) colors first: 3)
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testTab10StartsWithBlueAndOrange [

	self assert: (BpQualitativePalette tab10 colorAt: 1) equals: (Color
		 r: 31
		 g: 119
		 b: 180
		 range: 255).
	self assert: (BpQualitativePalette tab10 colorAt: 2) equals: (Color
		 r: 255
		 g: 127
		 b: 14
		 range: 255)
]
