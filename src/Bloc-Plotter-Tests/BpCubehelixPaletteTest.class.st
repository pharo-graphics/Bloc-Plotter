"
I test `BpCubehelixPalette` and `BpCubehelix`: the colors of the schemes against the published ones, their greys, and the settings of the helix.
"
Class {
	#name : 'BpCubehelixPaletteTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpCubehelixPaletteTest >> assert: aPalette has: someTriplets [

	self
		assert: (aPalette colors collect: [ :each |
			 {
				 (each red * 255) rounded.
				 (each green * 255) rounded.
				 (each blue * 255) rounded } ])
		equals: someTriplets
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> greysOf: aPalette [
	"Answer the brightness of the colors of aPalette, as printed in grey."

	^ aPalette colors collect: [ :each | 0.3 * each red + (0.59 * each green) + (0.11 * each blue) ]
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testChartArtistsTakeTheColorsOfACubehelixPalette [

	| chart palette |
	palette := BpCubehelixPalette classic resizedTo: 3 lightFrom: 0.2 to: 0.8.
	chart := BpChart new
		         palette: palette;
		         yourself.
	self assert: (chart plotX: #( 1 2 ) y: #( 1 2 )) linePatch border paint color equals: (palette colorAt: 1)
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testClassic [

	self
		assert: BpCubehelixPalette classic
		has: #( #( 0 0 0 ) #( 22 10 34 ) #( 24 32 68 ) #( 16 62 83 ) #( 14 94 74 ) #( 35 116 51 ) #( 80 125 35 ) #( 138 122 45 )
			   #( 190 117 85 ) #( 218 121 145 ) #( 219 138 203 ) #( 204 167 240 ) #( 191 201 251 ) #( 195 229 244 ) #( 220 246 239 )
			   #( 255 255 255 ) )
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testCubehelix3 [
	"Its saturation is so high that colors are clipped."

	self
		assert: BpCubehelixPalette cubehelix3
		has:
			#( #( 0 0 0 ) #( 0 39 12 ) #( 0 68 60 ) #( 0 80 131 ) #( 3 75 202 ) #( 72 60 252 ) #( 156 43 255 ) #( 235 36 244 )
			   #( 255 45 194 ) #( 255 73 134 ) #( 255 115 86 ) #( 255 164 67 ) #( 235 209 85 ) #( 211 241 135 ) #( 215 255 200 )
			   #( 255 255 255 ) )
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testGammaAboveOneDarkens [

	self assert: (self greysOf: (BpCubehelix new
		  gamma: 2;
		  palette)) eighth < (self greysOf: BpCubehelixPalette classic) eighth
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testGreysOfTheClassicSchemeAreEvenlySpaced [

	(self greysOf: BpCubehelixPalette classic) withIndexDo: [ :each :index |
		self assert: (each closeTo: index - 1 / 15 precision: 0.01) ]
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testHueFromToSetsTheStartAndTheRotation [

	| helix |
	helix := BpCubehelix new.
	helix hueFrom: 240 to: -300.
	self assert: helix start closeTo: -1.
	self assert: helix rotation closeTo: -1.5
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testLightDirectionCanBeReversed [

	self
		assert: (BpCubehelix new
			 lightFrom: 1 to: 0;
			 palette) colors
		equals: BpCubehelixPalette classic colors reversed
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testPerceptualRainbow [
	"It is given by its hues and has a gamma."

	self
		assert: BpCubehelixPalette perceptualRainbow
		has: #( #( 135 59 97 ) #( 143 64 127 ) #( 143 72 157 ) #( 135 85 185 ) #( 121 102 207 ) #( 103 123 220 ) #( 84 146 223 )
			   #( 69 170 215 ) #( 59 192 197 ) #( 60 210 172 ) #( 71 223 145 ) #( 93 229 120 ) #( 124 231 103 ) #( 161 227 95 )
			   #( 198 220 100 ) #( 233 213 117 ) )
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testResizedToKeepsTheEndsOfTheHelix [

	| palette |
	palette := BpCubehelixPalette classic resizedTo: 4.
	self assert: palette size equals: 4.
	self assert: palette name equals: 'classic'.
	self assert: (palette colorAt: 1) equals: Color black.
	self assert: (palette colorAt: 2) equals: (BpCubehelixPalette classic colorAt: 6).
	self assert: (palette colorAt: 4) equals: Color white
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testResizedToLeavesTheOriginalPalette [

	| palette |
	palette := BpCubehelixPalette classic.
	palette resizedTo: 4.
	self assert: palette size equals: 16
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testResizedToLightFromToLeavesBlackAndWhiteOut [

	| palette greys |
	palette := BpCubehelixPalette classic resizedTo: 5 lightFrom: 0.2 to: 0.8.
	greys := self greysOf: palette.
	self assert: (greys first closeTo: 0.2 precision: 0.01).
	self assert: (greys last closeTo: 0.8 precision: 0.01)
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testResizedToOneColor [

	self assert: (BpCubehelixPalette classic resizedTo: 1 lightFrom: 0.5 to: 1) colors size equals: 1
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testSchemesAreNamedAfterTheirSelector [

	self
		assert: (BpCubehelixPalette schemes collect: [ :each | (BpCubehelixPalette perform: each) name ])
		equals: (BpCubehelixPalette schemes collect: [ :each | each asString ])
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testSchemesGetLighterInGrey [

	BpCubehelixPalette schemes do: [ :each |
		self assert: (self greysOf: (BpCubehelixPalette perform: each)) isSorted description: each asString ]
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testSchemesHaveSixteenColors [

	self assert: BpCubehelixPalette schemes size equals: 8.
	BpCubehelixPalette schemes do: [ :each | self assert: (BpCubehelixPalette perform: each) size equals: 16 ]
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testSixthColorOfTheOtherSchemes [

	{
		(#purple -> #( 79 75 152 )).
		(#jimSpecial -> #( 55 88 146 )).
		(#red -> #( 134 53 118 )).
		(#cubehelix1 -> #( 147 45 126 )).
		(#cubehelix2 -> #( 78 72 168 )) } do: [ :each |
			| color |
			color := (BpCubehelixPalette perform: each key) colorAt: 6.
			self
				assert: {
					(color red * 255) rounded.
					(color green * 255) rounded.
					(color blue * 255) rounded }
				equals: each value ]
]

{ #category : 'tests' }
BpCubehelixPaletteTest >> testZeroSaturationGivesGreys [

	| palette |
	palette := BpCubehelix new
		           saturation: 0;
		           palette.
	self assert: (palette colors allSatisfy: [ :each | each red = each green and: [ each green = each blue ] ])
]
