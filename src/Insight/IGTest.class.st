Class {
	#name : 'IGTest',
	#superclass : 'TestCase',
	#category : 'Insight-Tests',
	#package : 'Insight',
	#tag : 'Tests'
}

{ #category : 'tests' }
IGTest >> conditionalMethod: aBoolean [

	| t |
	
	aBoolean ifTrue: [ t := 1 ] ifFalse: [ t := 2 ].
	
	^ t
]

{ #category : 'tests' }
IGTest >> incrementingTvariable [

	| t |
	
	t := 0.

	t := t + 1
]

{ #category : 'tests' }
IGTest >> returnMethod [

	^ 42
]

{ #category : 'tests' }
IGTest >> sequencialMethod [

	1 + 2.
	
	3 + 4.
	
	self yourself
]

{ #category : 'tests' }
IGTest >> testCollectArbitraryValueWithAnAfterStatementHook [
	
	| instrumentation afterHook collector result methodToInstrument |
	
	collector := IGCollector collect: [ :instrumentationContext | instrumentationContext receiver ].
	afterHook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #sequencialMethod.
	
	result := instrumentation instrument: methodToInstrument during: [ self sequencialMethod ].
	
	self assert: (collector includes: self)
]

{ #category : 'tests' }
IGTest >> testCollectArbitraryValueWithAnBeforeAndAfterStatementHook [
	
	| instrumentation beforeHook afterHook beforeCollector afterCollector result methodToInstrument |
	
	beforeCollector := IGCollector collect: [ :instrumentationContext | instrumentationContext variableNamed: 't' ].
	afterCollector := IGCollector collect: [ :instrumentationContext | instrumentationContext variableNamed: 't' ].
	
	beforeHook := IGBeforeStatementHook new do: beforeCollector.
	afterHook := IGAfterStatementHook new do: afterCollector.
	instrumentation := IGInstrumentation new addHook: afterHook; addHook: beforeHook.
	methodToInstrument := IGTest >> #incrementingTvariable.

	result := instrumentation instrument: methodToInstrument during: [ self incrementingTvariable ].
	
	self assert: beforeCollector collection asArray equals: { nil . 0 }.
	self assert: afterCollector collection asArray equals: { 0 . 1 }
]

{ #category : 'tests' }
IGTest >> testCounterPerStatement [
	
	| instrumentation afterHook counter result methodToInstrument |
	
	counter := IGCounter new countKeyBy: [ :context | context astNode ].
	afterHook := IGAfterStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #incrementingTvariable.
	
	methodToInstrument ast statements do: [ :node |
		self assert: (counter countAt: node) equals: 0		
	].

	result := instrumentation instrument: methodToInstrument during: [ self incrementingTvariable ].
	
	methodToInstrument ast statements do: [ :node |
		self assert: (counter countAt: node) equals: 1		
	].
]

{ #category : 'tests' }
IGTest >> testCounterWithAnAfterStatementHook [
	
	| instrumentation afterHook counter result methodToInstrument |
	
	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #incrementingTvariable.

	self assert: counter count equals: 0.

	result := instrumentation instrument: methodToInstrument during: [ self incrementingTvariable ].
	
	self assert: counter count equals: 2.
]

{ #category : 'tests' }
IGTest >> testCoverageInstrumentAConditionalWithAnAfterHook [
	
	| instrumentation afterHook collector methodToInstrument ifStatement trueStatement falseStatement |
	
	collector := IGCounter new countKeyBy: [ :context | context astNode ].
	afterHook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #conditionalMethod:.
	
	instrumentation instrument: methodToInstrument during: [
		self conditionalMethod: true.
		self conditionalMethod: false
	].

	ifStatement := methodToInstrument ast statements first.
	trueStatement := ifStatement arguments first statements first.
	falseStatement := ifStatement arguments second statements first.
	
	self assert: (collector countAt: ifStatement) equals: 2.
	self assert: (collector countAt: trueStatement) equals: 1.
	self assert: (collector countAt: falseStatement) equals: 1.
]

{ #category : 'tests' }
IGTest >> testCoverageInstrumentAStatementWithAnAfterHook [
	
	| instrumentation afterHook collector result methodToInstrument |
	
	collector := IGCollector new.
	afterHook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #sequencialMethod.
	
	result := instrumentation instrument: methodToInstrument during: [ self sequencialMethod ].
	
	methodToInstrument ast statements do: [ :statement |
		self assert: (collector includes: statement)
	]
]

{ #category : 'tests' }
IGTest >> testInstrumentAfterReturn [
	
	| instrumentation afterHook counter methodToInstrument |
	
	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #returnMethod.
	
	instrumentation instrument: methodToInstrument during: [ self returnMethod ].
	
	self assert: counter count equals: 1
]
