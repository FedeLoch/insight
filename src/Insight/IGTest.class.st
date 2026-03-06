Class {
	#name : 'IGTest',
	#superclass : 'TestCase',
	#category : 'Insight-Tests',
	#package : 'Insight',
	#tag : 'Tests'
}

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
