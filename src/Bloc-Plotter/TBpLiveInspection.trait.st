"
I add a Live pane, the first one, to the inspector of every visual object of Bloc-Plotter: it shows the object in a Bloc space inside the inspector, so that it can be hovered and clicked as in its window.

## Examples

```
BpFigure exampleTwoByTwo inspect
```

## Design Rationale

- The pane shows `liveElement`: the topmost ancestor of an element, so that a patch or an axes is seen in its figure. An artist (`BpArtist>>liveElement`) shows the figure of its axes, or a new figure holding it; a marker (`BpMarker>>liveElement`) shows a patch drawing it.
- A Bloc element has one parent: the pane takes the element from where it is. It takes it from another Live pane, but not from a space shown in its own window, whose user would see it vanish; the pane then shows a snapshot.
- `prepareForLiveView` lets the element choose how it sits in the pane: centered by default, filling the pane for a `BpFigure`.

## Usage

1. The root classes of the visual hierarchies use me: `BpFigure`, `BpAxes`, `BpPlotArea`, `BpPatch`, `BpGridLine`, `BpLegend`, `BpText`, `BpPie`, `BpPieWedge`, `BpPieWedgeShadow`, `BpArtist` and `BpMarker`.
2. The inspector sends `inspectionLive:` (`<inspectorPresentationOrder: 0 title: 'Live'>`), which builds a `SpBlSpaceInMorphPresenter` holding the element.

## Implementation Notes

- `relayoutOnResize:` works around a Bloc bug: the first resize of a space embedded in a morph is not announced, so its root would keep its former size (logged in the Bloc backlog on 2026-11-21).

## Invariants and Assumptions

- `liveElement` answers a Bloc element.
"
Trait {
	#name : 'TBpLiveInspection',
	#category : 'Bloc-Plotter-Inspection',
	#package : 'Bloc-Plotter',
	#tag : 'Inspection'
}

{ #category : 'inspector extensions' }
TBpLiveInspection >> inspectionLive: aBuilder [
	"Show my live element in a Bloc space inside the inspector, so it can be used with the mouse. An element already shown in another space (a window) is not taken from it: its snapshot is shown instead."

	<inspectorPresentationOrder: 0 title: 'Live'>
	| element presenter root |
	element := self liveElement.
	(element isAttachedToSceneGraph and: [ (self isInLivePane: element) not ]) ifTrue: [
		^ aBuilder newMorph
			  morph: element asForm asMorph;
			  yourself ].
	element removeFromParent.
	element constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	element prepareForLiveView.
	presenter := aBuilder instantiate: SpBlSpaceInMorphPresenter.
	self relayoutOnResize: presenter space.
	root := presenter space root.
	root userData at: #bpLivePane put: true.
	root
		layout: BlFrameLayout new;
		addChild: element.
	^ presenter
]

{ #category : 'inspector extensions' }
TBpLiveInspection >> isInLivePane: anElement [
	"Answer whether anElement is shown by a Live pane, which another Live pane may take it from."

	^ anElement hasParent and: [ anElement parent userData at: #bpLivePane ifAbsent: [ false ] ]
]

{ #category : 'inspector extensions' }
TBpLiveInspection >> liveElement [
	"Answer the element the Live pane shows: my topmost ancestor below the root of a space, so that a part is seen in its figure."

	| element |
	element := self.
	[ element hasParent and: [ element parent isRoot not ] ] whileTrue: [ element := element parent ].
	^ element
]

{ #category : 'inspector extensions' }
TBpLiveInspection >> prepareForLiveView [
	"Prepare me to be the element of a Live pane, where I am centered. Nothing more to do by default."

	^ self
]

{ #category : 'inspector extensions' }
TBpLiveInspection >> relayoutOnResize: aSpace [
	"Lay the root of aSpace out again whenever it no longer has the size of aSpace. Work around a Bloc bug: the first resize of a space embedded in a morph is not announced, so the root keeps its former size (see P15-BlocBacklog, 2026-11-21)."

	aSpace
		addEventHandlerOn: BlSpaceEventsProcessedEvent
		do: [ :event | aSpace root extent = aSpace extent ifFalse: [ aSpace root requestLayout ] ]
]
