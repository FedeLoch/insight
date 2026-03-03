Class {
	#name : 'IGTest',
	#superclass : 'TestCase',
	#category : 'Insight',
	#package : 'Insight'
}

{ #category : 'tests' }
IGTest >> sequencialMethod [

	1 + 2.
	
	3 + 4.
	
	self yourself 
]

{ #category : 'tests' }
IGTest >> testCoverageInstrumentAStatement [
	
	| instrumentation hook collector result methodToInstrument |
	
	collector := IGCollector new.
	hook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: hook.
	methodToInstrument := IGTest >> #sequencialMethod.
	
	result := instrumentation instrument: methodToInstrument during: [ self sequencialMethod ].
	
	methodToInstrument ast statements do: [ :statement |
		self assert: (collector includes: statement)
	]
]
