"
I am a palette whose colors differ by hue, to tell things apart without ordering them: the artists of a chart, the wedges of a pie. `tab10` is the default palette of the charts.

## Examples

```
BpQualitativePalette exampleQualitative
```

## Design Rationale

- A scheme has one factory, answering all its colors: in the source data a smaller version is the start of the largest one, so `colorAt:` gives the same colors.

## Implementation Notes

- Accent, dark2, paired, pastel1, pastel2, set1, set2 and set3 come from www.ColorBrewer.org by Cynthia A. Brewer, Geography, Pennsylvania State University, under the Apache License 2.0 (https://github.com/axismaps/colorbrewer/blob/master/LICENCE.txt). flatui1 comes from http://flatuicolors.com/.
"
Class {
	#name : 'BpQualitativePalette',
	#superclass : 'BpEnumeratedPalette',
	#category : 'Bloc-Plotter-Color',
	#package : 'Bloc-Plotter',
	#tag : 'Color'
}

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> accent [

	^ self
		  name: 'accent'
		  triplets:
			  #( #( 127 201 127 ) #( 190 174 212 ) #( 253 192 134 ) #( 255 255 153 ) #( 56 108 176 ) #( 240 2 127 ) #( 191 91 23 )
			     #( 102 102 102 ) )
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> dark2 [

	^ self
		  name: 'dark2'
		  triplets:
		  #( #( 27 158 119 ) #( 217 95 2 ) #( 117 112 179 ) #( 231 41 138 ) #( 102 166 30 ) #( 230 171 2 ) #( 166 118 29 )
		     #( 102 102 102 ) )
]

{ #category : 'examples' }
BpQualitativePalette class >> exampleQualitative [
	"Show all the qualitative schemes."

	<example>
	^ self demoOpen: (self schemes collect: [ :each | self perform: each ]) title: 'Qualitative palettes'
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> flatui1 [

	^ self
		  name: 'flatui1'
		  triplets:
			  #( #( 26 188 156 ) #( 46 204 113 ) #( 52 152 219 ) #( 155 89 182 ) #( 52 73 94 ) #( 22 160 133 ) #( 39 174 96 )
			     #( 41 128 185 ) #( 142 68 173 ) #( 44 62 80 ) #( 241 196 15 ) #( 230 126 34 ) #( 231 76 60 ) #( 236 240 241 )
			     #( 149 165 166 ) #( 243 156 18 ) #( 211 84 0 ) #( 192 57 43 ) #( 189 195 199 ) #( 127 140 141 ) )
]

{ #category : 'instances' }
BpQualitativePalette class >> instanceTab10 [

	<sampleInstance>
	^ self tab10
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> paired [

	^ self
		  name: 'paired'
		  triplets:
			  #( #( 166 206 227 ) #( 31 120 180 ) #( 178 223 138 ) #( 51 160 44 ) #( 251 154 153 ) #( 227 26 28 ) #( 253 191 111 )
			     #( 255 127 0 ) #( 202 178 214 ) #( 106 61 154 ) #( 255 255 153 ) #( 177 89 40 ) )
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> pastel1 [

	^ self
		  name: 'pastel1'
		  triplets:
			  #( #( 251 180 174 ) #( 179 205 227 ) #( 204 235 197 ) #( 222 203 228 ) #( 254 217 166 ) #( 255 255 204 ) #( 229 216 189 )
			     #( 253 218 236 ) #( 242 242 242 ) )
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> pastel2 [

	^ self
		  name: 'pastel2'
		  triplets:
			  #( #( 179 226 205 ) #( 253 205 172 ) #( 203 213 232 ) #( 244 202 228 ) #( 230 245 201 ) #( 255 242 174 ) #( 241 226 204 )
			     #( 204 204 204 ) )
]

{ #category : 'accessing' }
BpQualitativePalette class >> schemes [
	"Answer the selectors of my schemes."

	^ #( #tab10 #accent #dark2 #flatui1 #paired #pastel1 #pastel2 #set1 #set2 #set3 )
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> set1 [

	^ self
		  name: 'set1'
		  triplets:
			  #( #( 228 26 28 ) #( 55 126 184 ) #( 77 175 74 ) #( 152 78 163 ) #( 255 127 0 ) #( 255 255 51 ) #( 166 86 40 ) #( 247 129 191 )
			     #( 153 153 153 ) )
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> set2 [

	^ self
		  name: 'set2'
		  triplets:
			  #( #( 102 194 165 ) #( 252 141 98 ) #( 141 160 203 ) #( 231 138 195 ) #( 166 216 84 ) #( 255 217 47 ) #( 229 196 148 )
			     #( 179 179 179 ) )
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> set3 [

	^ self
		  name: 'set3'
		  triplets:
			  #( #( 141 211 199 ) #( 255 255 179 ) #( 190 186 218 ) #( 251 128 114 ) #( 128 177 211 ) #( 253 180 98 ) #( 179 222 105 )
			     #( 252 205 229 ) #( 217 217 217 ) #( 188 128 189 ) #( 204 235 197 ) #( 255 237 111 ) )
]

{ #category : 'instance creation - schemes' }
BpQualitativePalette class >> tab10 [

	^ self
		  name: 'tab10'
		  triplets:
			  #( #( 31 119 180 ) #( 255 127 14 ) #( 44 160 44 ) #( 214 39 40 ) #( 148 103 189 ) #( 140 86 75 ) #( 227 119 194 )
			     #( 127 127 127 ) #( 188 189 34 ) #( 23 190 207 ) )
]
