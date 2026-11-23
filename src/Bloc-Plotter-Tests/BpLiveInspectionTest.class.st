"
I check the Live inspector pane of `TBpLiveInspection`: it is the first pane of every visual class, it shows the right element (a figure for a patch or an artist, a patch for a marker), it takes the element from a previous pane but not from a window, and it lays the element out at the size of the pane.

## Implementation Notes

- The panes are built with a bare `SpPresenterBuilder` and their spaces are closed in `tearDown`.
- `resize:to:` resizes the morph hosting a pane as the inspector does, then waits for the frames of the space: that resize is the one Bloc does not announce.
"
Class {
	#name : 'BpLiveInspectionTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'private' }
BpLiveInspectionTest >> livePaneOf: anObject [

	^ anObject inspectionLive: SpPresenterBuilder new
]

{ #category : 'private' }
BpLiveInspectionTest >> showInMorph: aPane resizedTo: anExtent [
	"Show the element of aPane in a space hosted by a morph, as the Morphic adapter of SpBlocPresenter does, then resize that morph as the inspector does and let the space run its frames."

	| space |
	space := BlSpace new.
	space host: (BlMorphicHost new
		 containerMorph: Morph new;
		 yourself).
	space show.
	[
		space root addChild: aPane blocElement.
		space settle.
		space hostSpaceDo: [ :host | host windowExtent: anExtent ].
		space requestPulse.
		space settle.
		(Delay forMilliseconds: 300) wait ] ensure: [ space close ]
]

{ #category : 'tests' }
BpLiveInspectionTest >> testASecondLivePaneTakesTheElementFromTheFirstOne [

	| figure first second |
	figure := BpFigure instanceTwoByTwo.
	first := self livePaneOf: figure.
	second := self livePaneOf: figure.
	self deny: (first blocElement children includes: figure).
	self assert: (second blocElement children includes: figure)
]

{ #category : 'tests' }
BpLiveInspectionTest >> testAnElementShownInAnotherSpaceIsNotTakenFromIt [

	| figure |
	figure := BpFigure instanceTwoByTwo.
	figure inNewHeadlessSpaceDo: [ :space |
		| pane |
		pane := self livePaneOf: figure.
		self assert: figure space identicalTo: space.
		self assert: (pane isKindOf: SpImagePresenter) ]
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAFigureIsTheFigure [

	| figure |
	figure := BpFigure instanceTwoByTwo.
	self assert: figure liveElement identicalTo: figure
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAFreeArtistIsANewFigureShowingIt [

	| line figure |
	line := BpLine instanceSine.
	figure := line liveElement.
	self assert: (figure isKindOf: BpFigure).
	self assert: figure charts first artists asArray equals: { line }
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAMarkerIsAPatchDrawingIt [

	| marker |
	marker := BpMarker instanceStar.
	self assert: marker liveElement marker identicalTo: marker
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAPatchIsItsFigure [

	| figure |
	figure := BpFigure instanceLinePlotType.
	self assert: figure charts first artists first patches first liveElement identicalTo: figure
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveElementOfAnArtistIsItsFigure [

	| figure |
	figure := BpFigure instanceLinePlotType.
	self assert: figure charts first artists first liveElement identicalTo: figure
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLiveIsTheFirstPaneOfEveryVisualClass [

	{
		BpFigure.
		BpChart.
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
	patch := BpMarker instanceStar liveElement.
	self showInMorph: (self livePaneOf: patch) resizedTo: 300 @ 200.
	self assert: patch bounds inParent center equals: 150 @ 100
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneFollowsItsSizeInAMorph [
	"The first resize of a space hosted in a morph (the Morphic backend) is not announced by Bloc: the Live pane must still lay its figure out at the new size."

	| figure |
	figure := BpFigure instanceTwoByTwo.
	self showInMorph: (self livePaneOf: figure) resizedTo: 300 @ 200.
	self assert: figure extent equals: 300 @ 200
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneOfAPatchShowsItsFigure [

	| figure pane |
	figure := BpFigure instanceLinePlotType.
	pane := self livePaneOf: figure charts first artists first patches first.
	self assert: (pane blocElement children includes: figure)
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneOpensInAToploInspector [

	| application window |
	application := SpApplication new
		               useBackend: #Toplo;
		               yourself.
	window := (StInspectorPresenter newApplication: application model: BpLine instanceSine) open.
	[ self assert: window isOpen ] ensure: [ window close ]
]

{ #category : 'tests' }
BpLiveInspectionTest >> testLivePaneShowsTheElement [

	| figure pane |
	figure := BpFigure instanceTwoByTwo.
	pane := self livePaneOf: figure.
	self assert: (pane blocElement children includes: figure)
]
