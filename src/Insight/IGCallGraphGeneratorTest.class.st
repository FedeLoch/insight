Class {
	#name : 'IGCallGraphGeneratorTest',
	#superclass : 'TestCase',
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'tests' }
IGCallGraphGeneratorTest >> testCreatingCallGraphOfThisClassRunningAnEmptyBlock [

	| graph |

	graph := IGCallGraphGenerator callGraph: IGMock On: [].

	self assert: graph nodes equals: #()
]

{ #category : 'tests' }
IGCallGraphGeneratorTest >> testCreatingCallGraphOfThisClassRunningAnEmptyMethodCall [

	| graph |

	graph := IGCallGraphGenerator callGraph: IGMock On: [ IGMock new emptyMethod ].

	self assert: graph nodes equals: #()
]

{ #category : 'tests' }
IGCallGraphGeneratorTest >> testCreatingCallGraphOfThisClassRunningAnSimpleMethodCall [

	| graph |

	graph := IGCallGraphGenerator callGraph: IGMock On: [ IGMock new messageA: 1 ].

	self assert: graph nodes equals: #()
]
