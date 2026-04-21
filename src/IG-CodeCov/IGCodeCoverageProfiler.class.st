"
Statement level code coverage profiler that can instrument methods and clasess, execute a block of code, and produce a structured coverage report.
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

{ #category : 'api' }
IGCodeCoverageProfiler >> methodsToInstrument: aCollection [
	"Register every method found in the collection for profiling.
	The collection may be nested"

	aCollection do: [ :each|
		each isCompiledMethod
			ifTrue: [ methods add: each ]
			ifFalse: [ self methodsToInstrument: each ] ]
]
