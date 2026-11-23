"
I am a pie chart: a Bloc element showing values as wedges, labeled with `labels:`, `autoPct:` and `addLabels:`. I show one `BpPieWedge` per value, optional `BpPieWedgeShadow`s behind them, and `BpPieText`s around them, all placed by my `BpPieLayout`. `whenWedge:do:` adds an interaction handler to all my wedges.

## Examples

```
BpPie scriptPieFeatures.
BpPie scriptPieLabels.
BpPie scriptInteraction.
BpPie exampleExplodeShadowRotate
```

## Design Rationale

- `autoPct:` takes a printf string or a block, and the default colors are the tab10 cycle (`BpColors tab10`).
- Angles are in degrees, counterclockwise from the right. The wedges convert them to the clockwise angles of `BlAnnulusSectorGeometry`.
- Every setter rebuilds all my children. It keeps me simple, at the price of losing the handlers added directly to a wedge: `whenWedge:do:` keeps them across rebuilds.
- A pie of radius 1 fills 1/1.25 of my half side. Nothing is drawn outside me, so I shrink when an exploded wedge or a text would get out of my bounds.
- I have one slot per option, hence many slots.

## Usage

1. Each setter rebuilds my wedges, shadows and texts (`rebuild`).
2. `addLabels:distance:rotate:textStyle:` keeps a `BpPieLabelSet` and answers it.
3. `whenWedge:do:` keeps its handlers and gives them to the new wedges of each rebuild.
4. When I am shown, `BpPieLayout` asks me to fit my radius (`fitUnitRadiusIn:`) and places each part.

- I am mutable: keep me, not my wedges, which are replaced at each change.

## Implementation Notes

- Only my wedges, shadows and texts are laid out; other children are not placed by `BpPieLayout`.
- Not supported yet: hatches, legends, rotating the texts of `labels:`, a center other than the origin, and a frame. The shadow is a darker, half transparent copy of each wedge.
"
Class {
	#name : 'BpPie',
	#superclass : 'BlElement',
	#traits : 'TBpLiveInspection',
	#classTraits : 'TBpLiveInspection classTrait',
	#instVars : [
		'values',
		'labels',
		'colors',
		'explode',
		'pctDistance',
		'labelDistance',
		'startAngle',
		'radius',
		'shadow',
		'normalize',
		'wedgeStyle',
		'textStyle',
		'labelSets',
		'wedgeHandlers',
		'wedges',
		'texts',
		'shadows',
		'unitRadius',
		'autoPct',
		'counterClock'
	],
	#category : 'Bloc-Plotter-Pie',
	#package : 'Bloc-Plotter',
	#tag : 'Pie'
}

{ #category : 'defaults' }
BpPie class >> defaultColors [
	"Answer the colors given in turn to the wedges: the tab10 cycle."

	^ BpColors tab10
]

{ #category : 'private - demo' }
BpPie class >> demoCellFor: aPie caption: aString [
	"Answer an element showing aPie, 300 pixels wide, under aString."

	^ BlElement new
		  layout: BlLinearLayout vertical;
		  constraintsDo: [ :c |
			  c horizontal fitContent.
			  c vertical fitContent ];
		  padding: (BlInsets all: 5);
		  addChild: (BlTextElement new text: (aString asRopedText
			    fontSize: 13;
			    bold;
			    yourself));
		  addChild: (aPie
			   extent: 300 @ 300;
			   yourself);
		  yourself
]

{ #category : 'private - demo' }
BpPie class >> demoOpen: aCollectionOfAssociations title: aString [
	"Open a space showing in a grid each pie (association value) under its caption (association key)."

	| grid space |
	grid := BlElement new
		        layout: (BlGridLayout horizontal columnCount: 4);
		        background: Color white;
		        constraintsDo: [ :c |
			        c horizontal fitContent.
			        c vertical fitContent ];
		        yourself.
	aCollectionOfAssociations do: [ :each | grid addChild: (self demoCellFor: each value caption: each key) ].
	space := BlSpace new.
	space
		title: aString;
		extent: 1260 @ 700.
	space root
		background: Color white;
		addChild: grid.
	space show.
	^ space
]

{ #category : 'examples' }
BpPie class >> exampleAutoPct [
	"Answer a pie with its labels and the percentage of each wedge with one decimal."

	<sampleInstance>
	^ self frogsPie
		  autoPct: '%1.1f%%';
		  yourself
]

{ #category : 'examples' }
BpPie class >> exampleColors [
	"Answer a pie with its labels and chosen wedge colors: olive drab, rosy brown, gray and saddle brown."

	<sampleInstance>
	^ self frogsPie
		  colors: (#( '6b8e23' 'bc8f8f' '808080' '8b4513' ) collect: [ :each | Color fromHexString: each ]);
		  yourself
]

{ #category : 'examples' }
BpPie class >> exampleExplodeShadowRotate [
	"Answer a pie whose second wedge is pulled out, with shadows, percentages, and the first wedge starting at the top (start angle 90)."

	<sampleInstance>
	^ self frogsPie
		  explode: #( 0 0.1 0 0 );
		  autoPct: '%1.1f%%';
		  shadow: true;
		  startAngle: 90;
		  yourself
]

{ #category : 'examples' }
BpPie class >> exampleLabels [
	"Answer a pie with one label per wedge, given by `labels:`."

	<sampleInstance>
	^ self frogsPie
]

{ #category : 'examples' }
BpPie class >> examplePieLabel [
	"Answer a pie with one label per wedge, added with `addLabels:`."

	<sampleInstance>
	^ self spamPie
		  addLabels: self spamLabels;
		  yourself
]

{ #category : 'examples' }
BpPie class >> examplePieLabelAbsoluteValues [
	"Answer a pie showing the value of each wedge with one decimal."

	<sampleInstance>
	^ self spamPie
		  addLabels: '{absval:.1f}';
		  yourself
]

{ #category : 'examples' }
BpPie class >> examplePieLabelOutside [
	"Answer a pie with one label per wedge, outside it at 1.1 times the radius."

	<sampleInstance>
	^ self spamPie
		  addLabels: self spamLabels distance: 1.1;
		  yourself
]

{ #category : 'examples' }
BpPie class >> examplePieLabelPercents [
	"Answer a pie showing the percentage of each wedge with one decimal."

	<sampleInstance>
	^ self spamPie
		  addLabels: '{frac:.1%}';
		  yourself
]

{ #category : 'examples' }
BpPie class >> examplePieLabelRotated [
	"Answer a pie whose labels are rotated along their wedge."

	<sampleInstance>
	^ self spamPie
		  addLabels: self spamLabels
		  distance: 0.6
		  rotate: true
		  textStyle: nil;
		  yourself
]

{ #category : 'examples' }
BpPie class >> examplePieLabelSeveralSets [
	"Answer a pie with three label sets: the names outside, the percentages at 0.7 and the values at 0.4 of the radius."

	<sampleInstance>
	^ self spamPie
		  addLabels: self spamLabels distance: 1.1;
		  addLabels: '{frac:.1%}' distance: 0.7;
		  addLabels: '{absval:d}' distance: 0.4;
		  yourself
]

{ #category : 'examples' }
BpPie class >> examplePieLabelTextStyle [
	"Answer a pie whose labels are written large and white."

	<sampleInstance>
	^ self spamPie
		  addLabels: self spamLabels
		  distance: 0.6
		  rotate: false
		  textStyle: [ :text |
			  text
				  fontSize: 18;
				  foreground: Color white ];
		  yourself
]

{ #category : 'examples' }
BpPie class >> examplePieLabelValuesAndPercents [
	"Answer a pie showing the value and, below it, the percentage of each wedge."

	<sampleInstance>
	^ self spamPie
		  addLabels: '{absval:d}\n{frac:.1%}';
		  yourself
]

{ #category : 'examples' }
BpPie class >> exampleSmallRadius [
	"Answer a pie of half the radius, with small percentages without decimals."

	<sampleInstance>
	^ self frogsPie
		  autoPct: '%.0f%%';
		  textStyle: [ :text | text fontSize: 9 ];
		  radius: 0.5;
		  yourself
]

{ #category : 'examples' }
BpPie class >> exampleSwapLabelsAndPercents [
	"Answer a pie with its percentages outside, at 1.25 times the radius, and its labels inside, at 0.6."

	<sampleInstance>
	^ self frogsPie
		  autoPct: '%1.1f%%';
		  pctDistance: 1.25;
		  labelDistance: 0.6;
		  yourself
]

{ #category : 'examples' }
BpPie class >> exampleWedgeStyle [
	"Answer a pie whose wedges are separated by a white border 3 pixels wide."

	<sampleInstance>
	^ self frogsPie
		  wedgeStyle: [ :wedge | wedge border: (BlBorder paint: Color white width: 3) ];
		  yourself
]

{ #category : 'private - demo' }
BpPie class >> frogsPie [
	"Answer the labeled pie that the pie features examples configure."

	^ self new
		  values: #( 15 30 45 10 );
		  labels: #( 'Frogs' 'Hogs' 'Dogs' 'Logs' );
		  yourself
]

{ #category : 'script' }
BpPie class >> scriptInteraction [
	"Interaction handlers on wedges: hovering a wedge explodes it, clicking it shows its value under the pie."

	<example>
	| pie info container space |
	info := BlTextElement new text: ('Click a wedge' asRopedText fontSize: 16).
	pie := self frogsPie
		       autoPct: '%1.1f%%';
		       yourself.
	pie
		whenWedge: BlMouseEnterEvent do: [ :event :wedge |
			wedge explode: 0.1.
			pie requestLayout ];
		whenWedge: BlMouseLeaveEvent do: [ :event :wedge |
			wedge explode: 0.
			pie requestLayout ];
		whenWedge: BlClickEvent do: [ :event :wedge |
			info text: (('{1}: {2} ({3})' format: {
				  wedge label.
				  wedge amount.
				  (BpTextFormatter printf: '%1.1f%%' with: wedge fraction * 100) }) asRopedText fontSize: 16) ].
	container := BlElement new
		             layout: BlLinearLayout vertical;
		             padding: (BlInsets all: 10);
		             constraintsDo: [ :c |
			             c horizontal matchParent.
			             c vertical matchParent ];
		             addChildren: {
			             pie.
			             info };
		             yourself.
	space := BlSpace new.
	space
		title: 'Pie interaction';
		extent: 440 @ 480.
	space root
		background: Color white;
		addChild: container.
	space show.
	^ space
]

{ #category : 'script' }
BpPie class >> scriptPieFeatures [
	"Show the features of pies: labels, percentages, colors, swapped labels and percentages, explode with shadow and start angle, small radius, and wedge style."

	<example>
	^ self
		  demoOpen: {
			  ('Label slices' -> self exampleLabels).
			  ('Auto-label slices' -> self exampleAutoPct).
			  ('Color slices' -> self exampleColors).
			  ('Swap labels and percents' -> self exampleSwapLabelsAndPercents).
			  ('Explode, shadow, rotate' -> self exampleExplodeShadowRotate).
			  ('Shrink pie' -> self exampleSmallRadius).
			  ('Wedge style' -> self exampleWedgeStyle) }
		  title: 'Pie features'
]

{ #category : 'script' }
BpPie class >> scriptPieLabels [
	"Show the ways to label a pie with `addLabels:`: labels inside, outside or rotated, absolute values, percentages, both, styled text, and several label sets on one pie."

	<example>
	^ self
		  demoOpen: {
			  ('Basic labels' -> self examplePieLabel).
			  ('Labels outside' -> self examplePieLabelOutside).
			  ('Rotated labels' -> self examplePieLabelRotated).
			  ('Absolute values' -> self examplePieLabelAbsoluteValues).
			  ('Percentages' -> self examplePieLabelPercents).
			  ('Values and percentages' -> self examplePieLabelValuesAndPercents).
			  ('Font styling' -> self examplePieLabelTextStyle).
			  ('Multiple label sets' -> self examplePieLabelSeveralSets) }
		  title: 'Pie labels'
]

{ #category : 'private - demo' }
BpPie class >> spamLabels [

	^ #( 'spam' 'eggs' 'bacon' 'sausage' )
]

{ #category : 'private - demo' }
BpPie class >> spamPie [
	"Answer an unlabeled pie, which the examples of `addLabels:` label in different ways."

	^ self new
		  values: #( 36 24 8 12 );
		  yourself
]

{ #category : 'private - interaction' }
BpPie >> addHandler: anAssociation to: aWedge [

	aWedge addEventHandler: (BlEventHandler
		 on: anAssociation key
		 do: [ :event | anAssociation value cull: event cull: aWedge ])
]

{ #category : 'labels' }
BpPie >> addLabels: aSource [

	^ self addLabels: aSource distance: 0.6
]

{ #category : 'labels' }
BpPie >> addLabels: aSource distance: aNumber [

	^ self
		  addLabels: aSource
		  distance: aNumber
		  rotate: false
		  textStyle: nil
]

{ #category : 'labels' }
BpPie >> addLabels: aSource distance: aNumber rotate: aBoolean textStyle: aBlockOrNil [
	"Add one text per wedge. aSource is a collection of strings, a format string such as '{absval:d}\n{frac:.1%}', or a block receiving the wedge. aNumber is the distance from the center as a fraction of the radius. Answer the new label set."

	| labelSet |
	labelSet := (BpPieLabelSet labels: aSource distance: aNumber)
		            rotate: aBoolean;
		            textStyle: aBlockOrNil;
		            yourself.
	labelSets add: labelSet.
	self rebuild.
	^ labelSet
]

{ #category : 'private - building' }
BpPie >> allLabelSets [
	"Answer the label sets for my labels and percentages (`labels:` and `autoPct:`), followed by the ones added with addLabels:..."

	| sets |
	sets := OrderedCollection new.
	labels ifNotNil: [
		sets add: ((BpPieLabelSet labels: labels distance: labelDistance)
			 textStyle: textStyle;
			 yourself) ].
	autoPct ifNotNil: [
		sets add: ((BpPieLabelSet percent: autoPct distance: pctDistance)
			 textStyle: textStyle;
			 yourself) ].
	^ sets
		  addAll: labelSets;
		  yourself
]

{ #category : 'geometry' }
BpPie >> anchorOf: aText [

	^ self anchorOf: aText in: self extent
]

{ #category : 'geometry' }
BpPie >> anchorOf: aText in: anExtent [
	"Answer the point aText is placed around: on the bisector of its wedge, at its distance from the wedge center."

	| wedge |
	wedge := aText wedge.
	^ (self wedgeCenterOf: wedge in: anExtent) - (anExtent / 2)
	  + (self pointAtAngle: wedge midAngle distance: aText distance in: anExtent)
]

{ #category : 'accessing' }
BpPie >> autoPct [

	^ autoPct
]

{ #category : 'accessing' }
BpPie >> autoPct: aStringOrBlock [
	"Show the percentage of each wedge at pctDistance, formatted with a printf string such as '%1.1f%%' or by a block receiving the percentage."

	autoPct := aStringOrBlock.
	self rebuild
]

{ #category : 'accessing' }
BpPie >> colors [

	^ colors
]

{ #category : 'accessing' }
BpPie >> colors: aCollectionOfColors [
	"Set the wedge colors, used in turn when there are fewer colors than wedges."

	colors := aCollectionOfColors.
	self rebuild
]

{ #category : 'accessing' }
BpPie >> counterClock [

	^ counterClock
]

{ #category : 'accessing' }
BpPie >> counterClock: aBoolean [

	counterClock := aBoolean.
	self rebuild
]

{ #category : 'private - building' }
BpPie >> direction [
	"Answer 1 when the wedges go counterclockwise, -1 otherwise."

	^ counterClock
		  ifTrue: [ 1 ]
		  ifFalse: [ -1 ]
]

{ #category : 'accessing' }
BpPie >> explode [

	^ explode
]

{ #category : 'accessing' }
BpPie >> explode: aCollectionOfNumbers [
	"Set, for each wedge, how far it is moved away from the center, as a fraction of the radius."

	explode := aCollectionOfNumbers.
	self rebuild
]

{ #category : 'geometry' }
BpPie >> fitUnitRadiusIn: anExtent [
	"Compute the radius of a pie of radius 1 in anExtent: the one of `frameRadiusIn:`, made smaller when an exploded wedge or a text would get out of anExtent. My texts must be measured first."

	| fitted halfSide |
	fitted := self frameRadiusIn: anExtent.
	halfSide := (anExtent x min: anExtent y) / 2.
	radius > 0 ifTrue: [ wedges do: [ :each | fitted := fitted min: halfSide / (radius * (1 + each explode)) ] ].
	texts do: [ :each | fitted := fitted min: (each maxUnitRadiusIn: anExtent radius: radius) ].
	unitRadius := fitted
]

{ #category : 'geometry' }
BpPie >> frameRadiusIn: anExtent [
	"Answer the radius of a pie of radius 1 when the half of the smallest side of anExtent is 1.25, so that a pie is shown between -1.25 and 1.25."

	^ (anExtent x min: anExtent y) / 2 / 1.25
]

{ #category : 'initialization' }
BpPie >> initialize [

	super initialize.
	values := #(  ).
	explode := #(  ).
	colors := self class defaultColors.
	pctDistance := 0.6.
	labelDistance := 1.1.
	startAngle := 0.
	radius := 1.
	counterClock := true.
	shadow := false.
	normalize := true.
	labelSets := OrderedCollection new.
	wedgeHandlers := OrderedCollection new.
	wedges := #(  ).
	shadows := #(  ).
	texts := #(  ).
	self layout: BpPieLayout new.
	self extent: 400 @ 400
]

{ #category : 'accessing' }
BpPie >> labelDistance [

	^ labelDistance
]

{ #category : 'accessing' }
BpPie >> labelDistance: aNumber [

	labelDistance := aNumber.
	self rebuild
]

{ #category : 'accessing - parts' }
BpPie >> labelSets [
	"Answer the label sets added with addLabels:..."

	^ labelSets
]

{ #category : 'accessing' }
BpPie >> labels [

	^ labels
]

{ #category : 'accessing' }
BpPie >> labels: aCollectionOfStrings [
	"Set one label per wedge, shown at labelDistance."

	labels := aCollectionOfStrings.
	self rebuild
]

{ #category : 'private - building' }
BpPie >> newWedgeAt: anIndex amount: aNumber fraction: aFraction from: anAngle [

	| wedge |
	wedge := BpPieWedge new
		         index: anIndex;
		         amount: aNumber;
		         fraction: aFraction;
		         theta1: anAngle theta2: anAngle + (self direction * 360 * aFraction);
		         explode: (explode at: anIndex ifAbsent: [ 0 ]);
		         label: (labels ifNotNil: [ labels at: anIndex ]);
		         background: (colors at: anIndex - 1 \\ colors size + 1);
		         yourself.
	wedgeStyle ifNotNil: [ wedgeStyle value: wedge ].
	wedgeHandlers do: [ :each | self addHandler: each to: wedge ].
	^ wedge
]

{ #category : 'private - building' }
BpPie >> newWedges [
	"Answer one wedge per value, each starting where the previous one ends."

	| total angle |
	values ifEmpty: [ ^ #(  ) ].
	total := normalize
		         ifTrue: [ (values inject: 0 into: [ :sum :each | sum + each ]) asFloat ]
		         ifFalse: [ 1 ].
	angle := startAngle.
	^ values asArray withIndexCollect: [ :each :index |
		  | wedge |
		  wedge := self
			           newWedgeAt: index
			           amount: each
			           fraction: each / total
			           from: angle.
		  angle := wedge theta2.
		  wedge ]
]

{ #category : 'accessing' }
BpPie >> normalize [

	^ normalize
]

{ #category : 'accessing' }
BpPie >> normalize: aBoolean [
	"When true (the default) the values are divided by their sum to make a full pie; when false they are used as fractions, so a sum below 1 gives a partial pie."

	normalize := aBoolean.
	self rebuild
]

{ #category : 'accessing - parts' }
BpPie >> parts [
	"Answer the children my layout places: shadows, wedges and texts."

	^ shadows , wedges , texts
]

{ #category : 'accessing' }
BpPie >> pctDistance [

	^ pctDistance
]

{ #category : 'accessing' }
BpPie >> pctDistance: aNumber [

	pctDistance := aNumber.
	self rebuild
]

{ #category : 'geometry' }
BpPie >> pointAtAngle: anAngle distance: aDistance [
	"Answer the point, in my coordinates, at anAngle (degrees, counterclockwise from the right) and aDistance from my center, as a fraction of the radius."

	^ self pointAtAngle: anAngle distance: aDistance in: self extent
]

{ #category : 'geometry' }
BpPie >> pointAtAngle: anAngle distance: aDistance in: anExtent [
	"Answer the point of a pie drawn in anExtent at anAngle (degrees, counterclockwise from the right) and aDistance from the center, as a fraction of the radius."

	| length radians |
	length := (self unitRadiusIn: anExtent) * radius * aDistance.
	radians := anAngle degreesToRadians.
	^ anExtent / 2 + (radians cos * length @ (radians sin * length) negated)
]

{ #category : 'accessing' }
BpPie >> radius [

	^ radius
]

{ #category : 'accessing' }
BpPie >> radius: aNumber [
	"Set the pie radius, 1 being the default size."

	radius := aNumber.
	self rebuild
]

{ #category : 'private - building' }
BpPie >> rebuild [
	"Recreate my shadows, wedges and texts from my configuration."

	self removeChildren.
	wedges := self newWedges.
	shadows := shadow
		           ifTrue: [ wedges collect: [ :each | BpPieWedgeShadow on: each ] ]
		           ifFalse: [ #(  ) ].
	texts := self allLabelSets flatCollect: [ :each | each textsFor: wedges ].
	self addChildren: self parts
]

{ #category : 'accessing' }
BpPie >> shadow [

	^ shadow
]

{ #category : 'accessing' }
BpPie >> shadow: aBoolean [

	shadow := aBoolean.
	self rebuild
]

{ #category : 'geometry' }
BpPie >> shadowOffsetIn: anExtent [
	"Answer how far shadows are moved: to the bottom left, by 2% of the radius."

	^ (self unitRadiusIn: anExtent) * radius * (-0.02 @ 0.02)
]

{ #category : 'accessing - parts' }
BpPie >> shadows [

	^ shadows
]

{ #category : 'accessing' }
BpPie >> startAngle [

	^ startAngle
]

{ #category : 'accessing' }
BpPie >> startAngle: aNumber [
	"Set the angle where the first wedge starts, in degrees, counterclockwise from the right."

	startAngle := aNumber.
	self rebuild
]

{ #category : 'accessing' }
BpPie >> textStyle [

	^ textStyle
]

{ #category : 'accessing' }
BpPie >> textStyle: aBlock [
	"aBlock receives the BlText of each label and percentage text to change its font, size or color."

	textStyle := aBlock.
	self rebuild
]

{ #category : 'accessing - parts' }
BpPie >> texts [

	^ texts
]

{ #category : 'geometry' }
BpPie >> unitRadiusIn: anExtent [
	"Answer the radius, in pixels, of a pie of radius 1 drawn in anExtent, as fitted by my layout (see fitUnitRadiusIn:)."

	^ unitRadius ifNil: [ self frameRadiusIn: anExtent ]
]

{ #category : 'accessing' }
BpPie >> values [

	^ values
]

{ #category : 'accessing' }
BpPie >> values: aCollectionOfNumbers [
	"Set the wedge sizes."

	values := aCollectionOfNumbers.
	self rebuild
]

{ #category : 'accessing - parts' }
BpPie >> wedgeAt: anIndex [

	^ wedges at: anIndex
]

{ #category : 'geometry' }
BpPie >> wedgeCenterOf: aWedge in: anExtent [
	"Answer the center of aWedge: my center, moved along its bisector when it is exploded."

	^ self pointAtAngle: aWedge midAngle distance: aWedge explode in: anExtent
]

{ #category : 'geometry' }
BpPie >> wedgeDiameterIn: anExtent [

	^ (self unitRadiusIn: anExtent) * radius * 2
]

{ #category : 'accessing' }
BpPie >> wedgeStyle [

	^ wedgeStyle
]

{ #category : 'accessing' }
BpPie >> wedgeStyle: aBlock [
	"aBlock receives each wedge once it is built, to change its border, opacity, ..."

	wedgeStyle := aBlock.
	self rebuild
]

{ #category : 'accessing - parts' }
BpPie >> wedges [

	^ wedges
]

{ #category : 'interaction' }
BpPie >> whenWedge: anEventClass do: aBlock [
	"Evaluate aBlock with the event and the wedge each time a wedge receives an event of anEventClass. Unlike a handler added to a wedge directly, it is kept when I rebuild my wedges."

	wedgeHandlers add: anEventClass -> aBlock.
	wedges do: [ :each | self addHandler: anEventClass -> aBlock to: each ]
]
