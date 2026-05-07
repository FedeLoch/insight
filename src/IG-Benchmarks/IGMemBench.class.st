"
Memory benchmarks for Insight, complementary to IGBenchRunner.

Two distinct experiments:

1. LEAK TEST (long-term retention) - runs N cycles of
   `instrumentMethod: -> uninstrumentMethod:` and checks whether the live
   instance counts of suspect classes have grown after a forced GC. If a
   counter or instrumentation object survives, that's a leak signal.

2. ALLOCATION TEST (single profileOn: run) - measures the GC churn (full GC
   count delta + image used-memory delta) caused by one full
   `IGCodeCoverageProfiler#profileOn:` pipeline. Tells you what one profiler
   run costs in GC pressure.

The two are reported separately - they answer different questions. Leak test
asks 'does Insight clean up after itself?'. Allocation test asks 'how much
memory churn does one profiling run cause?'.

Methodology notes:
- Always force a full GC before and after each measurement window. Counts
  reflect what survives, not transient allocations.
- Tracked class names are listed in `trackedClassNames` - extend if you want
  to watch additional classes for leaks.
- B0 (uninstrumented baseline) is meaningful only for the allocation test.
  In the leak test it would mean 'do nothing N times', which is uninformative,
  so the leak test runs only on instrumented scenarios.

Public entry points (class side):
  IGMemBench runAll           - run both experiments, print to Transcript
  IGMemBench runAllAndExport  - as above + write /tmp/insight-mem.csv
"
Class {
	#name : 'IGMemBench',
	#superclass : 'Object',
	#instVars : [
		'mock',
		'results'
	],
	#category : 'IG-Benchmarks-Memory',
	#package : 'IG-Benchmarks',
	#tag : 'Memory'
}

{ #category : 'defaults' }
IGMemBench class >> defaultLeakCycles [
	"Number of instrument/uninstrument cycles per leak-test cell."

	^ 1000
]

{ #category : 'running' }
IGMemBench class >> runAll [

	| bench |
	bench := self new.
	bench runAllExperiments.
	bench printResultsOn: Transcript.
	Transcript flush.
	^ bench
]

{ #category : 'running' }
IGMemBench class >> runAllAndExport [

	| bench |
	bench := self runAll.
	bench exportCSV: '/tmp/insight-mem.csv'.
	Transcript show: 'CSV written to /tmp/insight-mem.csv'; cr; flush.
	^ bench
]

{ #category : 'configuration' }
IGMemBench class >> trackedClassNames [
	"Classes whose live-instance count we monitor for leak detection.
	 The first group is Insight-internal; the second group catches leaks
	 in the rewritten methods themselves."

	^ #(
		'IGInstrumentation'
		'IGCounter'
		'IGCollector'
		'IGAfterStatementHook'
		'IGBeforeStatementHook'
		'IGStatementResultReification'
		'IGInstrumentationContext'
		'OCMethodNode'
	)
]

{ #category : 'configuration' }
IGMemBench >> allocationScenarios [
	"All four scenarios for the allocation test; B0 is the control
	 (no profiler at all - just runs the workload bare)."

	^ {
		nil "B0 - represented as nil; the allocation test special-cases it".
		IGBenchScenario coverageScenario "C1".
		IGBenchScenario afterStatementCollectorAst "A1".
		IGBenchScenario afterStatementCollectorResult "R1"
	}
]

{ #category : 'configuration' }
IGMemBench >> leakScenarios [
	"Leak test runs only on instrumented scenarios. B0 omitted (nothing to
	 instrument, nothing to leak)."

	^ {
		IGBenchScenario coverageScenario "C1".
		IGBenchScenario afterStatementCollectorAst "A1".
		IGBenchScenario afterStatementCollectorResult "R1"
	}
]

{ #category : 'configuration' }
IGMemBench >> workloads [

	^ #(mediumMethod heavyMethod tightLoopHeavy:)
]

{ #category : 'configuration' }
IGMemBench >> workloadInvocations [
	"Per-workload block used by the allocation test. These match
	 IGBenchRunner>>workloadSpecs but are local copies so the memory
	 bench can be run independently."

	^ Dictionary new
		at: #mediumMethod    put: [ 30000 timesRepeat: [ mock mediumMethod ] ];
		at: #heavyMethod     put: [ 10000 timesRepeat: [ mock heavyMethod ] ];
		at: #tightLoopHeavy: put: [ mock tightLoopHeavy: 30000 ];
		yourself
]

{ #category : 'initialization' }
IGMemBench >> initialize [

	super initialize.
	mock := IGBenchMock new.
	results := OrderedCollection new
]

{ #category : 'reporting' }
IGMemBench >> log: aString [

	Transcript show: aString; cr; flush
]

{ #category : 'snapshotting' }
IGMemBench >> takeSnapshot [
	"Force a full GC, then capture: full-GC count, used memory bytes,
	 and live instance counts for each tracked class.
	 Returns a Dictionary with #gcCount #usedBytes #counts (Dict).
	 The forced GC ensures we measure RETAINED objects, not transient."

	| counts |
	Smalltalk garbageCollect.
	counts := Dictionary new.
	self class trackedClassNames do: [ :nm |
		counts at: nm put: (self instanceCountFor: nm) ].
	^ Dictionary new
		at: #gcCount put: (Smalltalk vm parameterAt: 7);
		at: #usedBytes put: (Smalltalk vm parameterAt: 3);
		at: #counts put: counts;
		yourself
]

{ #category : 'snapshotting' }
IGMemBench >> instanceCountFor: aClassNameString [
	"Look up the class by name and ask for its instance count.
	 Returns nil if the class doesn't exist (so the bench survives if
	 some tracked class isn't loaded)."

	| cls |
	cls := Smalltalk globals at: aClassNameString asSymbol ifAbsent: [ ^ nil ].
	^ cls instanceCount
]

{ #category : 'snapshotting' }
IGMemBench >> diffSnapshots: before and: after [
	"Return a Dictionary with the deltas: #gcCount, #usedBytes,
	 and per-class count deltas under #counts."

	| countsBefore countsAfter deltaCounts |
	countsBefore := before at: #counts.
	countsAfter := after at: #counts.
	deltaCounts := Dictionary new.
	countsBefore keysDo: [ :k | | b a |
		b := countsBefore at: k.
		a := countsAfter at: k.
		(b notNil and: [ a notNil ])
			ifTrue: [ deltaCounts at: k put: a - b ]
			ifFalse: [ deltaCounts at: k put: nil ] ].
	^ Dictionary new
		at: #gcCount put: (after at: #gcCount) - (before at: #gcCount);
		at: #usedBytes put: (after at: #usedBytes) - (before at: #usedBytes);
		at: #counts put: deltaCounts;
		yourself
]

{ #category : 'leak test' }
IGMemBench >> runLeakTests [
	"For each (scenario, workload), run N instrument/uninstrument cycles,
	 force GC before and after, and record what survived.
	 Live counts of Insight classes should NOT grow after the forced GC."

	| n |
	n := self class defaultLeakCycles.
	self log: '>> Leak test (', n printString, ' cycles per cell)'.
	self leakScenarios do: [ :scenario |
		self workloads do: [ :selector |
			self log: '  ', scenario code, ' on ', selector.
			self runOneLeakCellFor: scenario workload: selector cycles: n ] ]
]

{ #category : 'leak test' }
IGMemBench >> runOneLeakCellFor: scenario workload: selector cycles: n [
	"One leak-test cell. The cycle var is nilled out before the after-snapshot
	 so we don't artificially keep instances alive."

	| target before after delta inst |
	target := IGBenchMock >> selector.

	"Pre-warm: do a few cycles before snapshotting, so first-time class
	 initialization doesn't show as a leak."
	5 timesRepeat: [
		inst := IGInstrumentation new addHook: scenario buildHook.
		inst instrumentMethod: target.
		inst uninstrumentMethod: target ].
	inst := nil.

	before := self takeSnapshot.

	n timesRepeat: [
		inst := IGInstrumentation new addHook: scenario buildHook.
		inst instrumentMethod: target.
		inst uninstrumentMethod: target ].
	inst := nil.

	after := self takeSnapshot.
	delta := self diffSnapshots: before and: after.

	results add: (Dictionary new
		at: #experiment put: 'leak';
		at: #scenario put: scenario code;
		at: #scenarioName put: scenario name;
		at: #workload put: selector;
		at: #cycles put: n;
		at: #beforeBytes put: (before at: #usedBytes);
		at: #afterBytes put: (after at: #usedBytes);
		at: #deltaBytes put: (delta at: #usedBytes);
		at: #deltaGCCount put: (delta at: #gcCount);
		at: #deltaCounts put: (delta at: #counts);
		yourself)
]

{ #category : 'allocation test' }
IGMemBench >> runAllocationTests [
	"For each (scenario, workload), run ONE full profileOn: pipeline (or
	 just the bare workload for B0), measure GC count delta and retained
	 memory delta after a forced GC."

	self log: '>> Allocation test (one profileOn: per cell)'.
	self allocationScenarios do: [ :scenario |
		self workloads do: [ :selector |
			self log: '  ', (scenario ifNil: [ 'B0' ] ifNotNil: [ scenario code ]),
				 ' on ', selector.
			self runOneAllocationCellFor: scenario workload: selector ] ]
]

{ #category : 'allocation test' }
IGMemBench >> runOneAllocationCellFor: scenario workload: selector [
	"One allocation cell. nil scenario means 'just run the workload bare'
	 (the B0 control)."

	| target block before after delta code name |
	target := IGBenchMock >> selector.
	block := (self workloadInvocations) at: selector.
	scenario
		ifNil: [ code := 'B0'. name := 'baseline (no profiler)' ]
		ifNotNil: [ code := scenario code. name := scenario name ].

	"Single warmup so the JIT and class initializers don't pollute the snapshot."
	scenario
		ifNil: [ block value ]
		ifNotNil: [ | warmup |
			warmup := IGCodeCoverageProfiler new.
			warmup methodsToInstrument: { target }.
			warmup profileOn: block ].

	before := self takeSnapshot.

	scenario
		ifNil: [ block value ]
		ifNotNil: [ | profiler |
			profiler := IGCodeCoverageProfiler new.
			profiler methodsToInstrument: { target }.
			profiler profileOn: block.
			profiler := nil ].

	after := self takeSnapshot.
	delta := self diffSnapshots: before and: after.

	results add: (Dictionary new
		at: #experiment put: 'allocation';
		at: #scenario put: code;
		at: #scenarioName put: name;
		at: #workload put: selector;
		at: #beforeBytes put: (before at: #usedBytes);
		at: #afterBytes put: (after at: #usedBytes);
		at: #deltaBytes put: (delta at: #usedBytes);
		at: #deltaGCCount put: (delta at: #gcCount);
		at: #deltaCounts put: (delta at: #counts);
		yourself)
]

{ #category : 'running' }
IGMemBench >> runAllExperiments [

	self log: '=== Insight memory bench starting ==='.
	self log: '   pre-bench full GC...'.
	Smalltalk garbageCollect.
	self runLeakTests.
	self runAllocationTests.
	self log: '=== Insight memory bench complete ==='.
	self log: '   ', results size printString, ' result rows'
]

{ #category : 'accessing' }
IGMemBench >> results [

	^ results
]

{ #category : 'reporting' }
IGMemBench >> printResultsOn: aStream [

	self printLeakResultsOn: aStream.
	self printAllocationResultsOn: aStream
]

{ #category : 'reporting' }
IGMemBench >> printLeakResultsOn: aStream [

	| rows |
	rows := results select: [ :r | (r at: #experiment) = 'leak' ].
	rows isEmpty ifTrue: [ ^ self ].
	aStream cr; nextPutAll: '=== LEAK TEST ==='; cr.
	aStream nextPutAll: '(deltaBytes/deltaGCCount measured around N cycles, after forced GC each side)'; cr.
	aStream nextPutAll: 'scenario | workload | cycles | deltaBytes | deltaGCCount'; cr.
	rows do: [ :r |
		aStream
			nextPutAll: (r at: #scenario); nextPutAll: ' | ';
			nextPutAll: (r at: #workload) asString; nextPutAll: ' | ';
			nextPutAll: (r at: #cycles) printString; nextPutAll: ' | ';
			nextPutAll: (r at: #deltaBytes) printString; nextPutAll: ' | ';
			nextPutAll: (r at: #deltaGCCount) printString; cr.
		"Per-class deltas inline if any are non-zero - this is the actual leak signal."
		(r at: #deltaCounts) keysAndValuesDo: [ :cls :d |
			(d notNil and: [ d ~= 0 ]) ifTrue: [
				aStream nextPutAll: '    +', d printString, ' ', cls; cr ] ] ]
]

{ #category : 'reporting' }
IGMemBench >> printAllocationResultsOn: aStream [

	| rows |
	rows := results select: [ :r | (r at: #experiment) = 'allocation' ].
	rows isEmpty ifTrue: [ ^ self ].
	aStream cr; nextPutAll: '=== ALLOCATION TEST (one profileOn: per cell) ==='; cr.
	aStream nextPutAll: 'scenario | workload | deltaBytes (retained) | deltaGCCount'; cr.
	rows do: [ :r |
		aStream
			nextPutAll: (r at: #scenario); nextPutAll: ' | ';
			nextPutAll: (r at: #workload) asString; nextPutAll: ' | ';
			nextPutAll: (r at: #deltaBytes) printString; nextPutAll: ' | ';
			nextPutAll: (r at: #deltaGCCount) printString; cr ]
]

{ #category : 'reporting' }
IGMemBench >> exportCSV: aFilename [
	"Long-form CSV: one row per (cell, tracked-class). Easier to pivot
	 later than a wide format."

	aFilename asFileReference writeStreamDo: [ :s |
		s nextPutAll: 'experiment,scenario,scenarioName,workload,cycles,deltaBytes,deltaGCCount,trackedClass,deltaCount'.
		s nextPut: Character lf.
		results do: [ :r | | counts |
			counts := r at: #deltaCounts.
			counts keysAndValuesDo: [ :cls :d |
				s nextPutAll: (r at: #experiment); nextPut: $,;
				  nextPutAll: (r at: #scenario); nextPut: $,;
				  nextPutAll: (r at: #scenarioName); nextPut: $,;
				  nextPutAll: (r at: #workload) asString; nextPut: $,;
				  nextPutAll: ((r at: #cycles ifAbsent: [ '' ]) asString); nextPut: $,;
				  nextPutAll: (r at: #deltaBytes) printString; nextPut: $,;
				  nextPutAll: (r at: #deltaGCCount) printString; nextPut: $,;
				  nextPutAll: cls; nextPut: $,;
				  nextPutAll: (d ifNil: [ '' ] ifNotNil: [ d printString ]).
				s nextPut: Character lf ] ] ]
]
