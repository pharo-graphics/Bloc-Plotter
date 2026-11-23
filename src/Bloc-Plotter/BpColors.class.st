"
I provide the colors of the plots: the default color cycle (`tab10`), some named colors (`named:`, including the names of the cycle such as 'tab:blue' or 'C1'), and the viridis colormap (`viridis:`, or `colorMap:` which answers it as a block).

## Examples

```
BpColors scriptPalettes
```

## Usage

I have no instances: `BpAxes>>nextColors:`, `BpArtist>>initialize`, `BpArtist>>colorOf:`, `BpScatterPlot>>colorMapBlock`, `BpLine>>isColorName:` and `BpPie class>>defaultColors` use my class-side methods.
"
Class {
	#name : 'BpColors',
	#superclass : 'Object',
	#category : 'Bloc-Plotter-Support',
	#package : 'Bloc-Plotter',
	#tag : 'Support'
}

{ #category : 'colormaps' }
BpColors class >> colorMap: aName [
	"Answer the colormap named aName, as a block from a fraction between 0 and 1 to a color."

	aName asString = 'viridis' ifTrue: [ ^ [ :fraction | self viridis: fraction ] ].
	^ self error: 'Unknown colormap: ' , aName printString
]

{ #category : 'palettes' }
BpColors class >> named: aString [
	"Answer the named color aString ('g', 'red', 'tan', 'lime', 'tab:blue', 'C1' for the second color of the cycle, ...)."

	| tableau |
	tableau := #( 'tab:blue' 'tab:orange' 'tab:green' 'tab:red' 'tab:purple' 'tab:brown' 'tab:pink' 'tab:gray' 'tab:olive'
	              'tab:cyan' ) indexOf: aString.
	tableau > 0 ifTrue: [ ^ self tab10 at: tableau ].
	(aString size = 2 and: [ aString first = $C and: [ aString last isDigit ] ]) ifTrue: [
		^ self tab10 at: aString last digitValue + 1 ].
	^ Color fromHexString: (self namedColors at: aString)
]

{ #category : 'palettes' }
BpColors class >> namedColors [

	^ Dictionary newFromPairs:
		  #( 'b' '0000ff' 'g' '008000' 'r' 'ff0000' 'c' '00bfbf' 'm' 'bf00bf' 'y' 'bfbf00' 'k' '000000' 'w' 'ffffff' 'red' 'ff0000'
		     'green' '008000' 'blue' '0000ff' 'tan' 'd2b48c' 'lime' '00ff00' 'olivedrab' '6b8e23' 'rosybrown' 'bc8f8f' 'gray' '808080'
		     'grey' '808080' 'saddlebrown' '8b4513' 'black' '000000' 'white' 'ffffff' 'orange' 'ffa500' 'purple' '800080' 'brown'
		     'a52a2a' 'pink' 'ffc0cb' 'cyan' '00ffff' 'magenta' 'ff00ff' 'yellow' 'ffff00' 'navy' '000080' 'darkorange' 'ff8c00'
		     'lightblue' 'add8e6' 'lightgray' 'd3d3d3' 'darkgray' 'a9a9a9' 'silver' 'c0c0c0' 'gold' 'ffd700' 'orchid' 'da70d6' )
]

{ #category : 'script' }
BpColors class >> scriptPalettes [
	"Show the color cycle (tab10) on the first row and the viridis colormap on the second one."

	<example>
	| row space |
	row := [ :colors |
		       BlElement new
			       layout: BlLinearLayout horizontal;
			       constraintsDo: [ :c |
				       c horizontal fitContent.
				       c vertical fitContent ];
			       addChildren: (colors collect: [ :each |
				        BlElement new
					        background: each;
					        extent: 30 @ 30;
					        yourself ]);
			       yourself ].
	space := BlSpace new.
	space
		title: 'Palettes';
		extent: 340 @ 80.
	space root
		layout: BlLinearLayout vertical;
		addChildren: {
			(row value: self tab10).
			(row value: ((0 to: 10) collect: [ :each | self viridis: each / 10 ])) }.
	space show.
	^ space
]

{ #category : 'palettes' }
BpColors class >> tab10 [
	"Answer the default color cycle (the tab10 palette): the colors given in turn to wedges and datasets."

	^ #( '1f77b4' 'ff7f0e' '2ca02c' 'd62728' '9467bd' '8c564b' 'e377c2' '7f7f7f' 'bcbd22' '17becf' ) collect: [ :each |
		  Color fromHexString: each ]
]

{ #category : 'palettes' }
BpColors class >> viridis: aFraction [
	"Answer the color of the viridis colormap at aFraction, between 0 (dark purple) and 1 (yellow), interpolated between eleven samples of the map."

	| anchors position index |
	anchors := #( '440154' '482475' '414487' '355f8d' '2a788e' '21918c' '22a884' '44bf70' '7ad151' 'bddf26' 'fde725' ) collect: [
		           :each | Color fromHexString: each ].
	position := (aFraction min: 1 max: 0) * (anchors size - 1).
	index := position floor + 1 min: anchors size - 1.
	^ (anchors at: index) mixed: 1 - (position - (index - 1)) with: (anchors at: index + 1)
]
