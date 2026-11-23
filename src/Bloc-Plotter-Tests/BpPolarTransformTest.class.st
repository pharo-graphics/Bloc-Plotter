"
I test `BpPolarTransform`: where angles and radii go in the plot area, the start angle, the direction, and the sectors of the bars.
"
Class {
	#name : 'BpPolarTransformTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpPolarTransformTest >> assert: aPoint isCloseTo: anotherPoint [

	self assert: aPoint x closeTo: anotherPoint x precision: 1.0e-6.
	self assert: aPoint y closeTo: anotherPoint y precision: 1.0e-6
]

{ #category : 'tests' }
BpPolarTransformTest >> polarTransform [
	"Answer a transform of a 200 by 200 plot area showing radii from 0 to 10."

	^ BpPolarTransform new
		  yLimits: #( 0 10 );
		  extent: 200 @ 200;
		  yourself
]

{ #category : 'tests' }
BpPolarTransformTest >> testAngleZeroIsOnTheRight [

	self assert: (self polarTransform pointFor: 0 @ 10) isCloseTo: 200 @ 100
]

{ #category : 'tests' }
BpPolarTransformTest >> testAnglesGoCounterclockwise [

	self assert: (self polarTransform pointFor: Float halfPi @ 10) isCloseTo: 100 @ 0
]

{ #category : 'tests' }
BpPolarTransformTest >> testBarIsASectorAroundTheCenter [
	"A bar from 0 to a quarter turn, between the radii 2 and 5: Bloc angles go clockwise."

	| bar bounds |
	bar := BpRectanglePatch new
		       dataBounds: (0 @ 2 corner: Float halfPi @ 5);
		       bePolar;
		       yourself.
	bounds := bar pixelBoundsWith: self polarTransform.
	self assert: bounds equals: (50 @ 50 corner: 150 @ 150).
	self assert: bar geometry innerRadius closeTo: 0.4.
	self assert: bar geometry startAngle closeTo: -90.
	self assert: bar geometry endAngle closeTo: 0
]

{ #category : 'tests' }
BpPolarTransformTest >> testBarWithoutHeightIsEmpty [

	| bar |
	bar := BpRectanglePatch new
		       dataBounds: (0 @ 0 corner: 1 @ 0);
		       bePolar;
		       yourself.
	self assert: (bar pixelBoundsWith: self polarTransform) extent equals: 0 @ 0
]

{ #category : 'tests' }
BpPolarTransformTest >> testCenterShowsTheLowestRadius [

	self assert: (self polarTransform pointFor: 1 @ 0) isCloseTo: 100 @ 100
]

{ #category : 'tests' }
BpPolarTransformTest >> testClockwiseAnglesGoDown [

	| transform |
	transform := self polarTransform
		             counterClock: false;
		             yourself.
	self assert: (transform pointFor: Float halfPi @ 10) isCloseTo: 100 @ 200
]

{ #category : 'tests' }
BpPolarTransformTest >> testClockwiseBarIsASectorGoingClockwise [

	| bar |
	bar := BpRectanglePatch new
		       dataBounds: (0 @ 0 corner: Float halfPi @ 5);
		       bePolar;
		       yourself.
	bar pixelBoundsWith: (self polarTransform
		 counterClock: false;
		 yourself).
	self assert: bar geometry startAngle closeTo: 0.
	self assert: bar geometry endAngle closeTo: 90
]

{ #category : 'tests' }
BpPolarTransformTest >> testLogScaleMapsDecadesEvenly [

	| transform |
	transform := self polarTransform
		             yLimits: #( 1 100 );
		             yScale: #log;
		             yourself.
	self assert: (transform pointFor: 0 @ 10) isCloseTo: 150 @ 100
]

{ #category : 'tests' }
BpPolarTransformTest >> testRadiiBelowTheLimitAreAtTheCenter [

	self assert: (self polarTransform pointFor: 0 @ -5) isCloseTo: 100 @ 100
]

{ #category : 'tests' }
BpPolarTransformTest >> testRadiusIsProportionalToTheValue [

	self assert: (self polarTransform pointFor: 0 @ 5) isCloseTo: 150 @ 100
]

{ #category : 'tests' }
BpPolarTransformTest >> testStartAnglePutsAngleZeroAtTheTop [

	| transform |
	transform := self polarTransform
		             startAngle: 90;
		             yourself.
	self assert: (transform pointFor: 0 @ 10) isCloseTo: 100 @ 0.
	self assert: (transform pointFor: Float halfPi @ 10) isCloseTo: 0 @ 100
]

{ #category : 'tests' }
BpPolarTransformTest >> testTheCircleFitsTheSmallestSide [

	| transform |
	transform := self polarTransform
		             extent: 300 @ 200;
		             yourself.
	self assert: (transform pointFor: 0 @ 10) isCloseTo: 250 @ 100
]
