"
I am the shape of a scatter marker, as matplotlib `MarkerStyle`: a circle, a polygon, lines (unfilled markers such as '+'), a path or a text. `BpMarker class>>on:` reads the matplotlib specifications: symbols ('o', '^', '*', ...), tuples (number of sides, 0 polygon, 1 star or 2 asterisk, angle), the vertices of a path, or a text between dollars.

## Examples

```
BpMarker exampleStar.
BpMarker scriptAllMarkers
```

## Design Rationale

- My vertices are in the unit cell of matplotlib markers: y goes up, a circle has a diameter of 1. A `BpMarkerPatch` scales them to its size and flips y with `pixelVerticesWithSide:`, so one marker serves all sizes.
- The TeX card suits ('$\clubsuit$', ...) are drawn as paths (`BlSvgPath`) because the fonts of the image do not have their glyphs; other texts between dollars are shown with the default font.

## Usage

1. `BpScatterplot>>marker:` creates me with `on:`; `BpScatterplot>>initialize` uses 'o'.
2. Each `BpMarkerPatch` asks me `geometryWithSide:`, `extentWithSide:` and `offsetWithSide:` to take my shape at its size.

- I am immutable and shared by all the patches of a scatter.

## Invariants and Assumptions

- An unknown symbol or tuple style raises an error.
"
Class {
	#name : 'BpMarker',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'vertices',
		'text',
		'commands'
	],
	#category : 'Bloc-Plotter-Scatter',
	#package : 'Bloc-Plotter',
	#tag : 'Scatter'
}

{ #category : 'private - shapes' }
BpMarker class >> asterisk: aNumberOfBranches angle: aDegreeAngle [
	"A path going from the center to each vertex of a regular polygon and back (matplotlib unit_regular_asterisk)."

	^ (self regular: aNumberOfBranches angle: aDegreeAngle) flatCollect: [ :each |
		  {
			  (0 @ 0).
			  each } ]
]

{ #category : 'private - shapes' }
BpMarker class >> circleAt: aCenter radius: aRadius [
	"Answer the path commands of a circle drawn counterclockwise with four cubic curves."

	| k |
	k := 0.5523 * aRadius.
	^ {
		  {
			  #M.
			  (aCenter + (aRadius @ 0)) }.
		  {
			  #C.
			  (aCenter + (aRadius @ k)).
			  (aCenter + (k @ aRadius)).
			  (aCenter + (0 @ aRadius)) }.
		  {
			  #C.
			  (aCenter + (k negated @ aRadius)).
			  (aCenter + (aRadius negated @ k)).
			  (aCenter + (aRadius negated @ 0)) }.
		  {
			  #C.
			  (aCenter + (aRadius negated @ k negated)).
			  (aCenter + (k negated @ aRadius negated)).
			  (aCenter + (0 @ aRadius negated)) }.
		  {
			  #C.
			  (aCenter + (k @ aRadius negated)).
			  (aCenter + (aRadius @ k negated)).
			  (aCenter + (aRadius @ 0)) }.
		  { #Z } }
]

{ #category : 'instance creation' }
BpMarker class >> commands: aCollectionOfCommands [
	"A marker drawn with path commands in the unit cell, y going up: {#M. aPoint}, {#L. aPoint}, {#C. control1. control2. aPoint} and {#Z}."

	^ self new
		  setKind: #path vertices: (aCollectionOfCommands flatCollect: [ :each | each allButFirst ]) text: nil;
		  setCommands: aCollectionOfCommands;
		  yourself
]

{ #category : 'examples' }
BpMarker class >> exampleStar [
	"Answer the star marker of matplotlib ('*')."

	<sampleInstance>
	^ self on: '*'
]

{ #category : 'private - shapes' }
BpMarker class >> heartCommandsFlipped: aBoolean [
	"Answer the path commands of a heart, upside down when aBoolean is true (the leaf of a spade)."

	| commands |
	commands := {
		            {
			            #M.
			            (0 @ -0.45) }.
		            {
			            #C.
			            (-0.3 @ -0.2).
			            (-0.5 @ 0.05).
			            (-0.37 @ 0.3) }.
		            {
			            #C.
			            (-0.25 @ 0.5).
			            (0 @ 0.45).
			            (0 @ 0.25) }.
		            {
			            #C.
			            (0 @ 0.45).
			            (0.25 @ 0.5).
			            (0.37 @ 0.3) }.
		            {
			            #C.
			            (0.5 @ 0.05).
			            (0.3 @ -0.2).
			            (0 @ -0.45) }.
		            { #Z } }.
	aBoolean ifFalse: [ ^ commands ].
	^ commands collect: [ :each | { each first } , (each allButFirst collect: [ :point | point x @ (point y negated * 0.8 + 0.1) ]) ]
]

{ #category : 'instance creation' }
BpMarker class >> kind: aSymbol vertices: aCollectionOfPoints [

	^ self new
		  setKind: aSymbol vertices: aCollectionOfPoints asArray text: nil;
		  yourself
]

{ #category : 'instance creation' }
BpMarker class >> named: aString [

	| builder |
	builder := self namedMarkers at: aString asString ifAbsent: [ ^ self error: 'Unknown marker: ' , aString printString ].
	^ builder value
]

{ #category : 'private - shapes' }
BpMarker class >> namedMarkers [
	"The matplotlib marker symbols and how to build them, with y going up and the unit cell from -0.5 to 0.5."

	| triangle square plus cross |
	triangle := {
		            (0 @ 0.5).
		            (-0.5 @ -0.5).
		            (0.5 @ -0.5) }.
	square := {
		          (-0.5 @ -0.5).
		          (0.5 @ -0.5).
		          (0.5 @ 0.5).
		          (-0.5 @ 0.5) }.
	plus := #( #( -1 -3 ) #( 1 -3 ) #( 1 -1 ) #( 3 -1 ) #( 3 1 ) #( 1 1 ) #( 1 3 ) #( -1 3 ) #( -1 1 ) #( -3 1 ) #( -3 -1 )
	           #( -1 -1 ) ) collect: [ :each | each first / 6 @ (each second / 6) ].
	cross := #( #( -1 -2 ) #( 0 -1 ) #( 1 -2 ) #( 2 -1 ) #( 1 0 ) #( 2 1 ) #( 1 2 ) #( 0 1 ) #( -1 2 ) #( -2 1 ) #( -1 0 ) #( -2 -1 ) )
		         collect: [ :each | each first / 4 @ (each second / 4) ].
	^ Dictionary new
		  at: 'o' put: [
			  self kind: #circle vertices: {
				  (-0.5 @ -0.5).
				  (0.5 @ 0.5) } ];
		  at: '.' put: [
			  self kind: #circle vertices: {
				  (-0.25 @ -0.25).
				  (0.25 @ 0.25) } ];
		  at: 's' put: [ self kind: #polygon vertices: square ];
		  at: '^' put: [ self kind: #polygon vertices: triangle ];
		  at: 'v' put: [ self kind: #polygon vertices: (self rotated: triangle by: 180) ];
		  at: '<' put: [ self kind: #polygon vertices: (self rotated: triangle by: 90) ];
		  at: '>' put: [ self kind: #polygon vertices: (self rotated: triangle by: -90) ];
		  at: 'D' put: [ self kind: #polygon vertices: (self rotated: square by: 45) ];
		  at: 'd' put: [ self kind: #polygon vertices: ((self rotated: square by: 45) collect: [ :each | each x * 0.6 @ each y ]) ];
		  at: 'p' put: [ self kind: #polygon vertices: (self regular: 5 angle: 0) ];
		  at: 'h' put: [ self kind: #polygon vertices: (self regular: 6 angle: 0) ];
		  at: 'H' put: [ self kind: #polygon vertices: (self regular: 6 angle: 30) ];
		  at: '8' put: [ self kind: #polygon vertices: (self regular: 8 angle: 22.5) ];
		  at: '*' put: [ self kind: #polygon vertices: (self star: 5 inner: 0.381966 angle: 0) ];
		  at: 'P' put: [ self kind: #polygon vertices: plus ];
		  at: 'X' put: [ self kind: #polygon vertices: cross ];
		  at: '+' put: [
			  self kind: #lines vertices: {
				  (-0.5 @ 0).
				  (0.5 @ 0).
				  (0 @ 0).
				  (0 @ 0.5).
				  (0 @ -0.5) } ];
		  at: 'x' put: [
			  self kind: #lines vertices: {
				  (-0.5 @ -0.5).
				  (0.5 @ 0.5).
				  (0 @ 0).
				  (-0.5 @ 0.5).
				  (0.5 @ -0.5) } ];
		  at: '|' put: [
			  self kind: #lines vertices: {
				  (0 @ -0.5).
				  (0 @ 0.5) } ];
		  at: '_' put: [
			  self kind: #lines vertices: {
				  (-0.5 @ 0).
				  (0.5 @ 0) } ];
		  yourself
]

{ #category : 'instance creation' }
BpMarker class >> on: aSpecification [
	"Answer the marker of a matplotlib marker specification: a symbol string such as 'o' or '^', a text between dollars such as '$f$', a tuple (number of sides, 0 for a polygon, 1 for a star or 2 for an asterisk, angle in degrees), or the vertices of a path."

	aSpecification isString ifTrue: [
		^ (aSpecification size > 2 and: [ aSpecification first = $$ and: [ aSpecification last = $$ ] ])
			  ifTrue: [ self text: (aSpecification copyFrom: 2 to: aSpecification size - 1) ]
			  ifFalse: [ self named: aSpecification ] ].
	(aSpecification allSatisfy: [ :each | each isNumber ]) ifTrue: [ ^ self tuple: aSpecification ].
	^ self vertices: (aSpecification collect: [ :each |
		   each isPoint
			   ifTrue: [ each ]
			   ifFalse: [ each first @ each second ] ])
]

{ #category : 'private - shapes' }
BpMarker class >> polar: aRadius angle: aDegreeAngle [

	| radians |
	radians := aDegreeAngle degreesToRadians.
	^ aRadius * radians cos @ (aRadius * radians sin)
]

{ #category : 'private - shapes' }
BpMarker class >> regular: aNumberOfSides angle: aDegreeAngle [
	"The vertices of a regular polygon of radius 0.5, the first one at the top before rotation (matplotlib unit_regular_polygon scaled by 0.5)."

	^ (0 to: aNumberOfSides - 1) collect: [ :index | self polar: 0.5 angle: 360 * index / aNumberOfSides + 90 + aDegreeAngle ]
]

{ #category : 'private - shapes' }
BpMarker class >> rotated: aCollectionOfPoints by: aDegreeAngle [

	| radians |
	radians := aDegreeAngle degreesToRadians.
	^ aCollectionOfPoints collect: [ :each |
		  each x * radians cos - (each y * radians sin) @ (each x * radians sin + (each y * radians cos)) ]
]

{ #category : 'script' }
BpMarker class >> scriptAllMarkers [
	"Show every marker symbol, tuple and TeX shape known, one per column."

	<example>
	| specifications figure axes |
	specifications := #( 'o' '.' 's' '^' 'v' '<' '>' 'D' 'd' 'p' 'h' 'H' '8' '*' 'P' 'X' '+' 'x' '|' '_' #( 6 1 0 ) #( 6 2 0 )
	                     '$\clubsuit$' '$\spadesuit$' '$\heartsuit$' '$\diamondsuit$' ).
	figure := BpFigure new.
	figure extent: 1000 @ 220.
	axes := figure axes first.
	specifications withIndexDo: [ :each :index |
		(axes scatterX: { index } y: #( 0 ))
			s: 200;
			c: 'k';
			marker: each ].
	axes
		title: 'Markers: o . s ^ v < > D d p h H 8 * P X + x | _ (6,1) (6,2) and the TeX card suits';
		yTickCount: 1.
	^ figure show: 'Markers'
]

{ #category : 'private - shapes' }
BpMarker class >> star: aNumberOfPoints inner: anInnerRatio angle: aDegreeAngle [
	"The vertices of a star of radius 0.5 whose inner vertices are at anInnerRatio of it (matplotlib unit_regular_star scaled by 0.5)."

	^ (0 to: 2 * aNumberOfPoints - 1) collect: [ :index |
		  self
			  polar: (index even
				   ifTrue: [ 0.5 ]
				   ifFalse: [ 0.5 * anInnerRatio ])
			  angle: 180 * index / aNumberOfPoints + 90 + aDegreeAngle ]
]

{ #category : 'private - shapes' }
BpMarker class >> stem [
	"Answer the path commands of the stem of a club or a spade, drawn counterclockwise; it starts high enough to fill the gap between the leaves."

	^ {
		  {
			  #M.
			  (0 @ 0.2) }.
		  {
			  #L.
			  (-0.15 @ -0.5) }.
		  {
			  #L.
			  (0.15 @ -0.5) }.
		  { #Z } }
]

{ #category : 'private - shapes' }
BpMarker class >> texMarkers [
	"The TeX symbols drawn as shapes, such as matplotlib '$\clubsuit$'."

	^ Dictionary new
		  at: '\clubsuit' put: [
			  self commands:
				  (self circleAt: 0 @ 0.22 radius: 0.2) , (self circleAt: -0.22 @ -0.08 radius: 0.2)
				  , (self circleAt: 0.22 @ -0.08 radius: 0.2) , self stem ];
		  at: '\spadesuit' put: [ self commands: (self heartCommandsFlipped: true) , self stem ];
		  at: '\heartsuit' put: [ self commands: (self heartCommandsFlipped: false) ];
		  at: '\diamondsuit' put: [
			  self kind: #polygon vertices: {
				  (0 @ 0.5).
				  (-0.35 @ 0).
				  (0 @ -0.5).
				  (0.35 @ 0) } ];
		  yourself
]

{ #category : 'instance creation' }
BpMarker class >> text: aString [
	"A text marker, or the shape of a TeX symbol such as \clubsuit, which the fonts of the image do not have."

	self texMarkers at: aString ifPresent: [ :builder | ^ builder value ].
	^ self new
		  setKind: #text vertices: {
			  (-0.5 @ -0.5).
			  (0.5 @ 0.5) }
		  text: aString;
		  yourself
]

{ #category : 'instance creation' }
BpMarker class >> tuple: anArray [
	"(numsides, style, angle): a regular polygon (style 0), star (1) or asterisk (2) of numsides vertices, rotated by angle degrees."

	| sides angle |
	sides := anArray first.
	angle := anArray size > 2
		         ifTrue: [ anArray third ]
		         ifFalse: [ 0 ].
	anArray second = 0 ifTrue: [ ^ self kind: #polygon vertices: (self regular: sides angle: angle) ].
	anArray second = 1 ifTrue: [ ^ self kind: #polygon vertices: (self star: sides inner: 0.5 angle: angle) ].
	anArray second = 2 ifTrue: [ ^ self kind: #lines vertices: (self asterisk: sides angle: angle) ].
	^ self error: 'Unknown marker style: ' , anArray second printString
]

{ #category : 'instance creation' }
BpMarker class >> vertices: aCollectionOfPoints [
	"A custom path, scaled so that its farthest coordinate is at 0.5 from the center, as matplotlib."

	| rescale |
	rescale := (aCollectionOfPoints collect: [ :each | each x abs max: each y abs ]) max.
	^ self kind: #polygon vertices: (aCollectionOfPoints collect: [ :each | each * (0.5 / rescale) ])
]

{ #category : 'accessing' }
BpMarker >> bounds [
	"Answer the rectangle around my vertices in the unit cell, y going up."

	^ Rectangle encompassing: vertices
]

{ #category : 'accessing' }
BpMarker >> commands [
	"Answer the path commands of a path marker, in the unit cell, y going up."

	^ commands
]

{ #category : 'geometry' }
BpMarker >> extentWithSide: aSide [
	"Answer my extent in pixels when the unit cell measures aSide pixels."

	^ self bounds extent * aSide
]

{ #category : 'geometry' }
BpMarker >> geometryWithSide: aSide [
	"Answer a Bloc geometry drawing me in a box of my extent when the unit cell measures aSide pixels."

	self isCircle ifTrue: [ ^ BlCircleGeometry new ].
	self isText ifTrue: [ ^ BlRectangleGeometry new ].
	kind = #path ifTrue: [ ^ BlSvgPath new pathString: (self pathStringWithSide: aSide) ].
	self isFilled ifTrue: [ ^ BlPolygonGeometry vertices: (self pixelVerticesWithSide: aSide) ].
	^ BlPolylineGeometry vertices: (self pixelVerticesWithSide: aSide)
]

{ #category : 'testing' }
BpMarker >> isCircle [

	^ kind = #circle
]

{ #category : 'testing' }
BpMarker >> isFilled [
	"Answer whether my shape is filled with the face color; the lines of an unfilled marker are drawn with it."

	^ kind ~= #lines
]

{ #category : 'testing' }
BpMarker >> isText [

	^ kind = #text
]

{ #category : 'accessing' }
BpMarker >> kind [

	^ kind
]

{ #category : 'geometry' }
BpMarker >> offsetWithSide: aSide [
	"Answer the position, from the center of the marker, of the top left corner of my box in pixels."

	^ self bounds left * aSide @ (self bounds bottom negated * aSide)
]

{ #category : 'geometry' }
BpMarker >> pathStringWithSide: aSide [
	"Answer my path commands as SVG path data in pixels."

	^ String streamContents: [ :stream |
		  commands do: [ :each |
			  stream nextPutAll: each first.
			  each allButFirst
				  do: [ :point |
					  | pixel |
					  pixel := self pixelPoint: point withSide: aSide.
					  stream
						  print: pixel x;
						  nextPut: $,;
						  print: pixel y ]
				  separatedBy: [ stream space ].
			  stream space ] ]
]

{ #category : 'geometry' }
BpMarker >> pixelPoint: aPoint withSide: aSide [
	"Answer aPoint of the unit cell in pixels, relative to the top left corner of my box, y going down."

	| box |
	box := self bounds.
	^ aPoint x - box left * aSide @ (box bottom - aPoint y * aSide)
]

{ #category : 'geometry' }
BpMarker >> pixelVerticesWithSide: aSide [
	"Answer my vertices in pixels relative to the top left corner of my box, y going down."

	^ vertices collect: [ :each | self pixelPoint: each withSide: aSide ]
]

{ #category : 'accessing' }
BpMarker >> setCommands: aCollectionOfCommands [

	commands := aCollectionOfCommands
]

{ #category : 'accessing' }
BpMarker >> setKind: aSymbol vertices: aCollectionOfPoints text: aString [

	kind := aSymbol.
	vertices := aCollectionOfPoints.
	text := aString
]

{ #category : 'accessing' }
BpMarker >> text [

	^ text
]

{ #category : 'accessing' }
BpMarker >> vertices [
	"Answer my vertices in the unit cell, y going up (the two corners of my box for a circle or a text)."

	^ vertices
]
