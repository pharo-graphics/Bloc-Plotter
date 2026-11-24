"
I am a palette of the colors of the IEEE brand and of their tints. A color comes in four tints, at 100%, 75%, 50% and 25%. `ieeeBlue`, `cyan` and the other palettes of `colorPalettes` hold the four tints of one color, from dark to light. `ieee100` holds the 18 colors at 100%, `ieee75And50` holds them at 75%, then at 50%: 36 colors, and so on up to the 72 colors of `ieee100And75And50And25` (`tintPalettes`).

## Examples

```
BpIEEEPalette exampleColors.
BpIEEEPalette exampleTints
```

## Design Rationale

- A palette of several tints puts whole rows of 18 colors one after the other, each in the order of the color guide. Adding a tint keeps the first colors as they are, and an index moved by 18 is the same color in the next tint.
- Colors next to each other in the guide, such as yellow and dark yellow, have close hues. The 25% tints are pale on a white background.
- `tints:` makes the palettes of any percentages, in any order.

## Implementation Notes

- The colors are the HEX codes of the IEEE Color Guide (24-MSD-3-051, 03/2025, https://brand-experience.ieee.org). The tints are the published ones, not computed from the 100% color: the 75% tints of cyan and teal, for example, have no red.

## Invariants and Assumptions

- The palettes of `colorPalettes` list their tints in the order of `percentages`.
"
Class {
	#name : 'BpIEEEPalette',
	#superclass : 'BpEnumeratedPalette',
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> brightGreen [

	^ self
		  name: 'brightGreen'
		  triplets: #( #( 16r78 16rBE 16r20 ) #( 16r9B 16rCD 16r62 ) #( 16rBD 16rDE 16r96 ) #( 16rDE 16rEE 16rCA ) )
]

{ #category : 'accessing' }
BpIEEEPalette class >> colorPalettes [
	"Answer the palettes of the tints of one color, in the order of the color guide."

	^ {
		  self ieeeBlue.
		  self cyan.
		  self teal.
		  self darkTeal.
		  self darkGreen.
		  self green.
		  self oliveGreen.
		  self brightGreen.
		  self yellow.
		  self darkYellow.
		  self orange.
		  self darkOrange.
		  self red.
		  self darkRed.
		  self purple.
		  self darkPurple.
		  self darkBlue.
		  self gray }
]

{ #category : 'private' }
BpIEEEPalette class >> colorsAtPercentage: aPercentage [
	"Answer the tint at aPercentage of each color, in the order of the color guide."

	| index |
	index := self percentages
		         indexOf: aPercentage
		         ifAbsent: [ self error: ('The colors have no tint at {1}%' format: { aPercentage }) ].
	^ self colorPalettes collect: [ :each | each colorAt: index ]
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> cyan [

	^ self name: 'cyan' triplets: #( #( 16r00 16rB5 16rE2 ) #( 16r00 16rBD 16rF2 ) #( 16r6D 16rCF 16rF6 ) #( 16rB9 16rE5 16rFA ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> darkBlue [

	^ self
		  name: 'darkBlue'
		  triplets: #( #( 16r00 16r28 16r55 ) #( 16r43 16r4E 16r6E ) #( 16r73 16r77 16r91 ) #( 16rAD 16rAE 16rBE ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> darkGreen [

	^ self
		  name: 'darkGreen'
		  triplets: #( #( 16r00 16r63 16r41 ) #( 16r3D 16r88 16r6D ) #( 16r7F 16rAE 16r9B ) #( 16rBE 16rD6 16rCB ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> darkOrange [

	^ self
		  name: 'darkOrange'
		  triplets: #( #( 16rE8 16r77 16r22 ) #( 16rF8 16r98 16r5C ) #( 16rFF 16rBA 16r90 ) #( 16rFF 16rDC 16rC6 ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> darkPurple [

	^ self
		  name: 'darkPurple'
		  triplets: #( #( 16r77 16r25 16r83 ) #( 16r9D 16r5D 16rA0 ) #( 16rBE 16r91 16rBF ) #( 16rDE 16rC7 16rDE ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> darkRed [

	^ self name: 'darkRed' triplets: #( #( 16r86 16r1F 16r41 ) #( 16rAB 16r5A 16r6C ) #( 16rC9 16r90 16r9A ) #( 16rE4 16rC6 16rCA ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> darkTeal [

	^ self
		  name: 'darkTeal'
		  triplets: #( #( 16r00 16r73 16r77 ) #( 16r00 16r94 16r98 ) #( 16r70 16rB7 16rB9 ) #( 16rB9 16rDA 16rDB ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> darkYellow [

	^ self
		  name: 'darkYellow'
		  triplets: #( #( 16rFF 16rC7 16r2C ) #( 16rFF 16rD4 16r6A ) #( 16rFF 16rE2 16r9C ) #( 16rFF 16rF0 16rCD ) )
]

{ #category : 'examples' }
BpIEEEPalette class >> exampleColors [
	"Show the 100%, 75%, 50% and 25% tints of each color."

	<example>
	^ self demoOpen: self colorPalettes title: 'IEEE colors and their tints'
]

{ #category : 'examples' }
BpIEEEPalette class >> exampleTints [
	"Show the palettes of all the colors: in one tint, then in two, three and four tints."

	<example>
	^ self demoOpen: self tintPalettes title: 'IEEE palettes'
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> gray [

	^ self name: 'gray' triplets: #( #( 16r75 16r78 16r7B ) #( 16r95 16r97 16r9A ) #( 16rB7 16rB8 16rBA ) #( 16rDA 16rDB 16rDC ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> green [

	^ self name: 'green' triplets: #( #( 16r00 16r84 16r3D ) #( 16r3C 16rA2 16r6B ) #( 16r83 16rC1 16r9A ) #( 16rC1 16rDF 16rCB ) )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100 [

	^ self tints: #( 100 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100And25 [

	^ self tints: #( 100 25 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100And50 [

	^ self tints: #( 100 50 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100And50And25 [

	^ self tints: #( 100 50 25 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100And75 [

	^ self tints: #( 100 75 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100And75And25 [

	^ self tints: #( 100 75 25 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100And75And50 [

	^ self tints: #( 100 75 50 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee100And75And50And25 [

	^ self tints: #( 100 75 50 25 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee25 [

	^ self tints: #( 25 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee50 [

	^ self tints: #( 50 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee50And25 [

	^ self tints: #( 50 25 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee75 [

	^ self tints: #( 75 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee75And25 [

	^ self tints: #( 75 25 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee75And50 [

	^ self tints: #( 75 50 )
]

{ #category : 'instance creation - schemes' }
BpIEEEPalette class >> ieee75And50And25 [

	^ self tints: #( 75 50 25 )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> ieeeBlue [

	^ self
		  name: 'ieeeBlue'
		  triplets: #( #( 16r00 16r62 16r9B ) #( 16r47 16r7C 16rA7 ) #( 16r80 16r9D 16rBD ) #( 16rBA 16rC6 16rD9 ) )
]

{ #category : 'instances' }
BpIEEEPalette class >> instanceIeee100 [

	<sampleInstance>
	^ self ieee100
]

{ #category : 'instances' }
BpIEEEPalette class >> instanceIeee100And75And50And25 [

	<sampleInstance>
	^ self ieee100And75And50And25
]

{ #category : 'instances' }
BpIEEEPalette class >> instanceIeee25 [

	<sampleInstance>
	^ self ieee25
]

{ #category : 'instances' }
BpIEEEPalette class >> instanceIeee50 [

	<sampleInstance>
	^ self ieee50
]

{ #category : 'instances' }
BpIEEEPalette class >> instanceIeee75 [

	<sampleInstance>
	^ self ieee75
]

{ #category : 'instances' }
BpIEEEPalette class >> instanceIeee75And50 [

	<sampleInstance>
	^ self ieee75And50
]

{ #category : 'instances' }
BpIEEEPalette class >> instanceIeeeBlue [

	<sampleInstance>
	^ self ieeeBlue
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> oliveGreen [

	^ self
		  name: 'oliveGreen'
		  triplets: #( #( 16r65 16r8D 16r1B ) #( 16r8B 16rA7 16r57 ) #( 16rB1 16rC4 16r8E ) #( 16rD8 16rE0 16rC5 ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> orange [

	^ self name: 'orange' triplets: #( #( 16rFF 16rA3 16r00 ) #( 16rFF 16rBA 16r56 ) #( 16rFF 16rD1 16r8F ) #( 16rFF 16rE7 16rC6 ) )
]

{ #category : 'accessing' }
BpIEEEPalette class >> percentages [
	"Answer the percentages of the tints, in the order of the tints of a color."

	^ #( 100 75 50 25 )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> purple [

	^ self name: 'purple' triplets: #( #( 16r98 16r1D 16r97 ) #( 16rB8 16r60 16rB0 ) #( 16rD1 16r95 16rCA ) #( 16rE9 16rC9 16rE4 ) )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> red [

	^ self name: 'red' triplets: #( #( 16rBA 16r0C 16r2F ) #( 16rD8 16r5D 16r5D ) #( 16rEA 16r94 16r8F ) #( 16rF7 16rC9 16rC5 ) )
]

{ #category : 'accessing' }
BpIEEEPalette class >> schemes [
	"Answer the selectors of my schemes."

	^ #( #ieeeBlue #cyan #teal #darkTeal #darkGreen #green #oliveGreen #brightGreen #yellow #darkYellow #orange #darkOrange
	     #red #darkRed #purple #darkPurple #darkBlue #gray #ieee100 #ieee75 #ieee50 #ieee25 #ieee100And75 #ieee100And50 #ieee100And25
	     #ieee75And50 #ieee75And25 #ieee50And25 #ieee100And75And50 #ieee100And75And25 #ieee100And50And25 #ieee75And50And25
	     #ieee100And75And50And25 )
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> teal [

	^ self name: 'teal' triplets: #( #( 16r00 16r9C 16rA6 ) #( 16r00 16rB4 16rBD ) #( 16r62 16rCD 16rD2 ) #( 16rB6 16rE6 16rE8 ) )
]

{ #category : 'accessing' }
BpIEEEPalette class >> tintPalettes [
	"Answer the palettes of all the colors in one or more tints, from the smallest to the largest."

	^ {
		  self ieee100.
		  self ieee75.
		  self ieee50.
		  self ieee25.
		  self ieee100And75.
		  self ieee100And50.
		  self ieee100And25.
		  self ieee75And50.
		  self ieee75And25.
		  self ieee50And25.
		  self ieee100And75And50.
		  self ieee100And75And25.
		  self ieee100And50And25.
		  self ieee75And50And25.
		  self ieee100And75And50And25 }
]

{ #category : 'instance creation' }
BpIEEEPalette class >> tints: somePercentages [
	"Answer the palette of all the colors at the first of somePercentages, followed by all the colors at the next one, and so on."

	^ self
		  name: 'ieee' , ('And' join: (somePercentages collect: [ :each | each asString ]))
		  colors: (somePercentages flatCollect: [ :each | self colorsAtPercentage: each ])
]

{ #category : 'instance creation - colors' }
BpIEEEPalette class >> yellow [

	^ self name: 'yellow' triplets: #( #( 16rFF 16rD1 16r00 ) #( 16rFF 16rDC 16r47 ) #( 16rFF 16rE7 16r8A ) #( 16rFF 16rF2 16rC4 ) )
]
