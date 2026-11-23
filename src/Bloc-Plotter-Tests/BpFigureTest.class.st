"
I test `BpFigure`: its default size, its grid of charts and the palette it gives them.
"
Class {
	#name : 'BpFigureTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests' }
BpFigureTest >> testChartsAreCountedRowByRow [

	| figure |
	figure := BpFigure rows: 2 columns: 3.
	self assert: (figure chartAtRow: 2 column: 1) identicalTo: (figure charts at: 4)
]

{ #category : 'tests' }
BpFigureTest >> testDefaultExtentIs640By480 [

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
BpFigureTest >> testFigureExtentOfAFigureFillingItsParentIsItsExtent [

	| figure |
	figure := BpFigure new.
	figure inNewHeadlessSpaceDo: [ :space |
		figure constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
		space extent: 300 @ 200.
		space settle.
		self assert: figure figureExtent equals: figure extent ]
]

{ #category : 'tests - palette' }
BpFigureTest >> testNewChartsTakeTheFigurePalette [

	| figure palette |
	palette := BpQualitativePalette set1.
	figure := BpFigure new.
	figure palette: palette.
	figure rows: 2 columns: 1.
	self assert: (figure charts allSatisfy: [ :each | each palette == palette ])
]

{ #category : 'tests' }
BpFigureTest >> testNewFigureHasOneChart [

	self assert: BpFigure new charts size equals: 1
]

{ #category : 'tests - palette' }
BpFigureTest >> testPaletteIsGivenToAllCharts [

	| figure palette |
	palette := BpQualitativePalette set1.
	figure := BpFigure rows: 1 columns: 2.
	figure palette: palette.
	self assert: (figure charts allSatisfy: [ :each | each palette == palette ])
]

{ #category : 'tests' }
BpFigureTest >> testRowsColumnsChartClassCreatesChartsOfThatClass [

	| figure |
	figure := BpFigure rows: 1 columns: 2 chartClass: BpPolarChart.
	self assert: figure charts size equals: 2.
	self assert: (figure charts allSatisfy: [ :each | each class = BpPolarChart ])
]

{ #category : 'tests' }
BpFigureTest >> testRowsColumnsChartClassGivesThePalette [

	| figure palette |
	palette := BpQualitativePalette set1.
	figure := BpFigure new.
	figure palette: palette.
	figure rows: 1 columns: 2 chartClass: BpPolarChart.
	self assert: (figure charts allSatisfy: [ :each | each palette == palette ])
]

{ #category : 'tests' }
BpFigureTest >> testRowsColumnsCreatesAGridOfCharts [

	self assert: (BpFigure rows: 2 columns: 3) charts size equals: 6
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsPDFWritesAPdf [

	self withFileNamed: 'figure.pdf' do: [ :file |
		BpFigure instanceTwoByTwo saveAsPDF: file.
		self assert: (file binaryReadStreamDo: [ :stream | (stream next: 5) asString ]) equals: '%PDF-' ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsPNGDpiScalesTheImage [

	self withFileNamed: 'figure.png' do: [ :file |
		BpFigure instanceTwoByTwo saveAsPNG: file dpi: 200.
		self assert: (file binaryReadStreamDo: [ :stream | (PNGReadWriter on: stream) nextImage ]) extent equals: 1280 @ 960 ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsPNGHasTheFigureExtent [

	self withFileNamed: 'figure.png' do: [ :file |
		BpFigure instanceTwoByTwo saveAsPNG: file.
		self assert: (file binaryReadStreamDo: [ :stream | (PNGReadWriter on: stream) nextImage ]) extent equals: 640 @ 480 ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsSVGAnswersTheFile [

	self withFileNamed: 'figure.svg' do: [ :file | self assert: (BpFigure instanceTwoByTwo saveAsSVG: file) equals: file ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsSVGDoesNotDependOnTheExtension [

	self withFileNamed: 'figure.txt' do: [ :file |
		BpFigure instanceTwoByTwo saveAsSVG: file.
		self assert: (file contents includesSubstring: '<svg') ]
]

{ #category : 'tests - saving' }
BpFigureTest >> testSaveAsSVGWritesVectorGraphics [

	self withFileNamed: 'figure.svg' do: [ :file |
		| contents |
		BpFigure instanceTwoByTwo saveAsSVG: file.
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
