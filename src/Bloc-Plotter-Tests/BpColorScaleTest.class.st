"
I test `BpColorScale`: the numbers at its ends, the clipping, and the logarithmic scale.
"
Class {
	#name : 'BpColorScaleTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpColorScaleTest >> newScale [

	^ BpColorScale new
		  colorMap: [ :fraction | Color gray: fraction ];
		  yourself
]

{ #category : 'tests' }
BpColorScaleTest >> testColorForMapsTheFractionThroughTheColorMap [

	| scale |
	scale := self newScale.
	scale fitTo: #( 0 10 ).
	self assert: (scale colorFor: 10) equals: Color white.
	scale colorMap: BpInterpolatedPalette viridis.
	self assert: (scale colorFor: 10) equals: (BpInterpolatedPalette viridis colorAt: 1)
]

{ #category : 'tests' }
BpColorScaleTest >> testEqualNumbersAreAtTheStart [

	| scale |
	scale := self newScale.
	scale fitTo: #( 5 5 ).
	self assert: (scale fractionOf: 5) equals: 0
]

{ #category : 'tests' }
BpColorScaleTest >> testFitToSpansTheNumbers [

	| scale |
	scale := self newScale.
	scale fitTo: #( 2 6 4 ).
	self assert: (scale fractionOf: 2) equals: 0.
	self assert: (scale fractionOf: 4) equals: 1 / 2.
	self assert: (scale fractionOf: 6) equals: 1
]

{ #category : 'tests' }
BpColorScaleTest >> testFractionsAreClipped [

	| scale |
	scale := self newScale.
	scale
		vMin: 3;
		vMax: 4;
		fitTo: #(  ).
	self assert: (scale fractionOf: 0) equals: 0.
	self assert: (scale fractionOf: 10) equals: 1
]

{ #category : 'tests' }
BpColorScaleTest >> testGivenEndsWinOverTheNumbers [

	| scale |
	scale := self newScale.
	scale
		vMin: 0;
		vMax: 8;
		fitTo: #( 2 6 4 ).
	self assert: (scale fractionOf: 2) equals: 1 / 4
]

{ #category : 'tests' }
BpColorScaleTest >> testLimitsAreTheEnds [

	| scale |
	scale := BpColorScale new.
	scale
		vMax: 10;
		fitTo: #( 2 5 ).
	self assert: scale limits equals: #( 2 10 )
]

{ #category : 'tests' }
BpColorScaleTest >> testLogarithmicScaleFollowsTheOrdersOfMagnitude [

	| scale |
	scale := self newScale.
	scale
		scale: #log;
		fitTo: #( 1 10 100 ).
	self assert: (scale fractionOf: 10) closeTo: 0.5
]

{ #category : 'tests' }
BpColorScaleTest >> testLogarithmicScaleIgnoresZeroAndNegativeNumbers [

	| scale |
	scale := self newScale.
	scale
		scale: #log;
		fitTo: #( -1 0 1 10 100 ).
	self assert: (scale fractionOf: 1) equals: 0.
	self assert: (scale colorFor: 0) isTransparent.
	self assert: (scale colorFor: -1) isTransparent
]

{ #category : 'tests - errors' }
BpColorScaleTest >> testUnknownScaleRaisesError [

	self
		should: [ BpColorScale new scale: #cubic ]
		raise: Error
		whoseDescriptionIncludes: 'Unknown scale'
		description: 'the scale is unknown'
]
