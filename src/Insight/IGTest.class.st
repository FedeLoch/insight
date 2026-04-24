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

	aBoolean ifTrue: [ t := 1 ]
		ifFalse: [ t := 2 ].

	^t
]

{ #category : 'helper methods' }
IGTest >> emptyMethod [
]

{ #category : 'helper methods' }
IGTest >> incrementingTvariable [

	| t |

	t := 0.

	t := t + 1
]

{ #category : 'method tests' }
IGTest >> instrumenting: targetToInstrument with: hooks running: programBlock assert: assertBlock [

	| instrumentation |

	instrumentation := IGInstrumentation new addHooks: hooks.

	instrumentation instrumentMethod: targetToInstrument during: programBlock.

	assertBlock value: targetToInstrument
]

{ #category : 'method tests' }
IGTest >> instrumentingClass: aClass with: hooks running: programBlock assert: assertBlock [

	| instrumentation |

	instrumentation := IGInstrumentation new addHooks: hooks.

	instrumentation instrumentClass: aClass during: programBlock.

	assertBlock value: aClass
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

{ #category : 'helper methods' }
IGTest >> slowFactorial: n [

	n < 2 ifTrue: [ ^1 ].
	^n * (self slowFactorial: n - 1)
]

{ #category : 'method tests' }
IGTest >> testCollectArbitraryValueWithAnAfterStatementHook [

	| afterHook collector methodToInstrument |

	collector := IGCollector collect: [ :instrumentationContext | instrumentationContext receiver ].
	afterHook := IGAfterStatementHook new do: collector.
	methodToInstrument := IGTest >> #sequencialMethod.

	self instrumenting: methodToInstrument with: { afterHook } running: [ self sequencialMethod ] assert: [ :method |
		self assert: (collector includes: self)
	]
]

{ #category : 'method tests' }
IGTest >> testCollectArbitraryValueWithAnBeforeAndAfterStatementHook [

	| beforeHook afterHook beforeCollector afterCollector methodToInstrument |

	beforeCollector := IGCollector collect: [ :instrumentationContext | instrumentationContext variableNamed: 't' ].
	afterCollector := IGCollector collect: [ :instrumentationContext | instrumentationContext variableNamed: 't' ].

	beforeHook := IGBeforeStatementHook new do: beforeCollector.
	afterHook := IGAfterStatementHook new do: afterCollector.
	methodToInstrument := IGTest >> #incrementingTvariable.

	self instrumenting: methodToInstrument with: { afterHook . beforeHook } running: [ self incrementingTvariable ] assert: [ :method |
		self assert: beforeCollector collection asArray equals: { nil . 0 }.
		self assert: afterCollector collection asArray equals: { 0 . 1 }
	]
]

{ #category : 'method tests' }
IGTest >> testCollectArbitraryValueWithAnBeforeStatementHook [

	| instrumentation beforeHook collector methodToInstrument |

	collector := IGCollector collect: [ :ctx | ctx variableNamed: 't' ].
	beforeHook := IGBeforeStatementHook new do: collector.

	instrumentation := IGInstrumentation new addHook: beforeHook.
	methodToInstrument := IGTest >> #conditionalMethod:.

	instrumentation instrumentMethod: methodToInstrument
		during: [ self conditionalMethod: false ].

	self assertCollection: collector collection asArray
		equals: { nil. nil. 2 }
]

{ #category : 'method tests' }
IGTest >> testCollectStatementResultsWithAnAfterStatementHook [

	| afterHook collector methodToInstrument |

	collector := IGCollector collect: [ :instrumentationContext | instrumentationContext statementResult ].
	afterHook := IGAfterStatementHook new do: collector.
	methodToInstrument := IGTest >> #sequencialMethod.

	self instrumenting: methodToInstrument with: { afterHook } running: [ self sequencialMethod ] assert: [ :method |
		self assertCollection: collector collection asArray equals: { 3 . 7 . self }
	]
]

{ #category : 'class tests' }
IGTest >> testCountAllAssignmentsCallingOnlyOneAssignmentInAClass [

	| afterHook counter |

	counter := IGCounter new.
	afterHook := IGAfterAssignmentHook new do: counter.

	self instrumentingClass: IGMock with: { afterHook } running: [ | instance |
		instance := IGMock basicNew.
		instance variable2: 'hola'.
	] assert: [ :class | self assert: (counter count) equals: 1 ]
]

{ #category : 'class tests' }
IGTest >> testCountAllAssignmentsInAClass [

	| afterHook counter |

	counter := IGCounter new.
	afterHook := IGAfterAssignmentHook new do: counter.

	self instrumentingClass: IGMock with: { afterHook } running: [ | instance |
		instance := IGMock new.
		instance variable1: 42.
		instance variable2: 'hola'.
	] assert: [ :class | self assert: (counter count) equals: 5 ]
]

{ #category : 'class tests' }
IGTest >> testCountAllStatementExecutionsInAClass [

	| afterHook counter |

	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.

	self instrumentingClass: IGMock with: { afterHook } running: [ | instance |
		instance := IGMock new.
		instance variable1: 42.
		instance variable2: 'hola'.
	] assert: [ :class | self assert: (counter count) equals: 5 ]
]

{ #category : 'method tests' }
IGTest >> testCountStatementsAndVariableValueWith2AfterHooks [

	| afterCounterHook counter afterCollectorHook collector methodToInstrument |

	counter := IGCounter new.
	afterCounterHook := IGAfterStatementHook new do: counter.

	collector := IGCollector collect: [ :ctx | ctx variableNamed: 't' ].
	afterCollectorHook := IGAfterStatementHook new do: collector.
	methodToInstrument := IGTest >> #conditionalMethod:.

	self instrumenting: methodToInstrument with: { afterCounterHook . afterCollectorHook } running: [ self conditionalMethod: true ] assert: [ :method |
		self assert: counter count equals: 3.
		self assertCollection: collector collection asArray equals: { 1 . 1 . 1 }
	]
]

{ #category : 'method tests' }
IGTest >> testCounterPerStatement [

	| afterHook counter methodToInstrument |

	counter := IGCounter new countKeyBy: [ :context | context astNode ].
	afterHook := IGAfterStatementHook new do: counter.
	methodToInstrument := IGTest >> #incrementingTvariable.

	methodToInstrument ast statements do: [ :node | self assert: (counter countAt: node) equals: 0 ].

	self instrumenting: methodToInstrument with: { afterHook } running: [ self incrementingTvariable ] assert: [ :method |
		methodToInstrument ast statements do: [ :node | self assert: (counter countAt: node) equals: 1 ]
	]
]

{ #category : 'method tests' }
IGTest >> testCounterWithAnAfterStatementHook [

	| afterHook counter methodToInstrument |

	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	methodToInstrument := IGTest >> #incrementingTvariable.

	self assert: counter count equals: 0.

	self instrumenting: methodToInstrument with: { afterHook } running: [ self incrementingTvariable ] assert: [ :method |
		self assert: counter count equals: 2.
	]
]

{ #category : 'method tests' }
IGTest >> testCoverageInstrumentAConditionalWithAnAfterHook [

	| afterHook collector methodToInstrument  |

	collector := IGCounter new countKeyBy: [ :context | context astNode ].
	afterHook := IGAfterStatementHook new do: collector.
	methodToInstrument := IGTest >> #conditionalMethod:.

	self instrumenting: methodToInstrument with: { afterHook } running: [ self conditionalMethod: true . self conditionalMethod: false ] assert:
		[ :method | | ifStatement trueStatement falseStatement |

			ifStatement := methodToInstrument ast statements first.
			trueStatement := ifStatement arguments first statements first.
			falseStatement := ifStatement arguments second statements first.

			self assert: (collector countAt: ifStatement) equals: 2.
			self assert: (collector countAt: trueStatement) equals: 1.
			self assert: (collector countAt: falseStatement) equals: 1.
	]
]

{ #category : 'method tests' }
IGTest >> testCoverageInstrumentAStatementWithAnAfterHook [

	| afterHook collector methodToInstrument |

	collector := IGCollector new.
	afterHook := IGAfterStatementHook new do: collector.
	methodToInstrument := IGTest >> #sequencialMethod.

	self instrumenting: methodToInstrument with: { afterHook } running: [ self sequencialMethod ] assert: [ :method |
		method ast statements do: [ :statement | self assert: (collector includes: statement) ]
	]
]

{ #category : 'method tests' }
IGTest >> testEmptyMethod [

	| afterHook counter methodToInstrument |

	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	methodToInstrument := IGTest >> #emptyMethod.

	self instrumenting: methodToInstrument with: { afterHook } running: [ self emptyMethod ] assert: [ :method |
		self assert: counter count equals: 0
	]
]

{ #category : 'method tests' }
IGTest >> testInstrumentAfterReturn [

	| afterHook counter methodToInstrument |

	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	methodToInstrument := IGTest >> #returnMethod.

	self instrumenting: methodToInstrument with: { afterHook } running: [ self returnMethod ] assert: [ :method |
		self assert: counter count equals: 1
	]
]

{ #category : 'method tests' }
IGTest >> testInstrumentBeforeReturn [

	| beforeHook counter methodToInstrument |

	counter := IGCounter new.
	beforeHook := IGBeforeStatementHook new do: counter.
	methodToInstrument := IGTest >> #returnMethod.

	self instrumenting: methodToInstrument with: { beforeHook } running: [ self returnMethod ] assert: [ :method |
		self assert: counter count equals: 1
	]
]

{ #category : 'methods tests' }
IGTest >> testMethodIsCorrectlyUninstrumented [

	| counter afterHook methodToInstrument uninstrumentedMethod |

	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	methodToInstrument := IGTest >> #incrementingTvariable.


	IGInstrumentation new
		addHook: afterHook; instrumentMethod: methodToInstrument; uninstrumentMethod: methodToInstrument.

	uninstrumentedMethod := IGTest >> #incrementingTvariable.

	self assertCollection: methodToInstrument bytecodes equals: uninstrumentedMethod bytecodes.
]

{ #category : 'methods tests' }
IGTest >> testMethodIsInstrumented [

	| counter afterHook uninstrumentedMethod instrumentedMethod instrumentation |

	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	uninstrumentedMethod := IGTest >> #incrementingTvariable.

	instrumentation := IGInstrumentation new.
	instrumentation addHook: afterHook; instrumentMethod: uninstrumentedMethod.
	self incrementingTvariable .
	instrumentedMethod := IGTest >> #incrementingTvariable.
	instrumentation uninstrumentMethod: uninstrumentedMethod .

	self denyCollection: uninstrumentedMethod bytecodes equals: instrumentedMethod bytecodes.
]

{ #category : 'method tests' }
IGTest >> testRecursiveMethodAccumulatesCount [

	| counter afterHook methodToInstrument result |

	counter := IGCounter new.
	afterHook := IGAfterStatementHook new do: counter.
	methodToInstrument := IGTest >> #slowFactorial:.

	self instrumenting: methodToInstrument with: { afterHook } running: [ result := self slowFactorial: 3 ] assert: [ :method |
		self assert: result equals: 6.
		self assert: counter count equals: 5
		 ]
]
