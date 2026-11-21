"
I check the Live inspector pane of `TBpLiveInspection`: it is the first pane of every visual class, it shows the right element (a figure for a patch or an artist, a patch for a marker), it takes the element from a previous pane but not from a window, and it lays the element out at the size of the pane.

## Implementation Notes

- The panes are built with a bare `SpPresenterBuilder` and their spaces are closed in `tearDown`.
- `resize:to:` resizes the morph hosting a pane as the inspector does, then waits for the frames of the space: that resize is the one Bloc does not announce.
"
Class {
	#name : 'BpLiveInspectionTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenters'
	],
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'private' }
BpLiveInspectionTest >> livePaneOf: anObject [

	| pane |
	pane := anObject inspectionLive: SpPresenterBuilder new.
	presenters add: pane.
	^ pane
]

{ #category : 'private' }
BpLiveInspectionTest >> resize: aSpace to: anExtent [
	"Resize the morph hosting aSpace, as the inspector does, and let aSpace run its frames."

	aSpace settle.
	aSpace hostSpaceDo: [ :host | host windowExtent: anExtent ].
	aSpace requestPulse.
	aSpace settle.
	(Delay forMilliseconds: 300) wait
]

{ #category : 'running' }
BpLiveInspectionTest >> setUp [

	super setUp.
	presenters := OrderedCollection new
]

{ #category : 'running' }
BpLiveInspectionTest >> tearDown [

	presenters do: [ :each | (each isKindOf: SpBlSpaceInMorphPresenter) ifTrue: [ each space close ] ].
	super tearDown
]

{ #category : 'tests' }
BpLiveInspectionTest >> testASecondLivePaneTakesTheElementFromTheFirstOne [

	| figure first second |
	figure := BpFigure exampleTwoByTwo.
	first := self livePaneOf: figure.
	second := self livePaneOf: figure.
	self deny: (first space root children includes: figure).
	self assert: (second space root children includes: figure)
]

{ #category : 'tests' }
BpLiveInspectionTest >> testAnElementShownInAnotherSpaceIsNotTakenFromIt [

	| figure |
	figure := BpFigure exampleTwoByTwo.
	figure inNewHeadlessSpaceDo: [ :space |
		| pane |
		pane := self livePaneOf: figure.
		self assert: figure space identicalTo: space.
		self deny: (pane isKindOf: SpBlSpaceInMorphPresenter) ]
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAFigureIsTheFigure [

	| figure |
	figure := BpFigure exampleTwoByTwo.
	self assert: figure liveElement identicalTo: figure
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAFreeArtistIsANewFigureShowingIt [

	| line figure |
	line := BpLine exampleSine.
	figure := line liveElement.
	self assert: (figure isKindOf: BpFigure).
	self assert: figure axes first artists asArray equals: { line }
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAMarkerIsAPatchDrawingIt [

	| marker |
	marker := BpMarker exampleStar.
	self assert: marker liveElement marker identicalTo: marker
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAPatchIsItsFigure [

	| figure |
	figure := BpLine examplePlotType.
	self assert: figure axes first artists first patches first liveElement identicalTo: figure
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAnArtistIsItsFigure [

	| figure |
	figure := BpLine examplePlotType.
	self assert: figure axes first artists first liveElement identicalTo: figure
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveIsTheFirstPaneOfEveryVisualClass [

	{
		BpFigure.
		BpAxes.
		BpPie.
		BpPieWedge.
		BpPlotArea.
		BpMarkerPatch.
		BpPolygonPatch.
		BpRectanglePatch.
		BpGridLine.
		BpLegend.
		BpText.
		BpPieText.
		BpHistogram.
		BpScatterPlot.
		BpLine.
		BpBoxPlot.
		BpMarker } do: [ :each |
			| orders live |
			orders := each allSelectors asArray
				          collect: [ :selector | each lookupSelector: selector ]
				          thenSelect: [ :method | method hasPragmaNamed: #inspectorPresentationOrder:title: ].
			orders := orders collect: [ :method | (method pragmaAt: #inspectorPresentationOrder:title:) arguments ].
			live := orders detect: [ :pair | pair last = 'Live' ] ifNone: [ nil ].
			self assert: live isNotNil description: [ '{1} has no Live pane' format: { each name } ].
			self
				assert: (orders allSatisfy: [ :pair | pair == live or: [ pair first > live first ] ])
				description: [ '{1} has a pane before Live' format: { each name } ] ]
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneCentersAnElementOfItsOwnSize [

	| patch |
	patch := BpMarker exampleStar liveElement.
	self resize: (self livePaneOf: patch) space to: 300 @ 200.
	self assert: patch bounds inParent center equals: 150 @ 100
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneFollowsItsSize [
	"The first resize of a space hosted in a morph is not announced by Bloc: the Live pane must still lay its figure out at the new size."

	| figure |
	figure := BpFigure exampleTwoByTwo.
	self resize: (self livePaneOf: figure) space to: 300 @ 200.
	self assert: figure extent equals: 300 @ 200
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneOfAPatchShowsItsFigure [

	| figure pane |
	figure := BpLine examplePlotType.
	pane := self livePaneOf: figure axes first artists first patches first.
	self assert: (pane space root children includes: figure)
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneShowsTheElementInASpace [

	| figure pane |
	figure := BpFigure exampleTwoByTwo.
	pane := self livePaneOf: figure.
	self assert: (pane space root children includes: figure)
]
