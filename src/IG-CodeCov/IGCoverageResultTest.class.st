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

{ #category : 'fixture' }
IGCoverageResultTest >> basicCoverage [

	| coveredMethod uncoveredMethod partiallyCoveredMethod |

	coveredMethod := IGCoverageMock >> #oneStatement.
	partiallyCoveredMethod := IGCoverageMock >> #conditionalMethod:.
	uncoveredMethod := IGCoverageMock >> #callSubMethod.

	^self
		 profileInstrumenting: {
				 coveredMethod.
				 partiallyCoveredMethod.
				 uncoveredMethod }
		 running: [
				 IGCoverageMock new
					 oneStatement; conditionalMethod: true
				 ]
]

{ #category : 'helper' }
IGCoverageResultTest >> profileInstrumenting: aMethodCollection running: aBlock [

	| profiler |

	profiler := IGCodeCoverageProfiler new.
	profiler methodsToInstrument: aMethodCollection.
	profiler profileOn: aBlock.

	^profiler coverageResult
]

{ #category : 'tests – lists' }
IGCoverageResultTest >> testFullyCoveredContainExecutedMethods [

	| methods coverage |

	methods := {
		           (IGCoverageMock >> #callSubMethod).
		           (IGCoverageMock >> #oneStatement) }.
	coverage := self profileInstrumenting: methods
		            running: [ IGCoverageMock new callSubMethod ].
	self assertCollection: coverage fullyCoveredMethods
		includesAll: methods
]

{ #category : 'tests – coverage' }
IGCoverageResultTest >> testFullyExecutedMethodCoverageIs100 [

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

{ #category : 'tests – lists' }
IGCoverageResultTest >> testPartiallyCoveredContainBranchingMethod [

	| coverage |

	coverage := self basicCoverage.

	self assertCollection: coverage partiallyCoveredMethods
		includesAll: { (IGCoverageMock >> #conditionalMethod:) }
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

{ #category : 'tests – percentages' }
IGCoverageResultTest >> testPercentagesReflectCategory [

	| coverage |

	coverage := self basicCoverage.

	self assert: coverage fullyCoveredPercentage
		equals: (100 / 3) asFloat.
	self assert: coverage partiallyCoveredPercentage
		equals: (100 / 3) asFloat.
	self assert: coverage uncoveredPercentage
		equals: (100 / 3) asFloat
]

{ #category : 'tests – percentages' }
IGCoverageResultTest >> testPercentagesSumsUpTo100 [

	| coverage |

	coverage := self basicCoverage.

	self
		assert:
			coverage fullyCoveredPercentage
			+ coverage partiallyCoveredPercentage
			+ coverage uncoveredPercentage
		equals: 100 asFloat
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

{ #category : 'tests – lists' }
IGCoverageResultTest >> testUncoveredContainEmptyMethod [

	| method coverage |

	method := IGCoverageMock >> #emptyMethod.
	coverage := self profileInstrumenting: { method }
		            running: [ "Nothing" ].

	self assertCollection: coverage uncoveredMethods
		includesAny: { method }
]
