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
BpEnumeratedPaletteTest >> testMdl200GoesFromRedToBlueGrey [

	self assert: BpMDLChartingPalette mdl200 name equals: 'mdl200'.
	self assert: (BpMDLChartingPalette mdl200 colorAt: 1) equals: (BpPalette colorFromTriplet: #( 16rEF 16r9A 16r9A )).
	self assert: (BpMDLChartingPalette mdl200 colorAt: 18) equals: (BpPalette colorFromTriplet: #( 16rEE 16rEE 16rEE )).
	self assert: (BpMDLChartingPalette mdl200 colorAt: 19) equals: (BpPalette colorFromTriplet: #( 16rB0 16rBE 16rC5 ))
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlMixedSchemesAreNamedAfterTheirRow [

	self assert: BpMDLChartingPalette mdl300Mixed name equals: 'mdl300Mixed'.
	self assert: BpMDLChartingPalette mdl400Mixed name equals: 'mdl400Mixed'.
	self assert: BpMDLChartingPalette mdl500Mixed name equals: 'mdl500Mixed'
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlMixedSchemesHoldTheColorsOfTheirRow [

	self assert: BpMDLChartingPalette mdl300Mixed colors asSet equals: BpMDLChartingPalette mdl300 colors asSet.
	self assert: BpMDLChartingPalette mdl400Mixed colors asSet equals: BpMDLChartingPalette mdl400 colors asSet.
	self assert: BpMDLChartingPalette mdl500Mixed colors asSet equals: BpMDLChartingPalette mdl500 colors asSet
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlMixedSchemesListTheirHuesInTheSameOrder [

	| orders |
	orders := {
		          (BpMDLChartingPalette mdl300 -> BpMDLChartingPalette mdl300Mixed).
		          (BpMDLChartingPalette mdl400 -> BpMDLChartingPalette mdl400Mixed).
		          (BpMDLChartingPalette mdl500 -> BpMDLChartingPalette mdl500Mixed) } collect: [ :each |
		          each value colors collect: [ :color | each key colors indexOf: color ] ].
	self assert: orders asSet size equals: 1
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlMixedSchemesSeparateTheNeighborsOfTheirRow [
	"Two colors following each other, the last and the first included, do not follow each other in the row."

	| row mixed |
	row := BpMDLChartingPalette mdl500 colors.
	mixed := BpMDLChartingPalette mdl500Mixed.
	self assert:
		((1 to: 19) allSatisfy: [ :each | ((row indexOf: (mixed colorAt: each)) - (row indexOf: (mixed colorAt: each + 1))) abs > 1 ])
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlMixedSchemesStartWithBlueAmberPurpleGreenBrown [

	self
		assert: (BpMDLChartingPalette mdl500Mixed colors first: 5) asArray
		equals:
			(#( #( 16r21 16r96 16rF3 ) #( 16rFF 16rC1 16r07 ) #( 16r9C 16r27 16rB0 ) #( 16r4C 16rAF 16r50 ) #( 16r79 16r55 16r48 ) )
				 collect: [ :each | BpPalette colorFromTriplet: each ])
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlSchemesAreNamedAfterTheirRow [

	self assert: BpMDLChartingPalette mdl300 name equals: 'mdl300'.
	self assert: BpMDLChartingPalette mdl400 name equals: 'mdl400'.
	self assert: BpMDLChartingPalette mdl500 name equals: 'mdl500'
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlSchemesEndWithTheirBlueGrey [

	self assert: (BpMDLChartingPalette mdl300 colorAt: 19) equals: (BpPalette colorFromTriplet: #( 16r90 16rA4 16rAE )).
	self assert: (BpMDLChartingPalette mdl400 colorAt: 19) equals: (BpPalette colorFromTriplet: #( 16r78 16r90 16r9C )).
	self assert: (BpMDLChartingPalette mdl500 colorAt: 19) equals: (BpPalette colorFromTriplet: #( 16r60 16r7D 16r8B ))
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlSchemesHaveNineteenDistinctColors [

	| palettes |
	palettes := BpMDLChartingPalette schemes collect: [ :each | BpMDLChartingPalette perform: each ].
	self assert: palettes size equals: 7.
	self assert: (palettes allSatisfy: [ :each | each size = 19 and: [ each colors asSet size = 19 ] ])
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlSchemesListTheirHuesInTheSameOrder [
	"Grey, the only color without saturation, is the 18th of every scheme."

	self assert: ({
		 BpMDLChartingPalette mdl300.
		 BpMDLChartingPalette mdl400.
		 BpMDLChartingPalette mdl500 } allSatisfy: [ :each |
			 (each colors detect: [ :color | color saturation isZero ]) == (each colors at: 18) ])
]

{ #category : 'tests' }
BpEnumeratedPaletteTest >> testMdlSchemesStartWithTheirRed [

	self assert: (BpMDLChartingPalette mdl300 colorAt: 1) equals: (BpPalette colorFromTriplet: #( 16rE5 16r73 16r73 )).
	self assert: (BpMDLChartingPalette mdl400 colorAt: 1) equals: (BpPalette colorFromTriplet: #( 16rEF 16r53 16r50 )).
	self assert: (BpMDLChartingPalette mdl500 colorAt: 1) equals: (BpPalette colorFromTriplet: #( 16rF4 16r43 16r36 ))
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
