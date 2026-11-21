"
I test `BpTextFormatter`: the printf strings of matplotlib `autopct` and the Python replacement fields of matplotlib `pie_label`.
"
Class {
	#name : 'BpTextFormatterTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests - format' }
BpTextFormatterTest >> testFormatAbsoluteValueOneDecimal [

	self assert: (BpTextFormatter format: '{absval:.1f}' absval: 36 frac: 0.45) equals: '36.0'
]

{ #category : 'tests - format' }
BpTextFormatterTest >> testFormatFractionAsPercent [

	self assert: (BpTextFormatter format: '{frac:.1%}' absval: 36 frac: 0.45) equals: '45.0%'
]

{ #category : 'tests - format' }
BpTextFormatterTest >> testFormatIntegerAndPercentOnTwoLines [

	self assert: (BpTextFormatter format: '{absval:d}\n{frac:.1%}' absval: 36 frac: 0.45) equals: (String cr join: #( '36' '45.0%' ))
]

{ #category : 'tests - format' }
BpTextFormatterTest >> testFormatKeepsSurroundingText [

	self assert: (BpTextFormatter format: '<{frac:.0%}>' absval: 8 frac: 0.125) equals: '<13%>'
]

{ #category : 'tests - errors' }
BpTextFormatterTest >> testFormatUnknownFieldRaisesError [

	self should: [ BpTextFormatter format: '{value}' absval: 8 frac: 0.1 ] raise: KeyNotFound
]

{ #category : 'tests - format' }
BpTextFormatterTest >> testFormatWithoutSpec [

	self assert: (BpTextFormatter format: 'v={absval}' absval: 8 frac: 0.1) equals: 'v=8'
]

{ #category : 'tests - printf' }
BpTextFormatterTest >> testPrintfInteger [

	self assert: (BpTextFormatter printf: '%d items' with: 12.6) equals: '13 items'
]

{ #category : 'tests - printf' }
BpTextFormatterTest >> testPrintfNoDecimal [

	self assert: (BpTextFormatter printf: '%.0f%%' with: 30.4) equals: '30%'
]

{ #category : 'tests - printf' }
BpTextFormatterTest >> testPrintfOneDecimalPercent [

	self assert: (BpTextFormatter printf: '%1.1f%%' with: 15) equals: '15.0%'
]

{ #category : 'tests - printf' }
BpTextFormatterTest >> testPrintfPlainText [

	self assert: (BpTextFormatter printf: 'none' with: 12) equals: 'none'
]
