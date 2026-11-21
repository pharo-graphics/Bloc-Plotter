Extension { #name : 'Random' }

{ #category : '*Bloc-Plotter' }
Random >> nextNormal [
	"Answer a sample of the standard normal distribution (mean 0, deviation 1), as numpy random.standard_normal, using the Box-Muller transform of two uniform values."

	| u1 u2 |
	u1 := 1 - self next.
	u2 := self next.
	^ (-2 * u1 ln) sqrt * (2 * Float pi * u2) cos
]

{ #category : '*Bloc-Plotter' }
Random >> nextNormalMean: aMean deviation: aDeviation [
	"Answer a sample of the normal distribution of aMean and aDeviation, as numpy random.normal."

	^ aMean + (aDeviation * self nextNormal)
]
