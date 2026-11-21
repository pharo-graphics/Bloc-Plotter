"
I test `BpDataTransform`: the conversion of data coordinates to pixels on linear and log scales.
"
Class {
	#name : 'BpDataTransformTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpDataTransformTest >> dataTransform [

	^ BpDataTransform new
		  xLimits: #( 0 10 );
		  yLimits: #( 0 100 );
		  extent: 200 @ 100;
		  yourself
]

{ #category : 'tests' }
BpDataTransformTest >> testDataCornerIsAtTheTopRight [

	self assert: (self dataTransform pointFor: 10 @ 100) equals: 200 @ 0
]

{ #category : 'tests' }
BpDataTransformTest >> testDataOriginIsAtTheBottomLeft [

	self assert: (self dataTransform pointFor: 0 @ 0) equals: 0 @ 100
]

{ #category : 'tests' }
BpDataTransformTest >> testLogScaleClipsNonPositiveValuesBelowTheAxis [

	| transform |
	transform := self dataTransform
		             yLimits: #( 1 100 );
		             yScale: #log;
		             yourself.
	self assert: (transform pointFor: 0 @ 0) y > 100
]

{ #category : 'tests' }
BpDataTransformTest >> testLogScaleMapsDecadesEvenly [

	| transform |
	transform := self dataTransform
		             yLimits: #( 1 100 );
		             yScale: #log;
		             yourself.
	self assert: (transform pointFor: 0 @ 10) y closeTo: 50
]

{ #category : 'tests' }
BpDataTransformTest >> testMiddle [

	self assert: (self dataTransform pointFor: 5 @ 50) equals: 100 @ 50
]

{ #category : 'tests' }
BpDataTransformTest >> testRectangleFor [

	self assert: (self dataTransform rectangleFor: (2 @ 0 corner: 4 @ 50)) equals: (40 @ 50 corner: 80 @ 100)
]
