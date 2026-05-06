"
Orchestrates the benchmark matrix. Holds the result rows (one Dictionary per
measurement) and knows how to print them as a Transcript table or write a
CSV.

Public entry points (class side):
  IGBenchRunner runAll              - run + print to Transcript, return runner
  IGBenchRunner runAllAndExport     - run + print + write /tmp/insight-bench.csv

To tune workload sizes, edit #workloadSpecs below. To tune iteration counts,
edit IGBenchHarness class side defaults.
"
Class {
	#name : 'IGBenchRunner',
	#superclass : 'Object',
	#instVars : [
		'mock',
		'results'
	],
	#category : 'IG-Benchmarks-Runner',
	#package : 'IG-Benchmarks',
	#tag : 'Runner'
}

{ #category : 'running' }
IGBenchRunner class >> runAll [
	"Run benchmarks, print to Transcript, return the runner.
	 Inspect the runner's `results` to drill in."

	| runner |
	runner := self new.
	runner runBenchmarks.
	runner printResultsOn: Transcript.
	Transcript flush.
	^ runner
]

{ #category : 'running' }
IGBenchRunner class >> runAllAndExport [
	"Run + write a CSV at /tmp/insight-bench.csv (override path by sending
	 #exportCSV: directly)."

	| runner |
	runner := self runAll.
	runner exportCSV: '/tmp/insight-bench.csv'.
	Transcript show: 'CSV written to /tmp/insight-bench.csv'; cr; flush.
	^ runner
]

{ #category : 'private' }
IGBenchRunner >> addColdResult: selector code: aCode scenario: scenarioName category: cat stats: stats [

	results add: (Dictionary new
		at: #category put: cat;
		at: #workload put: selector;
		at: #code put: aCode;
		at: #scenario put: scenarioName;
		at: #min put: (stats at: #min);
		at: #median put: (stats at: #median);
		at: #mean put: (stats at: #mean);
		at: #max put: (stats at: #max);
		at: #count put: (stats at: #count);
		yourself)
]

{ #category : 'private' }
IGBenchRunner >> addSteadyResult: selector code: aCode scenario: scenarioName label: aLabel stats: stats [

	results add: (Dictionary new
		at: #category put: 'steady-state';
		at: #workload put: selector;
		at: #code put: aCode;
		at: #scenario put: scenarioName;
		at: #label put: aLabel;
		at: #min put: (stats at: #min);
		at: #median put: (stats at: #median);
		at: #mean put: (stats at: #mean);
		at: #max put: (stats at: #max);
		at: #count put: (stats at: #count);
		yourself)
]

{ #category : 'reporting' }
IGBenchRunner >> exportCSV: aFilename [

	| keys |
	keys := #(category workload code scenario label count min median mean max).
	aFilename asFileReference writeStreamDo: [ :s |
		s nextPutAll: 'category,workload,code,scenario,label,count,min_us,median_us,mean_us,max_us'.
		s nextPut: Character lf.
		results do: [ :r |
			keys doWithIndex: [ :k :i |
				i > 1 ifTrue: [ s nextPut: $, ].
				s nextPutAll: (r at: k ifAbsent: [ '' ]) asString ].
			s nextPut: Character lf ] ]
]

{ #category : 'initialization' }
IGBenchRunner >> initialize [

	super initialize.
	mock := IGBenchMock new.
	results := OrderedCollection new
]

{ #category : 'reporting' }
IGBenchRunner >> log: aString [
	"Progress log on the Transcript so the user sees we're alive."

	Transcript show: aString; cr; flush
]

{ #category : 'reporting' }
IGBenchRunner >> printResultsOn: aStream [

	#('setup' 'steady-state' 'teardown' 'profiler-end2end' 'profiler-scaling')
		do: [ :cat | self printSection: cat on: aStream ]
]

{ #category : 'reporting' }
IGBenchRunner >> printSection: cat on: aStream [

	| rows |
	rows := results select: [ :r | (r at: #category) = cat ].
	rows isEmpty ifTrue: [ ^ self ].
	aStream cr.
	aStream nextPutAll: '=== ', cat asUppercase, ' ==='.
	aStream cr.
	aStream nextPutAll: 'workload | code | scenario | median(us) | min(us) | max(us) | mean(us)'.
	aStream cr.
	rows do: [ :r |
		aStream
			nextPutAll: (r at: #workload) asString; nextPutAll: ' | ';
			nextPutAll: (r at: #code) asString; nextPutAll: ' | ';
			nextPutAll: (r at: #scenario) asString; nextPutAll: ' | ';
			nextPutAll: (r at: #median) printString; nextPutAll: ' | ';
			nextPutAll: (r at: #min) printString; nextPutAll: ' | ';
			nextPutAll: (r at: #max) printString; nextPutAll: ' | ';
			nextPutAll: (r at: #mean) printString.
		aStream cr ]
]

{ #category : 'accessing' }
IGBenchRunner >> results [

	^ results
]

{ #category : 'running' }
IGBenchRunner >> runBenchmarks [
	"Run the four benchmark families. Order matters only for progress
	 reporting; all results are independent."

	self log: '=== Insight benchmark run starting ==='.
	self runSetupCostBenchmarks.
	self runSteadyStateBenchmarks.
	self runTeardownCostBenchmarks.
	self runProfilerBenchmarks.
	self runProfilerScalingBenchmarks.
	self log: '=== Insight benchmark run complete ==='.
	self log: '   ', results size printString, ' result rows'
]

{ #category : 'benchmarks' }
IGBenchRunner >> runProfilerBenchmarks [
	"End-to-end IGCodeCoverageProfiler#profileOn: cost. One run = one full
	 pipeline (build counter, instrument target methods, run block, build
	 result, restore methods)."

	self log: '>> Profiler end-to-end benchmarks'.
	self workloadSpecs do: [ :spec | | selector block label samples stats |
		selector := spec at: 1.
		block := spec at: 2.
		label := spec at: 3.
		self log: '  workload: ', selector.
		samples := OrderedCollection new.
		IGBenchHarness defaultColdRuns timesRepeat: [ | profiler |
			profiler := IGCodeCoverageProfiler new.
			profiler methodsToInstrument: { IGBenchMock >> selector }.
			samples add: (IGBenchHarness timeMicros: [ profiler profileOn: block ]) ].
		stats := IGBenchHarness statisticsOf: samples.
		results add: (Dictionary new
			at: #category put: 'profiler-end2end';
			at: #workload put: selector;
			at: #code put: 'P0';
			at: #scenario put: 'profiler';
			at: #label put: label;
			at: #min put: (stats at: #min);
			at: #median put: (stats at: #median);
			at: #mean put: (stats at: #mean);
			at: #max put: (stats at: #max);
			at: #count put: (stats at: #count);
			yourself) ]
]

{ #category : 'benchmarks' }
IGBenchRunner >> runProfilerScalingBenchmarks [
	"Scaling test: vary the NUMBER of instrumented methods, keep the
	 exercised block constant. The block only invokes mediumMethod, so
	 every method beyond the first contributes setup cost only - this
	 isolates linear-in-method-count overhead."

	| pool poolSizes block |
	self log: '>> Profiler scaling benchmarks'.
	pool := #(tinyMethod lightMethod mediumMethod heavyMethod assignmentChain
	          tightLoop: tightLoopHeavy: messageSendHeavy: recursiveFactorial:).
	poolSizes := { 1. 5. pool size }.
	block := [ 30000 timesRepeat: [ mock mediumMethod ] ].
	poolSizes do: [ :nMethods | | methods samples stats |
		methods := (pool first: nMethods) collect: [ :sel | IGBenchMock >> sel ].
		self log: '  ', nMethods printString, ' methods'.
		samples := OrderedCollection new.
		IGBenchHarness defaultColdRuns timesRepeat: [ | profiler |
			profiler := IGCodeCoverageProfiler new.
			profiler methodsToInstrument: methods.
			samples add: (IGBenchHarness timeMicros: [ profiler profileOn: block ]) ].
		stats := IGBenchHarness statisticsOf: samples.
		results add: (Dictionary new
			at: #category put: 'profiler-scaling';
			at: #workload put: 'mediumMethod (driven block)';
			at: #code put: 'S', nMethods printString;
			at: #scenario put: 'instrumented ', nMethods printString, ' methods';
			at: #label put: 'N=', nMethods printString;
			at: #min put: (stats at: #min);
			at: #median put: (stats at: #median);
			at: #mean put: (stats at: #mean);
			at: #max put: (stats at: #max);
			at: #count put: (stats at: #count);
			yourself) ]
]

{ #category : 'benchmarks' }
IGBenchRunner >> runSetupCostBenchmarks [

	| scenarios |
	scenarios := IGBenchScenario all.
	self log: '>> Setup-cost benchmarks (instrumentMethod:)'.
	self workloadSpecs do: [ :spec | | selector original |
		selector := spec at: 1.
		original := IGBenchMock >> selector.
		self log: '  workload: ', selector.
		scenarios do: [ :scenario | | samples stats |
			samples := OrderedCollection new.
			IGBenchHarness defaultColdRuns timesRepeat: [ | inst |
				inst := IGInstrumentation new addHook: scenario buildHook.
				samples add: (IGBenchHarness timeMicros: [ inst instrumentMethod: original ]).
				inst uninstrumentMethod: original ].
			stats := IGBenchHarness statisticsOf: samples.
			self
				addColdResult: selector
				code: scenario code
				scenario: scenario name
				category: 'setup'
				stats: stats ] ]
]

{ #category : 'benchmarks' }
IGBenchRunner >> runSteadyStateBenchmarks [

	| scenarios |
	scenarios := IGBenchScenario all.
	self log: '>> Steady-state benchmarks'.
	self workloadSpecs do: [ :spec | | selector block label original baselineStats |
		selector := spec at: 1.
		block := spec at: 2.
		label := spec at: 3.
		original := IGBenchMock >> selector.
		self log: '  workload: ', selector, ' (', label, ')'.

		"Baseline: no instrumentation"
		baselineStats := IGBenchHarness
			measureSteadyState: block
			warmup: IGBenchHarness defaultWarmups
			iterations: IGBenchHarness defaultIterations.
		self
			addSteadyResult: selector
			code: 'B0'
			scenario: 'baseline'
			label: label
			stats: baselineStats.

		"Each scenario: install, measure, uninstall, store."
		scenarios do: [ :scenario | | inst stats |
			inst := IGInstrumentation new addHook: scenario buildHook.
			inst instrumentMethod: original.
			stats := IGBenchHarness
				measureSteadyState: block
				warmup: IGBenchHarness defaultWarmups
				iterations: IGBenchHarness defaultIterations.
			inst uninstrumentMethod: original.
			self
				addSteadyResult: selector
				code: scenario code
				scenario: scenario name
				label: label
				stats: stats ] ]
]

{ #category : 'benchmarks' }
IGBenchRunner >> runTeardownCostBenchmarks [

	| scenarios |
	scenarios := IGBenchScenario all.
	self log: '>> Teardown-cost benchmarks (uninstrumentMethod:)'.
	self workloadSpecs do: [ :spec | | selector original |
		selector := spec at: 1.
		original := IGBenchMock >> selector.
		self log: '  workload: ', selector.
		scenarios do: [ :scenario | | samples stats |
			samples := OrderedCollection new.
			IGBenchHarness defaultColdRuns timesRepeat: [ | inst |
				inst := IGInstrumentation new addHook: scenario buildHook.
				inst instrumentMethod: original.
				samples add: (IGBenchHarness timeMicros: [ inst uninstrumentMethod: original ]) ].
			stats := IGBenchHarness statisticsOf: samples.
			self
				addColdResult: selector
				code: scenario code
				scenario: scenario name
				category: 'teardown'
				stats: stats ] ]
]

{ #category : 'workloads' }
IGBenchRunner >> workloadSpecs [
	"Per-workload configuration: { selector. invocation block. label }.
	 The block is the timed unit. For straight-line methods it wraps the
	 call in a `timesRepeat:` so each measurement sits comfortably above
	 the timer noise floor (target: > 5 ms uninstrumented per measurement).

	 Tune these if your machine is much faster (raise) or much slower (lower).
	 Sized for a fast machine."

	^ {
		{ #tinyMethod.          [ 200000 timesRepeat: [ mock tinyMethod ] ].   '200k calls'  }.
		{ #lightMethod.         [ 100000 timesRepeat: [ mock lightMethod ] ].  '100k calls'  }.
		{ #mediumMethod.        [ 30000 timesRepeat: [ mock mediumMethod ] ].  '30k calls'   }.
		{ #heavyMethod.         [ 10000 timesRepeat: [ mock heavyMethod ] ].   '10k calls'   }.
		{ #assignmentChain.     [ 100000 timesRepeat: [ mock assignmentChain ] ]. '100k calls' }.
		{ #tightLoop:.          [ mock tightLoop: 500000 ].                    '500k iters'  }.
		{ #tightLoopHeavy:.     [ mock tightLoopHeavy: 30000 ].                '30k iters'   }.
		{ #messageSendHeavy:.   [ mock messageSendHeavy: 200000 ].             '200k sends'  }.
		{ #recursiveFactorial:. [ mock recursiveFactorial: 500 ].              'depth 500'   }
	}
]
