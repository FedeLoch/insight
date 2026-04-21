"
Statement level code coverage profiler that can instrument methods and classes, execute a block of code, and produce a structured coverage report.
"
Class {
	#name : 'IGCodeCoverageProfiler',
	#superclass : 'Object',
	#instVars : [
		'methods',
		'coverageResult',
		'statementCounter'
	],
	#category : 'IG-CodeCov-IG-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverage'
}

{ #category : 'private' }
IGCodeCoverageProfiler >> buildResultFor: aCollectionOfMethods [
	"Populate an IGCoverageResult from the profiling"

	| result |

	result := IGCoverageResult new.
	aCollectionOfMethods do: [ :eachMethod |
		result addMethodCoverage: (self methodCoverageFor: eachMethod) ].
	coverageResult := result
]

{ #category : 'api' }
IGCodeCoverageProfiler >> classesToInstrument: aCollection [
	" Sugar for getting and instrumenting the methods from the classes."

	| flattenClasses |

	flattenClasses := self flattenClassesFrom: aCollection.
	self methodsToInstrument: (flattenClasses flatCollect: #definedMethods)
]

{ #category : 'accessing' }
IGCodeCoverageProfiler >> coverageResult [

	^coverageResult
]

{ #category : 'private' }
IGCodeCoverageProfiler >> flattenClassesFrom: aCollection [

	| flattenedCollection |

	flattenedCollection := OrderedCollection new.

	aCollection do: [ :each |
			each isClass ifTrue: [ flattenedCollection add: each ]
				ifFalse: [
						flattenedCollection
							addAll: (self flattenClassesFrom: each)
						]
			].
	^flattenedCollection
]

{ #category : 'initialization' }
IGCodeCoverageProfiler >> initialize [

	super initialize.
	methods := OrderedCollection new.
	coverageResult := IGCoverageResult new.
]

{ #category : 'private' }
IGCodeCoverageProfiler >> methodCoverageFor: aMethod [
	"Build a IGMethodCoverage struct from the counter values"

	| executedStatements |

	executedStatements := IdentityDictionary new.
	aMethod ast statements do: [ :eachNode |
			executedStatements at: eachNode
				put: (statementCounter countAt: eachNode)
			].
	^IGMethodCoverage method: aMethod executedStatements: executedStatements 
]

{ #category : 'private - accessing' }
IGCodeCoverageProfiler >> methods [

	^methods
]

{ #category : 'api' }
IGCodeCoverageProfiler >> methodsToInstrument: aCollection [
	"Register every method found in the collection for profiling.
	The collection may be nested"

	aCollection do: [ :each|
		each isCompiledMethod
			ifTrue: [ methods add: each ]
			ifFalse: [ self methodsToInstrument: each ] ]
]

{ #category : 'api' }
IGCodeCoverageProfiler >> profileOn: aBlock [

	| instrumentation statementHook uniqueMethods |

	statementCounter := IGCounter new countKeyBy: #astNode.
	statementHook := IGAfterStatementHook new do: statementCounter.

	instrumentation := IGInstrumentation new addHook: statementHook.

	uniqueMethods := methods asSet asArray.
	instrumentation instrumentMethods: uniqueMethods
		during: aBlock.

	self buildResultFor: uniqueMethods
]
