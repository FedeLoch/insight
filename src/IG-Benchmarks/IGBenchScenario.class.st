"
A named hook+action configuration. Each scenario is a 'recipe' for building
a fresh hook every time we need a clean measurement.

The factory block returns a fresh hook with a fresh action - this matters
because counters and collectors hold mutable state.
"
Class {
	#name : 'IGBenchScenario',
	#superclass : 'Object',
	#instVars : [
		'name',
		'code',
		'hookFactory'
	],
	#category : 'IG-Benchmarks-Scenarios',
	#package : 'IG-Benchmarks',
	#tag : 'Scenarios'
}

{ #category : 'configurations' }
IGBenchScenario class >> afterAssignmentCounter [
	"H3: After-assignment, single-key counter. Fires only on assignment
	 statements."

	^ self
		code: 'H3'
		name: 'AfterAssign + Counter'
		factory: [ IGAfterAssignmentHook new do: IGCounter new ]
]

{ #category : 'configurations' }
IGBenchScenario class >> afterStatementCollectorAst [
	"A1: Collector that captures the AST node. Compare to H1 to isolate
	 OrderedCollection-add cost vs Dictionary-increment cost."

	^ self
		code: 'A1'
		name: 'AfterStmt + Collector[astNode]'
		factory: [
			IGAfterStatementHook new
				do: (IGCollector collect: [ :ctx | ctx astNode ]) ]
]

{ #category : 'configurations' }
IGBenchScenario class >> afterStatementCollectorReceiver [
	"A2: Collector that captures the receiver. Different reification path
	 (variable node vs literal node). Compare to A1."

	^ self
		code: 'A2'
		name: 'AfterStmt + Collector[receiver]'
		factory: [
			IGAfterStatementHook new
				do: (IGCollector collect: [ :ctx | ctx receiver ]) ]
]

{ #category : 'configurations' }
IGBenchScenario class >> afterStatementCounter [
	"H1: After-statement, single-key counter (no per-node dictionary growth).
	 Compare to C1 to isolate Dictionary at:update: cost."

	^ self
		code: 'H1'
		name: 'AfterStmt + Counter'
		factory: [ IGAfterStatementHook new do: IGCounter new ]
]

{ #category : 'configurations' }
IGBenchScenario class >> all [
	"The 7 scenarios benchmarked in every workload row."

	^ {
		self coverageScenario.
		self afterStatementCounter.
		self beforeStatementCounter.
		self afterAssignmentCounter.
		self beforeAssignmentCounter.
		self afterStatementCollectorAst.
		self afterStatementCollectorReceiver
	}
]

{ #category : 'configurations' }
IGBenchScenario class >> beforeAssignmentCounter [
	"H4: Before-assignment variant of H3."

	^ self
		code: 'H4'
		name: 'BeforeAssign + Counter'
		factory: [ IGBeforeAssignmentHook new do: IGCounter new ]
]

{ #category : 'configurations' }
IGBenchScenario class >> beforeStatementCounter [
	"H2: Before-statement variant of H1."

	^ self
		code: 'H2'
		name: 'BeforeStmt + Counter'
		factory: [ IGBeforeStatementHook new do: IGCounter new ]
]

{ #category : 'instance creation' }
IGBenchScenario class >> code: aCode name: aName factory: aBlock [

	^ self new
		code: aCode;
		name: aName;
		hookFactory: aBlock;
		yourself
]

{ #category : 'configurations' }
IGBenchScenario class >> coverageScenario [
	"C1: the exact path used by IGCodeCoverageProfiler (After-statement +
	 keyed counter). The headline number for ''how much does coverage cost?''."

	^ self
		code: 'C1'
		name: 'AfterStmt + Counter[astNode]'
		factory: [
			IGAfterStatementHook new
				do: (IGCounter new countKeyBy: #astNode) ]
]

{ #category : 'building' }
IGBenchScenario >> buildHook [
	"Return a fresh hook + fresh action. Called every time we want a clean
	 measurement (cold runs, fresh state for each steady-state measurement)."

	^ hookFactory value
]

{ #category : 'accessing' }
IGBenchScenario >> code [
	"Short code like 'C1', 'H1'. Used in CSV / table headers."

	^ code
]

{ #category : 'accessing' }
IGBenchScenario >> code: aString [

	code := aString
]

{ #category : 'accessing' }
IGBenchScenario >> hookFactory: aBlock [

	hookFactory := aBlock
]

{ #category : 'accessing' }
IGBenchScenario >> name [

	^ name
]

{ #category : 'accessing' }
IGBenchScenario >> name: aString [

	name := aString
]
