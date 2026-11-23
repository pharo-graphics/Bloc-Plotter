"
I am a patch of an artist: an element drawn in a `BpPlotArea` from data coordinates, like matplotlib `Patch`. I know my `artist`, the index of the `dataset` I show, my `dataBounds` and, once measured, my `pixelBounds`. My subclasses are the bars (`BpRectanglePatch`) and outlines (`BpPolygonPatch`) of a `BpHistogram`, the bars of a `BpBarPlot`, the markers (`BpMarkerPatch`) of a `BpScatterPlot`, the line (`BpPolygonPatch`) and markers of a `BpLine`, the lines and markers of a `BpBoxPlot`, and the stems, baseline and markers of a `BpStemPlot`.

## Examples

```
BpPatch scriptBarsAndSteps
```

## Usage

1. `BpHistogram>>newBarAt:dataset:amount:bounds:`, `BpHistogram>>newStepFor:top:base:shift:`, `BpBarPlot>>newBarAt:`, `BpScatterPlot>>newPatches`, `BpLine>>newLinePatch`, `BpLine>>newMarkerPatchAt:index:`, `BpBoxPlot>>newPolygon:closed:dataset:`, `BpBoxPlot>>newMarkerAt:props:dataset:`, `BpStemPlot>>newLineThrough:color:style:` and `BpStemPlot>>newMarkerAt:index:marker:color:` create patches, style them and add the handlers given to `BpArtist>>whenPatch:do:`.
2. `BpAxes>>rebuild` shows them in its plot area, and `BpAxes>>autoScale:` reads their `dataBounds`.
3. `BpPlotAreaLayout` sends `measureWith:` with the data transform of the axes, then places them at their `pixelBounds`.

- A patch shows one computation of its artist: it is not updated when the artist changes, it is replaced.
"
Class {
	#name : 'BpPatch',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'artist',
		'dataset',
		'pixelBounds'
	],
	#category : 'Bloc-Plotter-Axes',
	#package : 'Bloc-Plotter',
	#tag : 'Axes'
}

{ #category : 'script' }
BpPatch class >> scriptBarsAndSteps [
	"Show the two kinds of patches: bars (BpRectanglePatch) for the bar histtypes, outlines (BpPolygonPatch) for the step ones."

	<example>
	^ BpHistogram exampleHistTypes show: 'Bars and steps'
]

{ #category : 'accessing' }
BpPatch >> artist [

	^ artist
]

{ #category : 'accessing' }
BpPatch >> artist: anArtist [

	artist := anArtist
]

{ #category : 'accessing' }
BpPatch >> dataBounds [
	"Answer the rectangle I cover in data coordinates."

	^ self subclassResponsibility
]

{ #category : 'accessing' }
BpPatch >> dataset [
	"Answer the index of the dataset I show."

	^ dataset
]

{ #category : 'accessing' }
BpPatch >> dataset: anInteger [

	dataset := anInteger
]

{ #category : 'layout' }
BpPatch >> measureWith: aTransform [
	"Compute my bounds in the plot area from my data coordinates, and take their size."

	pixelBounds := self pixelBoundsWith: aTransform.
	self measure: (BlExtentMeasurementSpec exact: pixelBounds extent)
]

{ #category : 'accessing' }
BpPatch >> pixelBounds [
	"Answer my bounds in the plot area, as computed by the last layout."

	^ pixelBounds
]

{ #category : 'layout' }
BpPatch >> pixelBoundsWith: aTransform [

	^ self subclassResponsibility
]
