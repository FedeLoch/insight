Class {
	#name : 'IGCoverageResultTest',
	#superclass : 'TestCase',
	#category : 'IG-CodeCov-IG-CodeCoverageTest',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverageTest'
}

{ #category : 'helper' }
IGCoverageResultTest >> assertCoverageForMethod: aMethod running: aBlock equals: expectedCoverage [

	| coverageResult |

	coverageResult := self profileInstrumenting: { aMethod }
		                  running: aBlock.
	self assert: (coverageResult coverageFor: aMethod)
		equals: expectedCoverage
]

{ #category : 'helper' }
IGCoverageResultTest >> profileInstrumenting: aMethodCollection running: aBlock [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: aMethodCollection.
	profiler profileOn: aBlock.

	^profiler coverageResult
]

{ #category : 'tests – coverage' }
IGCoverageResultTest >> testFullyExecutedMethodCoverageIs100 [

	| method |

	method := IGCoverageMock >> #oneStatement.
	self assertCoverageForMethod: method
		running: [ IGCoverageMock new oneStatement ]
		equals: 100 asFloat
]

{ #category : 'tests – failing' }
IGCoverageResultTest >> testFullyExecutedMethodCoverageIs100Failing [

	| method |

	method := IGCoverageMock >> #twoStatements.
	self assertCoverageForMethod: method
		running: [ IGCoverageMock new twoStatements ]
		equals: 100 asFloat
]

{ #category : 'tests – coverage' }
IGCoverageResultTest >> testNotExecutedMethodCoverageIs0 [

	| method |

	method := IGCoverageMock >> #twoStatements.
	self assertCoverageForMethod: method
		running: [ "Nothing" ]
		equals: 0 asFloat
]

{ #category : 'tests – coverage' }
IGCoverageResultTest >> testPartiallyExectutedMethodCoverageIsBetween0And100 [
	"IGCoverageMock >> #conditionalMethod: has 3 statements
	Calling with true execute 2 of them, so coverage is 66%."

	| method |

	method := IGCoverageMock >> #conditionalMethod:.
	self assertCoverageForMethod: method
		running: [ IGCoverageMock new conditionalMethod: true ]
		equals: (2 / 3 * 100) asFloat
]

{ #category : 'tests – exception' }
IGCoverageResultTest >> testRecordForRaiseWhenMethodNotInScope [

	self should: [ IGCoverageResult new recordFor: #someMethod ]
		raise: Error
]

{ #category : 'tests – coverage' }
IGCoverageResultTest >> testRepeatedExecutionDoesNotInflateCoverage [

	| method |

	method := IGCoverageMock >> #conditionalMethod:.
	self
		assertCoverageForMethod: method
		running: [
				| mock |

				mock := IGCoverageMock new.
				5 timesRepeat: [ mock conditionalMethod: false ]
				]
		equals: (2 / 3 * 100) asFloat
]
