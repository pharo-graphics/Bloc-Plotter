"
I test the factories of `BpIEEEPalette`: the tints of each color, the colors and the sizes of the palettes of one or more tints, the names of the schemes and the error for an unknown percentage.
"
Class {
	#name : 'BpIEEEPaletteTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpIEEEPaletteTest >> testAllTintsAreDistinct [

	self assert: BpIEEEPalette ieee100And75And50And25 colors asSet size equals: 72
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testColorPalettesGoFromDarkToLight [

	self assert: (BpIEEEPalette colorPalettes allSatisfy: [ :each |
		 | luminances |
		 luminances := each colors collect: [ :color | color luminance ].
		 luminances = luminances sorted ])
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testColorPalettesHaveFourColors [

	self assert: BpIEEEPalette colorPalettes size equals: 18.
	self assert: (BpIEEEPalette colorPalettes allSatisfy: [ :each | each size = 4 ])
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testColorPalettesHoldTheirFourTints [

	self
		assert: (BpIEEEPalette ieeeBlue colors collect: [ :each | each asHexString ])
		equals: #( '00629B' '477CA7' '809DBD' 'BAC6D9' ).
	self assert: (BpIEEEPalette gray colors collect: [ :each | each asHexString ]) equals: #( '75787B' '95979A' 'B7B8BA' 'DADBDC' )
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testOneTintPalettesFollowTheOrderOfTheColors [

	self assert: BpIEEEPalette ieee50 colors equals: (BpIEEEPalette colorPalettes collect: [ :each | each colorAt: 3 ])
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testOneTintPalettesStartWithTheTintOfIeeeBlue [

	self assert: (BpIEEEPalette ieee100 colorAt: 1) asHexString equals: '00629B'.
	self assert: (BpIEEEPalette ieee75 colorAt: 1) asHexString equals: '477CA7'.
	self assert: (BpIEEEPalette ieee50 colorAt: 1) asHexString equals: '809DBD'.
	self assert: (BpIEEEPalette ieee25 colorAt: 1) asHexString equals: 'BAC6D9'
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testSchemesAreNamedAfterTheirSelector [

	BpIEEEPalette schemes do: [ :each | self assert: (BpIEEEPalette perform: each) name equals: each asString ]
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testSchemesListTheColorPalettesThenTheTintPalettes [

	self
		assert: BpIEEEPalette schemes
		equals: (BpIEEEPalette colorPalettes , BpIEEEPalette tintPalettes collect: [ :each | each name asSymbol ])
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testTintSchemesAreAllDifferent [

	| colorSets |
	colorSets := BpIEEEPalette tintPalettes collect: [ :each | each colors asSet ] as: Set.
	self assert: colorSets size equals: 15
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testTintSchemesHoldEighteenColorsPerPercentage [
	"There are four palettes of one tint, six of two, four of three and one of four."

	self
		assert: (BpIEEEPalette tintPalettes collect: [ :each | each size ])
		equals: #( 18 18 18 18 36 36 36 36 36 36 54 54 54 54 72 )
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testTintsKeepTheOrderOfThePercentages [

	self assert: (BpIEEEPalette tints: #( 25 100 )) colors equals: BpIEEEPalette ieee25 colors , BpIEEEPalette ieee100 colors
]

{ #category : 'tests - errors' }
BpIEEEPaletteTest >> testTintsOfAnUnknownPercentageRaisesError [

	self should: [ BpIEEEPalette tints: #( 75 60 ) ] raise: Error
]

{ #category : 'tests' }
BpIEEEPaletteTest >> testTwoTintsPaletteHoldsOneTintThenTheOther [

	self assert: BpIEEEPalette ieee75And50 size equals: 36.
	self assert: (BpIEEEPalette ieee75And50 colors first: 18) equals: BpIEEEPalette ieee75 colors.
	self assert: (BpIEEEPalette ieee75And50 colors last: 18) equals: BpIEEEPalette ieee50 colors
]
