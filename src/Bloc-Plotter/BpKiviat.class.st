"
I am a Kiviat chart (also called radar chart): one axis per variable around a center, and a polygon per row of values (`BpKiviatRow`), with a corner on each axis. `axisNames:` names the axes and `addRow:` adds a row. Each axis (`BpKiviatAxis`) can have its own scale.

## Examples

```
BpKiviat exampleRadarChart.
BpKiviat exampleMaterials.
BpKiviat exampleRestaurants.
BpKiviat exampleCars
```

## Design Rationale

- I am a `BpPolarChart` whose radii are fractions, from 0 at the center to 1 at the edge: each axis turns its values into fractions with its own limits and scale, so the axes can show different units.
- The limits of an axis are its own (`BpKiviatAxis>>limits:`), else mine (`limits:`), else computed from the values: the ones of all the axes without limits of their own (`shareScale:` true, the default), or the ones of that axis only. Sharing is the default because rows are compared most often on one scale. Computed limits start at 0, or below the lowest value when it is negative, and put nice values on the rings.
- The values are labeled on the first axis only when all the axes show the same ones, else on each axis.
- The first axis is at the top and the next ones turn counterclockwise; `startAngle:` and `counterClock:` change it.
- My frame and my rings are polygons with a corner on each axis, or circles after `beCircular`. Less than three axes make no polygon: I am circular then.
- Axes are numbered when rows are added without `axisNames:`.

## Usage

1. `BpFigure>>rows:columns:chartClass:` creates me; I can also be shown alone.
2. `axisNames:` creates my axes. `axisNamed:` and `axisAt:` answer one of them, to give it limits, a scale or a formatter.
3. `addRow:` and `addRows:` answer the rows they create, to give them a label, a color or markers. `legend` shows the labels.
4. When a row, an axis or a setting changes, I `rebuild`: the limits of the axes are computed, and the rows place their patches on them (`BpKiviatRow>>place`).

## Implementation Notes

- The corners of my polygonal frame are computed when my plot area is placed (`plotBounds:`).
- My plot area does not clip its children: the outlines and the markers on the edge are drawn entirely, and so are the values out of the limits of their axis.

## Invariants and Assumptions

- Each row has one value per axis: an error is raised otherwise.
"
Class {
	#name : 'BpKiviat',
	#superclass : 'BpPolarChart',
	#instVars : [
		'axes',
		'rows',
		'limits',
		'shareScale',
		'ringCount',
		'polygonal'
	],
	#category : 'Bloc-Plotter-Kiviat',
	#package : 'Bloc-Plotter',
	#tag : 'Kiviat'
}

{ #category : 'examples' }
BpKiviat class >> exampleCars [
	"Show a kiviat whose axes have different scales, one of them inverted and one logarithmic."

	<example>
	| figure |
	figure := BpFigure rows: 1 columns: 1 chartClass: self.
	self showCarsIn: figure charts first.
	^ figure show: 'A scale for each axis'
]

{ #category : 'examples' }
BpKiviat class >> exampleMaterials [
	"Show a kiviat of one row, whose axes share their scale."

	<example>
	| figure |
	figure := BpFigure rows: 1 columns: 1 chartClass: self.
	self showMaterialsIn: figure charts first.
	^ figure show: 'Kiviat of one row'
]

{ #category : 'examples' }
BpKiviat class >> exampleRadarChart [
	"Reproduce the gallery 'Radar chart (aka spider or star chart)' (see `BpFigure class>>instanceRadarChart`)."

	<example>
	^ BpFigure instanceRadarChart show: 'radar_chart'
]

{ #category : 'examples' }
BpKiviat class >> exampleRestaurants [
	"Show a circular kiviat of three rows with a dot on each value and a legend."

	<example>
	| figure |
	figure := BpFigure rows: 1 columns: 1 chartClass: self.
	self showRestaurantsIn: figure charts first.
	^ figure show: 'Circular kiviat'
]

{ #category : 'private - demo' }
BpKiviat class >> factorProfiles [
	"Answer the shares of the factors (the rows) in nine chemicals, for four scenarios."

	^ {
		  ('Basecase' -> #( #( 0.88 0.01 0.03 0.03 0.0 0.06 0.01 0.0 0.0 ) #( 0.07 0.95 0.04 0.05 0.0 0.02 0.01 0.0 0.0 )
		      #( 0.01 0.02 0.85 0.19 0.05 0.1 0.0 0.0 0.0 ) #( 0.02 0.01 0.07 0.01 0.21 0.12 0.98 0.0 0.0 )
		      #( 0.01 0.01 0.02 0.71 0.74 0.7 0.0 0.0 0.0 ) )).
		  ('With CO' -> #( #( 0.88 0.02 0.02 0.02 0.0 0.05 0.0 0.05 0.0 ) #( 0.08 0.94 0.04 0.02 0.0 0.01 0.12 0.04 0.0 )
		      #( 0.01 0.01 0.79 0.1 0.0 0.05 0.0 0.31 0.0 ) #( 0.0 0.02 0.03 0.38 0.31 0.31 0.0 0.59 0.0 )
		      #( 0.02 0.02 0.11 0.47 0.69 0.58 0.88 0.0 0.0 ) )).
		  ('With O3' -> #( #( 0.89 0.01 0.07 0.0 0.0 0.05 0.0 0.0 0.03 ) #( 0.07 0.95 0.05 0.04 0.0 0.02 0.12 0.0 0.0 )
		      #( 0.01 0.02 0.86 0.27 0.16 0.19 0.0 0.0 0.0 ) #( 0.01 0.03 0.0 0.32 0.29 0.27 0.0 0.0 0.95 )
		      #( 0.02 0.0 0.03 0.37 0.56 0.47 0.87 0.0 0.0 ) )).
		  ('CO & O3' -> #( #( 0.87 0.01 0.08 0.0 0.0 0.04 0.0 0.0 0.01 ) #( 0.09 0.95 0.02 0.03 0.0 0.01 0.13 0.06 0.0 )
		      #( 0.01 0.02 0.71 0.24 0.13 0.16 0.0 0.5 0.0 ) #( 0.01 0.03 0.0 0.28 0.24 0.23 0.0 0.44 0.88 )
		      #( 0.02 0.0 0.18 0.45 0.64 0.55 0.86 0.0 0.16 ) )) }
]

{ #category : 'instances' }
BpKiviat class >> instanceCars [
	"Answer a kiviat whose axes have different scales: an inverted one for the price, where less is better, and a logarithmic one for the number of cars produced."

	<sampleInstance>
	| kiviat |
	kiviat := self new
		          extent: 600 @ 500;
		          yourself.
	self showCarsIn: kiviat.
	^ kiviat
]

{ #category : 'instances' }
BpKiviat class >> instanceMaterials [
	"Answer a kiviat of one row, whose five axes share their scale."

	<sampleInstance>
	| kiviat |
	kiviat := self new
		          extent: 500 @ 400;
		          yourself.
	self showMaterialsIn: kiviat.
	^ kiviat
]

{ #category : 'instances' }
BpKiviat class >> instanceRestaurants [
	"Answer a circular kiviat of three rows with a dot on each value and a legend."

	<sampleInstance>
	| kiviat |
	kiviat := self new
		          extent: 500 @ 400;
		          yourself.
	self showRestaurantsIn: kiviat.
	^ kiviat
]

{ #category : 'private - demo' }
BpKiviat class >> showCarsIn: aKiviat [

	aKiviat
		axisNames: #( 'Speed (km/h)' 'Price' 'Produced' 'Seats' 'Trunk (l)' );
		title: 'Cars'.
	(aKiviat axisNamed: 'Speed (km/h)') limits: #( 100 250 ).
	(aKiviat axisNamed: 'Price')
		limits: #( 60000 10000 );
		tickFormatter: [ :each | (each / 1000) printString , ' k' ].
	(aKiviat axisNamed: 'Produced')
		scale: #log;
		limits: #( 1 100000 ).
	(aKiviat axisNamed: 'Seats') limits: #( 0 10 ).
	(aKiviat axisNamed: 'Trunk (l)') limits: #( 0 1000 ).
	#( 'City' 'Family' )
		with: (aKiviat addRows: #( #( 140 15000 80000 4 250 ) #( 210 42000 3000 7 800 ) ))
		do: [ :label :row | row label: label ].
	aKiviat legend
]

{ #category : 'private - demo' }
BpKiviat class >> showFactors: aCollectionOfRows in: aKiviat [
	"Show the shares of the factors in nine chemicals in aKiviat."

	aKiviat
		axisNames: #( 'Sulfate' 'Nitrate' 'EC' 'OC1' 'OC2' 'OC3' 'OP' 'CO' 'O3' );
		limits: #( 0 1 ).
	aCollectionOfRows withIndexDo: [ :each :index | (aKiviat addRow: each) label: 'Factor ' , index printString ]
]

{ #category : 'private - demo' }
BpKiviat class >> showMaterialsIn: aKiviat [

	aKiviat
		axisNames: #( 'processing cost' 'mechanical properties' 'chemical stability' 'thermal stability' 'device integration' );
		title: 'Material'.
	aKiviat addRow: #( 1 5 2 2 3 )
]

{ #category : 'private - demo' }
BpKiviat class >> showRestaurantsIn: aKiviat [

	aKiviat
		axisNames: #( 'Food Quality' 'Food Variety' 'Service Quality' 'Ambience' 'Affordability' );
		beCircular;
		title: 'Restaurants'.
	#( 'Restaurant A' 'Restaurant B' 'Restaurant C' )
		with: (aKiviat addRows: #( #( 4 4 5 4 3 ) #( 5 5 4 5 2 ) #( 3 4 5 3 5 ) ))
		do: [ :label :row |
			row
				label: label;
				fill: false;
				showMarkers: true ].
	aKiviat legend
]

{ #category : 'plotting' }
BpKiviat >> addKiviatRow: aRow [

	axes ifEmpty: [ axes := self newAxesNamed: ((1 to: aRow values size) collect: [ :each | each printString ]) ].
	self checkValues: aRow values.
	rows add: aRow.
	^ self addArtist: aRow
]

{ #category : 'plotting' }
BpKiviat >> addRow: aCollectionOfNumbers [
	"Draw aCollectionOfNumbers, one per axis, and answer the row, to be configured with label:, color:, fill:, showMarkers:, ... (see `BpKiviatRow`). Without axis names, the axes are numbered."

	^ self addKiviatRow: (BpKiviatRow new
		   values: aCollectionOfNumbers;
		   yourself)
]

{ #category : 'plotting' }
BpKiviat >> addRows: aCollectionOfCollections [
	"Draw a row for each element of aCollectionOfCollections and answer the rows (see `addRow:`)."

	^ aCollectionOfCollections collect: [ :each | self addRow: each ]
]

{ #category : 'geometry' }
BpKiviat >> angleAt: anIndex [
	"Answer the angle of the axis at anIndex, in radians from my start angle."

	^ Float twoPi * (anIndex - 1) / axes size
]

{ #category : 'geometry' }
BpKiviat >> angles [

	^ (1 to: axes size) collect: [ :each | self angleAt: each ]
]

{ #category : 'private - building' }
BpKiviat >> autoScale: anAxis [
	"The radii are fractions: my axes have their own scales."

	^ anAxis = #x
		  ifTrue: [ super autoScale: anAxis ]
		  ifFalse: [ #( 0 1 ) ]
]

{ #category : 'accessing' }
BpKiviat >> axes [
	"Answer my `BpKiviatAxis`, from the top in the direction of the angles."

	^ axes
]

{ #category : 'accessing' }
BpKiviat >> axisAt: anIndex [

	^ axes at: anIndex
]

{ #category : 'accessing' }
BpKiviat >> axisNamed: aString [
	"Answer my axis named aString, to be configured with limits:, scale: and tickFormatter:."

	^ axes detect: [ :each | each name = aString ]
]

{ #category : 'accessing' }
BpKiviat >> axisNames [

	^ axes collect: [ :each | each name ]
]

{ #category : 'accessing' }
BpKiviat >> axisNames: aCollectionOfStrings [
	"Replace my axes by new ones named by aCollectionOfStrings, one per value of my rows."

	rows do: [ :each | self check: each values size for: aCollectionOfStrings size ].
	axes := self newAxesNamed: aCollectionOfStrings.
	self rebuild
]

{ #category : 'configuring' }
BpKiviat >> beCircular [
	"Draw my frame and my rings as circles."

	polygonal := false.
	self rebuild
]

{ #category : 'configuring' }
BpKiviat >> bePolygonal [
	"Draw my frame and my rings as polygons with a corner on each axis (the default)."

	polygonal := true.
	self rebuild
]

{ #category : 'private - building' }
BpKiviat >> check: aValueCount for: anAxisCount [

	aValueCount = anAxisCount ifFalse: [
		self error: ('A row has {1} values for {2} axes' format: {
			 aValueCount.
			 anAxisCount }) ]
]

{ #category : 'private - building' }
BpKiviat >> checkValues: aCollectionOfNumbers [
	"Raise an error unless aCollectionOfNumbers has one value per axis."

	self check: aCollectionOfNumbers size for: axes size
]

{ #category : 'geometry' }
BpKiviat >> hasOneScale [
	"Answer whether all my axes show the same values at the same places."

	^ axes allSatisfy: [ :each | each hasScaleOf: axes first ]
]

{ #category : 'initialization' }
BpKiviat >> initialize [

	super initialize.
	plotArea clipChildren: false.
	self startAngle: 90
]

{ #category : 'initialization' }
BpKiviat >> initializeSettings [

	super initializeSettings.
	axes := #(  ).
	rows := OrderedCollection new.
	shareScale := true.
	ringCount := 5.
	polygonal := true
]

{ #category : 'accessing' }
BpKiviat >> isPolygonal [
	"Answer whether my frame and my rings are polygons: it takes at least three axes."

	^ polygonal and: [ axes size > 2 ]
]

{ #category : 'private - building' }
BpKiviat >> labelTicksOf: anAxis at: anIndex [
	"Answer the ticks labeling the values of anAxis, the axis at anIndex, at each ring."

	| fractions |
	fractions := self ringFractions.
	^ fractions
		  with: (anAxis labelsAt: fractions)
		  collect: [ :fraction :text | BpKiviatTick angle: (self angleAt: anIndex) location: fraction text: text ]
]

{ #category : 'accessing' }
BpKiviat >> limits [

	^ limits
]

{ #category : 'accessing' }
BpKiviat >> limits: aCollectionOrNil [
	"Set the values at the center and at the edge (first and last of aCollectionOrNil) of all the axes that have no limits of their own (`BpKiviatAxis>>limits:`). Nil computes them from the values."

	limits := aCollectionOrNil.
	self rebuild
]

{ #category : 'private - building' }
BpKiviat >> limitsOf: anAxis at: anIndex [
	"Answer the limits of anAxis, the axis at anIndex: its own, or mine, or the ones covering the values it shares or its own values."

	(anAxis canShow: anAxis limits) ifTrue: [ ^ anAxis limits ].
	(anAxis canShow: limits) ifTrue: [ ^ limits ].
	^ anAxis
		  limitsCovering: (shareScale
			   ifTrue: [ self valuesSharedWith: anAxis ]
			   ifFalse: [ self valuesAt: anIndex ])
		  count: ringCount
]

{ #category : 'private - building' }
BpKiviat >> newAxesNamed: aCollectionOfStrings [

	^ aCollectionOfStrings collect: [ :each | BpKiviatAxis name: each in: self ] as: Array
]

{ #category : 'private - building' }
BpKiviat >> newGridLines [
	"Answer a line for each axis, and a ring for each step but the last one, which my frame draws."

	showGrid ifFalse: [ ^ #(  ) ].
	^ (self angles collect: [ :each | BpPolarGridLine axis: #x location: each ] as: Array)
	  , (self ringFractions allButLast collect: [ :each | self newRingAt: each ])
]

{ #category : 'private - building' }
BpKiviat >> newRingAt: aFraction [

	^ self isPolygonal
		  ifTrue: [ BpKiviatRing location: aFraction angles: self angles ]
		  ifFalse: [ BpPolarGridLine axis: #y location: aFraction ]
]

{ #category : 'private - building' }
BpKiviat >> newTicksOn: anAxis [
	"Label the axes with their names around me. Label the values on the first axis, or on each one when they have different scales."

	| labeled |
	anAxis = #x ifTrue: [
		^ axes withIndexCollect: [ :each :index | self newTickOn: #x location: (self angleAt: index) text: each name asString ] ].
	labeled := self hasOneScale
		           ifTrue: [ axes size min: 1 ]
		           ifFalse: [ axes size ].
	^ (1 to: labeled) flatCollect: [ :index | self labelTicksOf: (self axisAt: index) at: index ] as: Array
]

{ #category : 'accessing' }
BpKiviat >> plotBounds: aRectangle [
	"Give my polygonal frame a corner at the edge of each axis."

	super plotBounds: aRectangle.
	self isPolygonal ifTrue: [ plotArea geometry vertices: (self angles collect: [ :each | transform pointFor: each @ 1 ]) ]
]

{ #category : 'geometry' }
BpKiviat >> pointsFor: aCollectionOfNumbers [
	"Answer the point of each number on its axis: the angle of the axis @ a fraction of the radius."

	^ aCollectionOfNumbers withIndexCollect: [ :each :index | (self angleAt: index) @ ((self axisAt: index) fractionOf: each) ]
]

{ #category : 'private - building' }
BpKiviat >> rebuild [
	"Compute the limits of my axes and move my rows there, then show all."

	axes withIndexDo: [ :each :index | each shownLimits: (self limitsOf: each at: index) ].
	rows do: [ :each | each place ].
	self updateFrame.
	super rebuild
]

{ #category : 'accessing' }
BpKiviat >> ringCount [

	^ ringCount
]

{ #category : 'accessing' }
BpKiviat >> ringCount: anInteger [
	"Set the number of equal steps from the center to the edge, shown by my rings (5 by default)."

	ringCount := anInteger.
	self rebuild
]

{ #category : 'private - building' }
BpKiviat >> ringFractions [

	^ (1 to: ringCount) collect: [ :each | each / ringCount ]
]

{ #category : 'accessing' }
BpKiviat >> rows [

	^ rows
]

{ #category : 'accessing' }
BpKiviat >> shareScale [

	^ shareScale
]

{ #category : 'accessing' }
BpKiviat >> shareScale: aBoolean [
	"Set whether the limits computed for the axes cover the values of all of them (the default), or for each axis its own values only."

	shareScale := aBoolean.
	self rebuild
]

{ #category : 'private - building' }
BpKiviat >> updateFrame [
	"Take the shape of my frame; its corners are computed when my plot area is placed."

	plotArea geometry: (self isPolygonal
		 ifTrue: [ BlPolygonGeometry vertices: { (0 @ 0) } ]
		 ifFalse: [ BlCircleGeometry new ])
]

{ #category : 'private - building' }
BpKiviat >> valuesAt: anIndex [
	"Answer the values of my rows on the axis at anIndex."

	^ rows collect: [ :each | each values at: anIndex ] as: Array
]

{ #category : 'private - building' }
BpKiviat >> valuesSharedWith: anAxis [
	"Answer the values of my rows on all the axes whose limits are computed, on the same kind of scale as anAxis."

	| values |
	values := OrderedCollection new.
	axes withIndexDo: [ :each :index |
		(each limits isNil and: [ each scale = anAxis scale ]) ifTrue: [ values addAll: (self valuesAt: index) ] ].
	^ values
]
