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
BpFigureTest >> testSaveAsPDFWritesAPdf [

	self withFileNamed: 'figure.pdf' do: [ :file |
		BpFigure exampleTwoByTwo saveAsPDF: file.
		self assert: (file binaryReadStreamDo: [ :stream | (stream next: 5) asString ]) equals: '%PDF-' ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsPNGDpiScalesTheImage [

	self withFileNamed: 'figure.png' do: [ :file |
		BpFigure exampleTwoByTwo saveAsPNG: file dpi: 200.
		self assert: (file binaryReadStreamDo: [ :stream | (PNGReadWriter on: stream) nextImage ]) extent equals: 1280 @ 960 ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsPNGHasTheFigureExtent [

	self withFileNamed: 'figure.png' do: [ :file |
		BpFigure exampleTwoByTwo saveAsPNG: file.
		self assert: (file binaryReadStreamDo: [ :stream | (PNGReadWriter on: stream) nextImage ]) extent equals: 640 @ 480 ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsSVGAnswersTheFile [

	self withFileNamed: 'figure.svg' do: [ :file | self assert: (BpFigure exampleTwoByTwo saveAsSVG: file) equals: file ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsSVGDoesNotDependOnTheExtension [

	self withFileNamed: 'figure.txt' do: [ :file |
		BpFigure exampleTwoByTwo saveAsSVG: file.
		self assert: (file contents includesSubstring: '<svg') ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsSVGWritesVectorGraphics [

	self withFileNamed: 'figure.svg' do: [ :file |
		| contents |
		BpFigure exampleTwoByTwo saveAsSVG: file.
		contents := file contents.
		self assert: (contents includesSubstring: '<svg').
		self assert: (contents includesSubstring: 'width="640" height="480"').
		self assert: (contents includesSubstring: '<path').
		self deny: (contents includesSubstring: '<image') ]
]

{ #category : 'tests - saving' }
BpFigureTest >> withFileNamed: aBasename do: aBlock [
	"Evaluate aBlock with a file of the image directory, deleted afterwards."

	| file |
	file := FileLocator imageDirectory asFileReference / ('BpFigureTest-' , aBasename).
	[ aBlock value: file ] ensure: [ file ensureDelete ]
]
