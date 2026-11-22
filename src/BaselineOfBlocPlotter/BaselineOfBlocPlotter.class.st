"
I describe how Metacello loads Bloc-Plotter, the matplotlib-like plotting library built on Bloc: its packages `Bloc-Plotter` and `Bloc-Plotter-Tests`, and the Bloc release they depend on.

I am used through `Metacello new baseline: 'BlocPlotter'; repository: 'github://pharo-graphics/Bloc-Plotter:master/src'; load`; `load: 'Core'` loads the library without its tests.

## Design Rationale

- Bloc is pinned to the tag `v3.0.0` instead of a branch, so a load always gets the Bloc API Bloc-Plotter was written against (`BlElement`, `BlSvgPath`, the `BAExporter` family of `Bloc-Alexandrie-Exporter` used by `BpFigure>>#saveAsSVG:`, `BpFigure>>#saveAsPDF:` and `BpFigure>>#saveAsPNG:dpi:`).
- I depend on the whole Bloc baseline rather than on some of its packages: Bloc-Plotter uses both the core elements and the Alexandrie exporters, and Bloc's baseline has no groups to pick from.
- The groups `Core` (the library) and `Tests` let a user load the plotting library alone; `default` loads both.

## Usage

Metacello creates and uses me when a user loads the project, or when Iceberg loads the repository; nobody else sends me messages.
"
Class {
	#name : 'BaselineOfBlocPlotter',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBlocPlotter',
	#package : 'BaselineOfBlocPlotter'
}

{ #category : 'baselines' }
BaselineOfBlocPlotter >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec baseline: 'Bloc' with: [ spec repository: 'github://pharo-graphics/Bloc:v3.0.0/src' ].
		spec
			package: 'Bloc-Plotter' with: [ spec requires: #( 'Bloc' ) ];
			package: 'Bloc-Plotter-Tests' with: [ spec requires: #( 'Bloc-Plotter' ) ].
		spec
			group: 'Core' with: #( 'Bloc-Plotter' );
			group: 'Tests' with: #( 'Bloc-Plotter-Tests' );
			group: 'default' with: #( 'Core' 'Tests' ) ]
]
