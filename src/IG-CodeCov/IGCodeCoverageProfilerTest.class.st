Class {
	#name : 'IGCodeCoverageProfilerTest',
	#superclass : 'TestCase',
	#category : 'IG-CodeCov-IG-CodeCoverageTest',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverageTest'
}

{ #category : 'helper' }
IGCodeCoverageProfilerTest >> assertRecord: aMethodRecord equals: expected [

	self assertCollection: aMethodRecord executedStatements asArray
		equals: expected
]

{ #category : 'helper' }
IGCodeCoverageProfilerTest >> profileClass: aClass on: aBlock [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler classesToInstrument: { aClass }.
	profiler profileOn: aBlock.

	^profiler coverageResult
]

{ #category : 'helper' }
IGCodeCoverageProfilerTest >> profileMethod: aMethod on: aBlock [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: { aMethod }.
	profiler profileOn: aBlock.

	^profiler coverageResult recordFor: aMethod
]

{ #category : 'tests - classes' }
IGCodeCoverageProfilerTest >> testClassesToInstrumentCoversAllDefinedMethods [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler classesToInstrument: { IGCoverageMock }.

	self assertCollection: profiler instrumentedMethods
		hasSameElements: IGCoverageMock definedMethods
]

{ #category : 'tests' }
IGCodeCoverageProfilerTest >> testCoverageResultBeforeProfilingIsEmpty [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	self assert: profiler coverageResult isEmpty
]

{ #category : 'tests - profiling' }
IGCodeCoverageProfilerTest >> testExecutedMethodIsCovered [

	| methodCoverage method |

	method := IGCoverageMock >> #oneStatement.
	methodCoverage := self profileMethod: method
		                  on: [ IGCoverageMock new oneStatement ].

	self assertRecord: methodCoverage
		equals: { 1 }
]

{ #category : 'tests - profiling' }
IGCodeCoverageProfilerTest >> testMethodUncoveredWhenNotExecuted [

	| methodCoverage method |

	method := IGCoverageMock >> #twoStatements.
	methodCoverage := self profileMethod: method
		                  on: [ "Nothing" ].

	self assertRecord: methodCoverage
		equals: { 0. 0 }
]

{ #category : 'tests' }
IGCodeCoverageProfilerTest >> testProfileOnWithNoInstrumentationIsNoOp [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler profileOn: [ IGCoverageMock new oneStatement ].

	self assert: profiler coverageResult isEmpty
]

{ #category : 'tests - profiling' }
IGCodeCoverageProfilerTest >> testSubMethodsAreCovered [

	| classCoverage |

	classCoverage := self profileClass: IGCoverageMock
		                 on: [ IGCoverageMock new callSubMethod ].

	self assertRecord:
		(classCoverage recordFor: IGCoverageMock >> #callSubMethod)
		equals: { 1. 1 }.
	self assertRecord:
		(classCoverage recordFor: IGCoverageMock >> #oneStatement)
		equals: { 1 }
]
