"
I am a patch of an artist: an element drawn in a `BpPlotArea` from data coordinates. I know my `artist`, the index of the `dataset` I show, my `dataBounds` and, once measured, my `pixelBounds`. My subclasses are the bars (`BpRectanglePatch`) and outlines (`BpPolygonPatch`) of a `BpHistogram`, the bars of a `BpBarPlot`, the markers (`BpMarkerPatch`) of a `BpScatterPlot`, the line (`BpPolygonPatch`) and markers of a `BpLine`, the lines and markers of a `BpBoxPlot`, the stems, baseline and markers of a `BpStemPlot`, and the polygons (`BpPolygonPatch`) of a `BpFillBetween`, a `BpStackPlot` or a `BpStairs`, the bodies and lines of a `BpViolinPlot`, and the bars, caps and arrows of a `BpErrorBar`.

## Examples

```
BpPatch exampleBarsAndSteps
```

## Usage

1. `BpHistogram>>newBarAt:dataset:amount:bounds:`, `BpHistogram>>newStepFor:top:base:shift:`, `BpBarPlot>>newBarAt:`, `BpScatterPlot>>newPatches`, `BpLine>>newLinePatch`, `BpLine>>newMarkerPatchAt:index:`, `BpBoxPlot>>newPolygon:closed:dataset:`, `BpBoxPlot>>newMarkerAt:properties:dataset:`, `BpStemPlot>>newLineThrough:color:style:`, `BpStemPlot>>newMarkerAt:index:marker:color:`, `BpFillBetween>>newPolygonThrough:`, `BpStackPlot>>newPolygonFor:tops:bottoms:`, `BpStairs>>newPatches`, `BpViolinPlot>>newPatch:through:dataset:style:`, `BpErrorBar>>newBarFrom:to:index:` and `BpErrorBar>>newCap:at:index:` create patches, style them and add the handlers given to `BpArtist>>whenPatch:do:`.
2. `BpChart>>rebuild` shows them in its plot area, and `BpChart>>autoScale:` reads their `dataBounds`.
3. `BpPlotAreaLayout` sends `measureWith:` with the data transform of the chart, then places them at their `pixelBounds`.

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
	#category : 'Bloc-Plotter-Chart',
	#package : 'Bloc-Plotter',
	#tag : 'Chart'
}

{ #category : 'examples' }
BpPatch class >> exampleBarsAndSteps [
	"Show the two kinds of patches: bars (BpRectanglePatch) for the bar histogram types, outlines (BpPolygonPatch) for the step ones (see `BpHistogram>>histType:`)."

	<example>
	^ BpFigure instanceHistTypes show: 'Bars and steps'
]

{ #category : 'accessing' }
BpPatch >> artist [

	^ artist
]

{ #category : 'accessing' }
BpPatch >> artist: anArtist [

	artist := anArtist
]

{ #category : 'layout' }
BpPatch >> bePolar [
	"Take the shape I need in a polar chart. Nothing to do when my shape is made of points: the transform moves them."

	
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
