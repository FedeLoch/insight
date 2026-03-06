Class {
	#name : 'IGTest',
	#superclass : 'TestCase',
	#category : 'Insight-Tests',
	#package : 'Insight',
	#tag : 'Tests'
}

{ #category : 'tests' }
IGTest >> incrementingTvariable [

	| t |
	
	t := 0.
	t := t + 1
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
