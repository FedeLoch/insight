"
Tiny custom benchmark harness. Provides:
  - microsecond-precision timing (Time microsecondsClock)
  - steady-state measurement with warmup
  - cold measurement (no warmup) for setup/teardown
  - basic statistics (min, median, mean, max)

Defaults are class-side methods so they can be tweaked at runtime through
the inspector without touching source.
"
Class {
	#name : 'IGBenchHarness',
	#superclass : 'Object',
	#category : 'IG-Benchmarks-Harness',
	#package : 'IG-Benchmarks',
	#tag : 'Harness'
}

{ #category : 'defaults' }
IGBenchHarness class >> defaultColdRuns [
	"Number of cold runs for setup / teardown benchmarks. No warmup is
	 possible because each run produces a fresh CompiledMethod."

	^ 10
]

{ #category : 'defaults' }
IGBenchHarness class >> defaultIterations [
	"Number of measured runs in a steady-state benchmark."

	^ 20
]

{ #category : 'defaults' }
IGBenchHarness class >> defaultWarmups [
	"Number of warmup runs before steady-state measurement.
	 3 is enough to push the Cog JIT past its hotness threshold for
	 normally-sized methods."

	^ 3
]

{ #category : 'measurement' }
IGBenchHarness class >> measureCold: aBlock iterations: n [
	"Run aBlock n times, no warmup. Suitable for setup/teardown.
	 Caller is responsible for resetting any external state between calls."

	| samples |
	samples := (1 to: n) collect: [ :i | self timeMicros: aBlock ].
	^ self statisticsOf: samples
]

{ #category : 'measurement' }
IGBenchHarness class >> measureSteadyState: aBlock warmup: w iterations: n [
	"Warmup w times (untimed), then time n iterations.
	 Returns a stats Dictionary - see #statisticsOf:."

	w timesRepeat: [ aBlock value ].
	^ self statisticsOf:
		((1 to: n) collect: [ :i | self timeMicros: aBlock ])
]

{ #category : 'statistics' }
IGBenchHarness class >> statisticsOf: samples [
	"samples is a Collection of integer microseconds.
	 Return a Dictionary with #min #max #median #mean #count."

	| sorted n median mean |
	sorted := samples asSortedCollection asArray.
	n := sorted size.
	median := n odd
		ifTrue: [ sorted at: n // 2 + 1 ]
		ifFalse: [ ((sorted at: n // 2) + (sorted at: n // 2 + 1)) / 2 ].
	mean := samples sum / n.
	^ Dictionary new
		at: #min put: sorted first;
		at: #max put: sorted last;
		at: #median put: median;
		at: #mean put: mean asFloat;
		at: #count put: n;
		yourself
]

{ #category : 'timing' }
IGBenchHarness class >> timeMicros: aBlock [
	"Run aBlock once, return microseconds elapsed as an Integer.
	 Uses the standard Pharo `Time microsecondsToRun:` class method."

	^ Time microsecondsToRun: aBlock
]
