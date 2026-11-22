# Bloc-Plotter

<a href="https://www.pharo.org">
    <img alt="Pharo" src="https://img.shields.io/static/v1?style=for-the-badge&message=Pharo&color=3297d4&logo=Harbor&logoColor=FFFFFF&label=" />
</a>

A matplotlib-like plotting library for [Bloc](https://github.com/pharo-graphics/Bloc): figures, axes and artists
for pie charts, histograms, scatter plots, line plots and box plots, with interactive patches and SVG, PDF and
PNG export.

Bloc-Plotter depends on Bloc v3.0.0.

## Loading

```smalltalk
Metacello new
	mvs;
	baseline: 'BlocPlotter';
	repository: 'github://pharo-graphics/Bloc-Plotter:v0.5.0/src';
	load.
```

To load the library without its tests, replace `load` with `load: 'Core'`.

## If you want to depend on it

```smalltalk
spec
	baseline: 'BlocPlotter'
	with: [ spec repository: 'github://pharo-graphics/Bloc-Plotter:v0.5.0/src' ].
```

----

> The best way to predict the future is to do it!
> Less talking more doing.
> Stéphane Ducasse
