"
Synthetic workloads that the benchmark instruments. Each method here is
designed to exercise a specific cost dimension: AST size, control flow,
assignment density, message-send rate, recursion depth.

Outer-loop iteration counts live in IGBenchRunner>>workloadSpecs, not here,
so these methods stay shape-pure.
"
Class {
	#name : 'IGBenchMock',
	#superclass : 'Object',
	#category : 'IG-Benchmarks-Workloads',
	#package : 'IG-Benchmarks',
	#tag : 'Workloads'
}

{ #category : 'workloads - sends' }
IGBenchMock >> assignmentChain [
	"Worst case for the AST flattening pass: nested assignment node.
	 generateInstrumentedAST has to flatten this into a sequence of single
	 assignments."

	| a b c d |
	a := b := c := d := 42.
	^ a + b + c + d
]

{ #category : 'workloads - straight-line' }
IGBenchMock >> heavyMethod [
	"50 statements - all uniform shape so AST size scales linearly."

	| x |
	x := 0.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	x := x + 1. x := x + 1. x := x + 1. x := x + 1. x := x + 1.
	^ x
]

{ #category : 'workloads - straight-line' }
IGBenchMock >> lightMethod [
	"5 statements."

	| a b c d e |
	a := 1.
	b := a + 1.
	c := b * 2.
	d := c - 1.
	e := d / 2.
	^ e
]

{ #category : 'workloads - straight-line' }
IGBenchMock >> mediumMethod [
	"20 statements."

	| a b c d e f g h i j k l m n o p q r s t |
	a := 1. b := 2. c := 3. d := 4. e := 5.
	f := a + b. g := c + d. h := e + f. i := g + h.
	j := i * 2. k := j - 1. l := k + 3. m := l * 2.
	n := m - 5. o := n + 1. p := o * 3. q := p - 2.
	r := q + 4. s := r * 2. t := s + 1.
	^ t
]

{ #category : 'workloads - sends' }
IGBenchMock >> messageSendHeavy: n [
	"Drives a chain of self-sends. The instrumented method is the OUTER one;
	 subSend: stays uninstrumented (intentional - isolates per-send overhead
	 in the instrumented frame)."

	| sum i |
	sum := 0.
	i := 0.
	[ i < n ] whileTrue: [
		sum := sum + (self subSend: i).
		i := i + 1 ].
	^ sum
]

{ #category : 'workloads - control flow' }
IGBenchMock >> recursiveFactorial: n [
	"Recursion. The recursive call hits the instrumented self-method, so
	 hook firings accumulate down the stack."

	n < 2 ifTrue: [ ^ 1 ].
	^ n * (self recursiveFactorial: n - 1)
]

{ #category : 'workloads - sends' }
IGBenchMock >> subSend: i [
	"Helper for messageSendHeavy:. Intentionally not instrumented in any
	 scenario."

	^ i + 1
]

{ #category : 'workloads - control flow' }
IGBenchMock >> tightLoop: n [
	"While loop with a 1-statement body. Stresses the per-statement hook
	 firing rate."

	| i |
	i := 0.
	[ i < n ] whileTrue: [ i := i + 1 ].
	^ i
]

{ #category : 'workloads - control flow' }
IGBenchMock >> tightLoopHeavy: n [
	"While loop with a 16-statement body."

	| i x |
	i := 0.
	x := 0.
	[ i < n ] whileTrue: [
		x := x + 1. x := x * 2. x := x - 1. x := x + 3.
		x := x * 1. x := x + 2. x := x - 4. x := x + 5.
		x := x + 1. x := x * 2. x := x - 1. x := x + 3.
		x := x * 1. x := x + 2. x := x - 4. x := x + 5.
		i := i + 1 ].
	^ x
]

{ #category : 'workloads - straight-line' }
IGBenchMock >> tinyMethod [
	"1 statement - smallest measurable unit."

	^ 42
]
