"
I am a tick of a `BpColorBar`: I place my mark on the right of the strip, beside the color of my location, and my label next to it. See `BpTick`.

## Examples

```
BpColorBarTick instanceOfHarvest
```

## Usage

`BpColorBar>>newTicks` creates me, and `BpColorBarLayout` sends me `layoutIn:context:` with the bar.
"
Class {
	#name : 'BpColorBarTick',
	#superclass : 'BpTick',
	#category : 'Bloc-Plotter-ColorBar',
	#package : 'Bloc-Plotter',
	#tag : 'ColorBar'
}

{ #category : 'instances' }
BpColorBarTick class >> instanceOfHarvest [
	"Answer the lowest tick of a color bar."

	<sampleInstance>
	^ BpColorBar instanceOfHarvest ticks first
]

{ #category : 'layout' }
BpColorBarTick >> layoutIn: aColorBar context: aBlElementBoundsUpdater [
	"Place my mark on the right of the strip, beside the color of my location, and my label next to it."

	| y size |
	y := aColorBar yOf: location in: aColorBar measuredExtent y.
	size := label measuredExtent.
	mark applyLayoutIn: (aColorBar thickness @ (y - 0.5) extent: 3.5 @ 1) context: aBlElementBoundsUpdater.
	label applyLayoutIn: (aColorBar thickness + 6 @ (y - (size y / 2)) extent: size) context: aBlElementBoundsUpdater
]
