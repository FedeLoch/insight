Class {
	#name : 'IGTest',
	#superclass : 'TestCase',
	#category : 'Insight-Tests',
	#package : 'Insight',
	#tag : 'Tests'
}

{ #category : 'helper methods' }
IGTest >> conditionalMethod: aBoolean [

	| t |
	
	aBoolean ifTrue: [ t := 1 ] ifFalse: [ t := 2 ].
	
	^ t
]

{ #category : 'helper methods' }
IGTest >> incrementingTvariable [

	| t |
	
	t := 0.

	t := t + 1
]

{ #category : 'helper methods' }
IGTest >> nonLocalReturnMethod: aBoolean [

	aBoolean ifTrue: [ ^42 ].
	
	^84
]

{ #category : 'helper methods' }
IGTest >> returnMethod [

	^ 42
]

{ #category : 'helper methods' }
IGTest >> sequencialMethod [

	1 + 2.
	
	3 + 4.
	
	self yourself
]

{ #category : 'method tests' }
IGTest >> testCollectArbitraryValueWithAnAfterStatementHook [
	
	| instrumentation afterHook collector result methodToInstrument |
	
	collector := IGCollector collect: [ :instrumentationContext | instrumentationContext receiver ].
	afterHook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #sequencialMethod.
	
	result := instrumentation instrumentMethod: methodToInstrument during: [ self sequencialMethod ].
	
	self assert: (collector includes: self)
]

{ #category : 'method tests' }
IGTest >> testCollectArbitraryValueWithAnBeforeAndAfterStatementHook [
	
	| instrumentation beforeHook afterHook beforeCollector afterCollector result methodToInstrument |
	
	beforeCollector := IGCollector collect: [ :instrumentationContext | instrumentationContext variableNamed: 't' ].
	afterCollector := IGCollector collect: [ :instrumentationContext | instrumentationContext variableNamed: 't' ].
	
	beforeHook := IGBeforeStatementHook new do: beforeCollector.
	afterHook := IGAfterStatementHook new do: afterCollector.
	instrumentation := IGInstrumentation new addHook: afterHook; addHook: beforeHook.
	methodToInstrument := IGTest >> #incrementingTvariable.

	result := instrumentation instrumentMethod: methodToInstrument during: [ self incrementingTvariable ].
	
	self assert: beforeCollector collection asArray equals: { nil . 0 }.
	self assert: afterCollector collection asArray equals: { 0 . 1 }
]

{ #category : 'method tests' }
IGTest >> testCollectStatementResultsWithAnAfterStatementHook [
	
	| instrumentation afterHook collector methodToInstrument |
	
	collector := IGCollector collect: [ :instrumentationContext | instrumentationContext statementResult ].
	afterHook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #sequencialMethod.
	
	instrumentation instrumentMethod: methodToInstrument during: [ self sequencialMethod ].
	
	self assertCollection: collector collection asArray equals: { 3 . 7 . self }
]

{ #category : 'class tests' }
IGTest >> testCountAllAssignmentsCallingOnlyOneAssignmentInAClass [

	| instrumentation afterHook counter |
	
	counter := IGCounter new.
	afterHook := IGAfterAssignmentHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	
	instrumentation instrumentClass: IGMock during: [ | instance |
		instance := IGMock basicNew.
		instance variable2: 'hola'.
	].
	
	self assert: (counter count) equals: 1
]

{ #category : 'class tests' }
IGTest >> testCountAllAssignmentsInAClass [

	| instrumentation afterHook counter |
	
	counter := IGCounter new.
	afterHook := IGAfterAssignmentHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	
	instrumentation instrumentClass: IGMock during: [ | instance |
		instance := IGMock new.
		instance variable1: 42.
		instance variable2: 'hola'.
	].
	
	self assert: (counter count) equals: 5
]

{ #category : 'class tests' }
IGTest >> testCountAllStatementExecutionsInAClass [
	
	| instrumentation afterHook counter |
	
	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	
	instrumentation instrumentClass: IGMock during: [ | instance |
		instance := IGMock new.
		instance variable1: 42.
		instance variable2: 'hola'.
	].
	
	self assert: (counter count) equals: 5
]

{ #category : 'method tests' }
IGTest >> testCounterPerStatement [
	
	| instrumentation afterHook counter result methodToInstrument |
	
	counter := IGCounter new countKeyBy: [ :context | context astNode ].
	afterHook := IGAfterStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #incrementingTvariable.
	
	methodToInstrument ast statements do: [ :node |
		self assert: (counter countAt: node) equals: 0		
	].

	result := instrumentation instrumentMethod: methodToInstrument during: [ self incrementingTvariable ].
	
	methodToInstrument ast statements do: [ :node |
		self assert: (counter countAt: node) equals: 1		
	].
]

{ #category : 'method tests' }
IGTest >> testCounterWithAnAfterStatementHook [
	
	| instrumentation afterHook counter result methodToInstrument |
	
	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #incrementingTvariable.

	self assert: counter count equals: 0.

	result := instrumentation instrumentMethod: methodToInstrument during: [ self incrementingTvariable ].
	
	self assert: counter count equals: 2.
]

{ #category : 'method tests' }
IGTest >> testCoverageInstrumentAConditionalWithAnAfterHook [
	
	| instrumentation afterHook collector methodToInstrument ifStatement trueStatement falseStatement |
	
	collector := IGCounter new countKeyBy: [ :context | context astNode ].
	afterHook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #conditionalMethod:.
	
	instrumentation instrumentMethod: methodToInstrument during: [
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

{ #category : 'method tests' }
IGTest >> testCoverageInstrumentAStatementWithAnAfterHook [
	
	| instrumentation afterHook collector result methodToInstrument |
	
	collector := IGCollector new.
	afterHook := IGAfterStatementHook new do: collector.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #sequencialMethod.
	
	result := instrumentation instrumentMethod: methodToInstrument during: [ self sequencialMethod ].
	
	methodToInstrument ast statements do: [ :statement |
		self assert: (collector includes: statement)
	]
]

{ #category : 'method tests' }
IGTest >> testDetectException [

	| instrumentation beforeCounter beforeHook afterCounter afterHook methodToInstrument |

	beforeCounter := IGCounter new.
	beforeHook := IGBeforeStatementHook new do: beforeCounter.

	afterCounter := IGCounter new.
	afterHook := IGAfterStatementHook new do: afterCounter.

	instrumentation := IGInstrumentation new addHook: beforeHook; addHook: afterHook.
	methodToInstrument := IGTest >> #exceptionMethod.

	[ instrumentation instrumentMethod: methodToInstrument during: [
		self exceptionMethod
	]] on: Error do: []. 

	self assert: beforeCounter count equals: 1.
	self assert: afterCounter count equals: 0.

]

{ #category : 'method tests' }
IGTest >> testDetectException [

	| instrumentation beforeCounter beforeHook afterCounter afterHook methodToInstrument |

	beforeCounter := IGCounter new.
	beforeHook := IGBeforeStatementHook new do: beforeCounter.

	afterCounter := IGCounter new.
	afterHook := IGAfterStatementHook new do: afterCounter.

	instrumentation := IGInstrumentation new addHook: beforeHook; addHook: afterHook.
	methodToInstrument := IGTest >> #exceptionMethod.

	[ instrumentation instrumentMethod: methodToInstrument during: [
		self exceptionMethod
	]] on: Error do: []. 

	self assert: beforeCounter count equals: 1.
	self assert: afterCounter count equals: 0.

]

{ #category : 'method tests' }
IGTest >> testInstrumentAfterReturn [
	
	| instrumentation afterHook counter methodToInstrument |
	
	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: afterHook.
	methodToInstrument := IGTest >> #returnMethod.
	
	instrumentation instrumentMethod: methodToInstrument during: [ self returnMethod ].
	
	self assert: counter count equals: 1
]

{ #category : 'method tests' }
IGTest >> testInstrumentBeforeReturn [
	
	| instrumentation beforeHook counter methodToInstrument |
	
	counter := IGCounter new.
	beforeHook := IGBeforeStatementHook new do: counter.
	instrumentation := IGInstrumentation new addHook: beforeHook.
	methodToInstrument := IGTest >> #returnMethod.
	
	instrumentation instrumentMethod: methodToInstrument during: [ self returnMethod ].
	
	self assert: counter count equals: 1
]
