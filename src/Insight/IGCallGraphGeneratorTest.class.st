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

	self assert: graph nodes size equals: 1 "Only the root node"
]

{ #category : 'tests' }
IGCallGraphGeneratorTest >> testCreatingCallGraphOfThisClassRunningAnEmptyMethodCall [

	| graph initializeANode emptyMethodNode |

	graph := IGCallGraphGenerator callGraph: IGMock On: [ IGMock new emptyMethod ].
	
	initializeANode := graph nodeForMethod: IGMock >> #initialize.
	emptyMethodNode := graph nodeForMethod: IGMock >> #emptyMethod.

	self assert: graph nodes size equals: 3.
	self assert: initializeANode methodCalls size equals: 0.
	self assert: emptyMethodNode methodCalls size equals: 0
	
]

{ #category : 'tests' }
IGCallGraphGeneratorTest >> testCreatingCallGraphOfThisClassRunningAnSimpleMethodCall [

	| graph messageANode messageBNode |

	graph := IGCallGraphGenerator
		         callGraph: IGMock
		         On: [ IGMock new messageA: 1 ].
		
	messageANode := graph nodeForMethod: IGMock >> #messageA:.
	messageBNode := graph nodeForMethod: IGMock >> #messageB:.

	self assert: graph nodes size equals: 4.
	self assert: messageANode methodCalls size equals: 1.
	self assert: messageBNode methodCalls size equals: 0.
	self assertCollection: messageANode methodCalls hasSameElements: { messageBNode }
]
