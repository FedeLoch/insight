Class {
	#name : 'IGCodeCoverageProfilerTest',
	#superclass : 'TestCase',
	#category : 'IG-CodeCov-IG-CodeCoverageTest',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverageTest'
}

{ #category : 'tests - classes' }
IGCodeCoverageProfilerTest >> testClassExecutedMethodsAreCovered [

	| profiler result |

	profiler := IGCodeCoverageProfiler new.
	profiler classesToInstrument: { IGCoverageMock }.
	profiler profileOn: [ IGCoverageMock new oneStatement ].
	result := profiler coverageResult.

	self assertCollection:
		(result methodCoverageFor: IGCoverageMock >> #oneStatement ) executedStatements asArray
		equals: { 1 }.
	self assertCollection:
		(result methodCoverageFor: IGCoverageMock >> #initialize ) executedStatements asArray
		equals: { 1 }
]

{ #category : 'tests - classes' }
IGCodeCoverageProfilerTest >> testClassNeverCalledMethodIsUncovered [

	| profiler result |

	profiler := IGCodeCoverageProfiler new.
	profiler classesToInstrument: { IGCoverageMock }.
	profiler profileOn: [ IGCoverageMock new oneStatement ].
	result := profiler coverageResult.

	self assertCollection:
		(result methodCoverageFor: IGCoverageMock >> #twoStatements ) executedStatements asArray
		equals: { 0. 0 }
]

{ #category : 'tests - classes' }
IGCodeCoverageProfilerTest >> testClassesToInstrumentAcceptsNestedCollections [

	| profiler method |

	method := IGCoverageMock >> #emptyMethod.

	profiler := IGCodeCoverageProfiler new.
	profiler classesToInstrument: { { IGCoverageMock } }.

	self assertCollection: profiler methods asArray
		includesAny: { method }
]

{ #category : 'tests - classes' }
IGCodeCoverageProfilerTest >> testClassestoInstrumentCoversAllDefinedMethod [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler classesToInstrument: { IGCoverageMock }.

	self assertCollection: profiler methods asArray
		equals: IGCoverageMock definedMethods
]

{ #category : 'tests' }
IGCodeCoverageProfilerTest >> testCoverageResultBeforeProfilingIsEmpty [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	self assert: profiler coverageResult methodCoverages isEmpty
]

{ #category : 'tests - methods' }
IGCodeCoverageProfilerTest >> testExecutedMethodIsCovered [

	| profiler result method |

	method := IGCoverageMock >> #oneStatement.

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: { method }.
	profiler profileOn: [ IGCoverageMock new oneStatement ].
	result := profiler coverageResult.

	self assertCollection:
		(result methodCoverageFor: method) executedStatements asArray
		equals: { 1 }
]

{ #category : 'tests' }
IGCodeCoverageProfilerTest >> testInstrumentationIsRestoredAfterProfiling [

	| profiler method before after |

	method := IGCoverageMock>>#emptyMethod.
	before := IGCoverageMock methodDict at: #emptyMethod.

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: { method }.
	profiler profileOn: [ IGCoverageMock new emptyMethod ].

	after := IGCoverageMock methodDict at: #emptyMethod.
	self assert: before identicalTo: after
]

{ #category : 'tests - methods' }
IGCodeCoverageProfilerTest >> testMethodUncoveredWhenNotExecuted [

	| profiler result method |

	method := IGCoverageMock >> #twoStatements.

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: { method }.
	profiler profileOn: [ "Nothing" ].
	result := profiler coverageResult.

	self assertCollection:
		(result methodCoverageFor: method) executedStatements asArray
		equals: { 0. 0 }
]

{ #category : 'tests - methods' }
IGCodeCoverageProfilerTest >> testMethodsToInstrumentAcceptsNestedCollections [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: {
			{ IGCoverageMock >> #oneStatement }.
			{ IGCoverageMock >> #twoStatements } }.

	self assertCollection: profiler methods asArray
		equals: {
				(IGCoverageMock >> #oneStatement).
				(IGCoverageMock >> #twoStatements) }
]

{ #category : 'tests - methods' }
IGCodeCoverageProfilerTest >> testMethodsToInstrumentSeveralCallsCanBeCombined [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: { IGCoverageMock >> #oneStatement }.
	profiler methodsToInstrument: { IGCoverageMock >> #twoStatements }.

	self assertCollection: profiler methods asArray
		equals: {
				(IGCoverageMock >> #oneStatement).
				(IGCoverageMock >> #twoStatements) }
]

{ #category : 'tests' }
IGCodeCoverageProfilerTest >> testProfileOnWithNoInstrumentationIsNoOp [

	| profiler executed |

	executed := false.

	profiler := IGCodeCoverageProfiler new.
	profiler profileOn: [ executed := true ].

	self assert: executed.
	self assert: profiler coverageResult methodCoverages isEmpty
]

{ #category : 'tests' }
IGCodeCoverageProfilerTest >> testRepeatedProfilingDifferentBlock [
	"profileOn: should be idempotent"

	| profiler result1 result2 method |

	method := IGCoverageMock >> #oneStatement.

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: { method }.
	profiler profileOn: [ IGCoverageMock new oneStatement ].
	result1 := profiler coverageResult.
	profiler profileOn: [ "Nothing" ].
	result2 := profiler coverageResult.

	self assertCollection:
		(result1 methodCoverageFor: method) executedStatements asArray
		equals: { 1 }.
	self assertCollection:
		(result2 methodCoverageFor: method) executedStatements asArray
		equals: { 0 }
]

{ #category : 'tests' }
IGCodeCoverageProfilerTest >> testRepeatedProfilingSameBlock [
	"profileOn: should be idempotent"

	| profiler result1 result2 method |

	method := IGCoverageMock >> #oneStatement.

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: { method }.
	profiler profileOn: [ IGCoverageMock new oneStatement ].
	result1 := profiler coverageResult.
	profiler profileOn: [ IGCoverageMock new oneStatement ].
	result2 := profiler coverageResult.

	self assertCollection: (result1 methodCoverageFor: method) executedStatements
		equals: (result2 methodCoverageFor: method) executedStatements
]
