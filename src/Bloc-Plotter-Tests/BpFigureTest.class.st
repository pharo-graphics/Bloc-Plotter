"
I test `BpFigure`: its default size and its grid of axes.
"
Class {
	#name : 'BpFigureTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpFigureTest >> testAxesAreCountedRowByRow [

	| figure |
	figure := BpFigure rows: 2 columns: 3.
	self assert: (figure axesAtRow: 2 column: 1) identicalTo: (figure axes at: 4)
]

{ #category : 'tests' }
BpFigureTest >> testDefaultExtentIsTheOneOfMatplotlib [

	| figure |
	figure := BpFigure new.
	figure inNewHeadlessSpaceDo: [ :space |
		space settle.
		self assert: figure extent equals: 640 @ 480 ]
]

{ #category : 'tests' }
BpFigureTest >> testFigureExtentIsTheDefaultSizeBeforeLayout [

	self assert: BpFigure new figureExtent equals: 640 @ 480
]

{ #category : 'tests' }
BpFigureTest >> testFigureExtentIsTheSizeAskedWithExtent [

	self
		assert: (BpFigure new
			 extent: 900 @ 520;
			 yourself) figureExtent
		equals: 900 @ 520
]

{ #category : 'tests' }
BpFigureTest >> testNewFigureHasOneAxes [

	self assert: BpFigure new axes size equals: 1
]

{ #category : 'tests' }
BpFigureTest >> testRowsColumnsCreatesAGridOfAxes [

	self assert: (BpFigure rows: 2 columns: 3) axes size equals: 6
]

{ #category : 'tests - saving' }
BpFigureTest >> testSavefigAnswersTheFile [

	self withFileNamed: 'figure.svg' do: [ :file | self assert: (BpFigure exampleTwoByTwo savefig: file) equals: file ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSavefigDpiScalesThePng [

	self withFileNamed: 'figure.png' do: [ :file |
		BpFigure exampleTwoByTwo savefig: file dpi: 200.
		self assert: (file binaryReadStreamDo: [ :stream | (PNGReadWriter on: stream) nextImage ]) extent equals: 1280 @ 960 ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSavefigPdfWritesAPdf [

	self withFileNamed: 'figure.pdf' do: [ :file |
		BpFigure exampleTwoByTwo savefig: file.
		self assert: (file binaryReadStreamDo: [ :stream | (stream next: 5) asString ]) equals: '%PDF-' ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSavefigPngHasTheFigureExtent [

	self withFileNamed: 'figure.png' do: [ :file |
		BpFigure exampleTwoByTwo savefig: file.
		self assert: (file binaryReadStreamDo: [ :stream | (PNGReadWriter on: stream) nextImage ]) extent equals: 640 @ 480 ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSavefigSvgWritesVectorGraphics [

	self withFileNamed: 'figure.svg' do: [ :file |
		| contents |
		BpFigure exampleTwoByTwo savefig: file.
		contents := file contents.
		self assert: (contents includesSubstring: '<svg').
		self assert: (contents includesSubstring: 'width="640" height="480"').
		self assert: (contents includesSubstring: '<path').
		self deny: (contents includesSubstring: '<image') ]
]

{ #category : 'tests - errors' }
BpFigureTest >> testSavefigWithAnUnknownExtensionRaisesError [

	self withFileNamed: 'figure.xyz' do: [ :file | self should: [ BpFigure exampleTwoByTwo savefig: file ] raise: Error ]
]

{ #category : 'tests - saving' }
BpFigureTest >> withFileNamed: aBasename do: aBlock [
	"Evaluate aBlock with a file of the image directory, deleted afterwards."

	| file |
	file := FileLocator imageDirectory asFileReference / ('BpFigureTest-' , aBasename).
	[ aBlock value: file ] ensure: [ file ensureDelete ]
]
