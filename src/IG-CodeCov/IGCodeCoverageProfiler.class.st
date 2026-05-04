"
Statement level code coverage profiler that can instrument methods and classes, execute a block of code, and produce a structured coverage report.
"
Class {
	#name : 'IGCodeCoverageProfiler',
	#superclass : 'Object',
	#instVars : [
		'instrumentedMethods',
		'coverageResult',
		'statementCounter'
	],
	#category : 'IG-CodeCov-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'CodeCoverage'
}

{ #category : 'private' }
IGCodeCoverageProfiler >> buildRecordFor: aMethod [
	"Build a IGMethodCoverageRecord struct from the counter values"

	^ IGMethodCoverageRecord for: aMethod
		  statementCounters: (self getCountersFor: aMethod)
]

{ #category : 'private' }
IGCodeCoverageProfiler >> buildResultFor: aCollectionOfMethods [
	"Populate an IGCoverageResult from the profiling"

	| result |

	result := IGCoverageResult new.
	aCollectionOfMethods do: [ :eachMethod |
		result addRecord: (self buildRecordFor: eachMethod) ].
	^ result
]

{ #category : 'api' }
IGCodeCoverageProfiler >> classesToInstrument: aCollectionOfClasses [
	" Sugar for getting and instrumenting the methods from the classes."

	self methodsToInstrument:
		(aCollectionOfClasses flatCollect: #definedMethods)
]

{ #category : 'accessing' }
IGCodeCoverageProfiler >> coverageResult [

	^ coverageResult
]

{ #category : 'private' }
IGCodeCoverageProfiler >> getCountersFor: aMethod [
	"Get the counter values for each statement in the method and return them as an OrderedIdentityDictionary keyed by the AST node."

	| counters |

	counters := OrderedIdentityDictionary new.
	"Reject temporaries, as they are not statements and thus not relevant for coverage."
	aMethod ast allStatementsWithoutTemporaries do: [ :eachNode |
			counters at: eachNode
				put: (statementCounter countAt: eachNode)
			].
	^ counters
]

{ #category : 'initialization' }
IGCodeCoverageProfiler >> initialize [

	super initialize.
	instrumentedMethods := Set new.
	"In case the result is requested before any profiling has been done"
	coverageResult := IGCoverageResult new
]

{ #category : 'private - accessing' }
IGCodeCoverageProfiler >> instrumentedMethods [

	^ instrumentedMethods
]

{ #category : 'api' }
IGCodeCoverageProfiler >> methodsToInstrument: aCollectionOfMethods [
	"Register every method found in the collection for profiling."

	instrumentedMethods addAll: aCollectionOfMethods
]

{ #category : 'api' }
IGCodeCoverageProfiler >> profileOn: aBlock [

	| instrumentation statementHook |

	statementCounter := IGCounter new countKeyBy: #astNode.
	statementHook := IGAfterStatementHook new do: statementCounter.

	instrumentation := IGInstrumentation new addHook: statementHook.

	instrumentation instrumentMethods: instrumentedMethods
		during: aBlock.

	coverageResult := self buildResultFor: instrumentedMethods
]
