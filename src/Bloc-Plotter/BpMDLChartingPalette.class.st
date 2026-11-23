"
I am a palette of the Material Design colors, to tell things apart without ordering them. My schemes come from four rows of the Material Design color table, from the lightest to the darkest: `mdl200`, `mdl300`, `mdl400` and `mdl500` keep the order of the table, `mdl200Mixed`, `mdl300Mixed`, `mdl400Mixed` and `mdl500Mixed` hold their colors in an order that separates close hues.

## Examples

```
BpMDLChartingPalette exampleMDLCharting
```

## Design Rationale

- A row holds 19 colors in the order of the table: red, pink, purple, deep purple, indigo, blue, light blue, cyan, teal, green, light green, lime, yellow, amber, orange, deep orange, brown, grey, blue grey. Colors next to each other have close hues, so the first artists of a chart are hard to tell apart. The mixed schemes are for charts with a few artists.
- The four mixed schemes share one order, and so do the four rows: the same index is the same hue in all of them, so a chart can move from one to another and keep its hues.

## Implementation Notes

- The colors come from https://materialui.co/colors.
- The order of the mixed schemes (`mixedOrder`) was computed once on OKLab distances, taking the worst of the rows 300, 400 and 500, in normal vision and in simulated protanopia and deuteranopia. Its first five colors are all distinct from each other. Further on, only the colors next to each other are. The row 200 was not part of the computation: its paler colors are closer to each other, but the order separates them much more than the one of the table.

## Invariants and Assumptions

- `mixedOrder` holds each index of a row once.
"
Class {
	#name : 'BpMDLChartingPalette',
	#superclass : 'BpEnumeratedPalette',
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'examples' }
BpMDLChartingPalette class >> exampleMDLCharting [
	"Show the four rows of Material Design colors, from the lightest to the darkest, then their mixed versions."

	<example>
	^ self
		  demoOpen: {
			  self instanceMdl200.
			  self instanceMdl300.
			  self instanceMdl400.
			  self instanceMdl500.
			  self instanceMdl200Mixed.
			  self instanceMdl300Mixed.
			  self instanceMdl400Mixed.
			  self instanceMdl500Mixed }
		  title: 'MDL charting palettes'
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl200 [

	<sampleInstance>
	^ self mdl200
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl200Mixed [

	<sampleInstance>
	^ self mdl200Mixed
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl300 [

	<sampleInstance>
	^ self mdl300
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl300Mixed [

	<sampleInstance>
	^ self mdl300Mixed
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl400 [

	<sampleInstance>
	^ self mdl400
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl400Mixed [

	<sampleInstance>
	^ self mdl400Mixed
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl500 [

	<sampleInstance>
	^ self mdl500
]

{ #category : 'instances' }
BpMDLChartingPalette class >> instanceMdl500Mixed [

	<sampleInstance>
	^ self mdl500Mixed
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl200 [

	^ self
		  name: 'mdl200'
		  triplets:
			  #( #( 239 154 154 ) #( 244 143 177 ) #( 206 147 216 ) #( 179 157 219 ) #( 159 168 218 ) #( 144 202 249 ) #( 129 212 250 )
			     #( 128 222 234 ) #( 128 203 196 ) #( 165 214 167 ) #( 197 225 165 ) #( 230 238 156 ) #( 255 245 157 ) #( 255 224 130 )
			     #( 255 204 128 ) #( 255 171 145 ) #( 188 170 164 ) #( 238 238 238 ) #( 176 190 197 ) )
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl200Mixed [

	^ self mixed: self mdl200
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl300 [

	^ self
		  name: 'mdl300'
		  triplets:
			  #( #( 229 115 115 ) #( 240 98 146 ) #( 186 104 200 ) #( 149 117 205 ) #( 121 134 203 ) #( 100 181 246 ) #( 79 195 247 )
			     #( 77 208 225 ) #( 77 182 172 ) #( 129 199 132 ) #( 174 213 129 ) #( 220 231 117 ) #( 255 241 118 ) #( 255 213 79 )
			     #( 255 183 77 ) #( 255 138 101 ) #( 161 136 127 ) #( 224 224 224 ) #( 144 164 174 ) )
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl300Mixed [

	^ self mixed: self mdl300
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl400 [

	^ self
		  name: 'mdl400'
		  triplets:
			  #( #( 239 83 80 ) #( 236 64 122 ) #( 171 71 188 ) #( 126 87 194 ) #( 92 107 192 ) #( 66 165 245 ) #( 41 182 246 )
			     #( 38 198 218 ) #( 38 166 154 ) #( 102 187 106 ) #( 156 204 101 ) #( 212 225 87 ) #( 255 238 88 ) #( 255 202 40 )
			     #( 255 167 38 ) #( 255 112 67 ) #( 141 110 99 ) #( 189 189 189 ) #( 120 144 156 ) )
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl400Mixed [

	^ self mixed: self mdl400
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl500 [

	^ self
		  name: 'mdl500'
		  triplets:
			  #( #( 244 67 54 ) #( 233 30 99 ) #( 156 39 176 ) #( 103 58 183 ) #( 63 81 181 ) #( 33 150 243 ) #( 3 169 244 ) #( 0 188 212 )
			     #( 0 150 136 ) #( 76 175 80 ) #( 139 195 74 ) #( 205 220 57 ) #( 255 235 59 ) #( 255 193 7 ) #( 255 152 0 ) #( 255 87 34 )
			     #( 121 85 72 ) #( 158 158 158 ) #( 96 125 139 ) )
]

{ #category : 'instance creation - schemes' }
BpMDLChartingPalette class >> mdl500Mixed [

	^ self mixed: self mdl500
]

{ #category : 'private' }
BpMDLChartingPalette class >> mixed: aPalette [
	"Answer the palette with the colors of aPalette, a row, in the mixed order."

	^ self name: aPalette name , 'Mixed' colors: (self mixedOrder collect: [ :each | aPalette colorAt: each ])
]

{ #category : 'private' }
BpMDLChartingPalette class >> mixedOrder [
	"Answer the indexes in a row of the colors of the mixed schemes: blue, amber, purple, green, brown, cyan, deep orange, teal, orange, deep purple, grey, indigo, light green, pink, yellow, light blue, red, lime, blue grey."

	^ #( 6 14 3 10 17 8 16 9 15 4 18 5 11 2 13 7 1 12 19 )
]

{ #category : 'accessing' }
BpMDLChartingPalette class >> schemes [
	"Answer the selectors of my schemes."

	^ #( #mdl200 #mdl300 #mdl400 #mdl500 #mdl200Mixed #mdl300Mixed #mdl400Mixed #mdl500Mixed )
]
