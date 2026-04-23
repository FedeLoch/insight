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
	#category : 'IG-CodeCov-IG-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverage'
}

{ #category : 'private' }
IGCodeCoverageProfiler >> buildMethodCoverageRecordFor: aMethod [
	"Build a IGMethodCoverageRecord struct from the counter values"

	^IGMethodCoverageRecord for: aMethod executedStatements: (self getExectutedStatementsFor: aMethod)
]

{ #category : 'private' }
IGCodeCoverageProfiler >> buildResultFor: aCollectionOfMethods [
	"Populate an IGCoverageResult from the profiling"

	| result |

	result := IGCoverageResult new.
	aCollectionOfMethods do: [ :eachMethod |
		result addRecord: (self buildMethodCoverageRecordFor: eachMethod) ].
	^ result
]

{ #category : 'api' }
IGCodeCoverageProfiler >> classesToInstrument: aCollectionOfClasses [
	" Sugar for getting and instrumenting the methods from the classes."

	self methodsToInstrument: (aCollectionOfClasses flattened collect: #definedMethods)
]

{ #category : 'accessing' }
IGCodeCoverageProfiler >> coverageResult [

	^coverageResult
]

{ #category : 'private' }
IGCodeCoverageProfiler >> getExectutedStatementsFor: aMethod [
    "Get the counter values for each statement in the method and return them as an IdentityDictionary keyed by the AST node."

    | executedStatements |

    executedStatements := IdentityDictionary new.
    aMethod ast statements do: [ :eachNode |
            executedStatements at: eachNode
                put: (statementCounter countAt: eachNode)
            ].
    ^ executedStatements
]

{ #category : 'initialization' }
IGCodeCoverageProfiler >> initialize [

	super initialize.
	methods := OrderedCollection new.
    "In case the result is requested before any profiling has been done"
	coverageResult := IGCoverageResult new.
]

{ #category : 'private - accessing' }
IGCodeCoverageProfiler >> instrumentedMethods [

	^instrumentedMethods
]

{ #category : 'api' }
IGCodeCoverageProfiler >> methodsToInstrument: aCollectionOfMethods [
	"Register every method found in the collection for profiling.
	The collection may be nested"

    aCollectionOfMethods flattened do: [ :eachMethod |
        instrumentedMethods add: eachMethod.
    ].
]

{ #category : 'api' }
IGCodeCoverageProfiler >> profileOn: aBlock [

	| instrumentation statementHook uniqueMethods |

	statementCounter := IGCounter new countKeyBy: #astNode.
	statementHook := IGAfterStatementHook new do: statementCounter.

	instrumentation := IGInstrumentation new addHook: statementHook.

	uniqueMethods := instrumentedMethods asSet asArray.
	instrumentation instrumentMethods: uniqueMethods
		during: aBlock.

	coverageResult := self buildResultFor: uniqueMethods
]
