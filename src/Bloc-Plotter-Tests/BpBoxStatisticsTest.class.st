"
I check `BpBoxStatistics` against the values matplotlib `cbook.boxplot_stats` computes: numpy linear percentiles, whisker ends on data, fliers, mean, notch interval, and whiskers given as percentiles.
"
Class {
	#name : 'BpBoxStatisticsTest',
	#superclass : 'TestCase',
	#category : 'Bloc-Plotter-Tests',
	#package : 'Bloc-Plotter-Tests'
}

{ #category : 'tests - errors' }
BpBoxStatisticsTest >> testEmptyDataRaisesError [

	self should: [ BpBoxStatistics of: #(  ) ] raise: Error
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testMean [

	self assert: (BpBoxStatistics of: #( 1 2 3 10 )) mean equals: 4
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testNotchIsTheConfidenceIntervalOfTheMedian [

	| stats |
	stats := BpBoxStatistics of: (1 to: 9).
	self assert: (stats confidenceLow closeTo: 5 - (1.57 * 4 / 3)).
	self assert: (stats confidenceHigh closeTo: 5 + (1.57 * 4 / 3))
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testPercentilesInterpolateLinearlyAsNumpy [

	| stats |
	stats := BpBoxStatistics of: #( 1 2 3 4 ).
	self assert: stats q1 equals: 7 / 4.
	self assert: stats median equals: 5 / 2.
	self assert: stats q3 equals: 13 / 4
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testQuartilesOfNineValues [

	| stats |
	stats := BpBoxStatistics of: (9 to: 1 by: -1).
	self assert: stats q1 equals: 3.
	self assert: stats median equals: 5.
	self assert: stats q3 equals: 7.
	self assert: stats iqr equals: 4
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testShorterWhiskers [

	| stats |
	stats := BpBoxStatistics of: #( 0 4 5 6 7 8 12 ) whiskers: 0.75.
	self assert: stats q1 equals: 9 / 2.
	self assert: stats q3 equals: 15 / 2.
	self assert: stats whiskerLow equals: 4.
	self assert: stats whiskerHigh equals: 8.
	self assert: stats fliers sorted equals: #( 0 12 )
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testValuesBeyondTheWhiskersAreFliers [

	| stats |
	stats := BpBoxStatistics of: #( 1 2 3 4 100 ).
	self assert: stats whiskerHigh equals: 4.
	self assert: stats whiskerLow equals: 1.
	self assert: stats fliers asArray equals: #( 100 )
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testWhiskersAsPercentiles [

	| stats |
	stats := BpBoxStatistics of: (1 to: 9) whiskers: #( 5 95 ).
	self assert: stats whiskerLow equals: 2.
	self assert: stats whiskerHigh equals: 8.
	self assert: stats fliers sorted equals: #( 1 9 )
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testWhiskersReachTheExtremeDataWithinOneAndAHalfIqr [

	| stats |
	stats := BpBoxStatistics of: (1 to: 9).
	self assert: stats whiskerLow equals: 1.
	self assert: stats whiskerHigh equals: 9.
	self assert: stats fliers isEmpty
]

{ #category : 'tests' }
BpBoxStatisticsTest >> testWhiskersStopAtTheBoxWhenNoDataIsBeyondIt [

	| stats |
	stats := BpBoxStatistics of: #( 0 1 9 10 ) whiskers: 0.
	self assert: stats whiskerLow equals: stats q1.
	self assert: stats whiskerHigh equals: stats q3
]
