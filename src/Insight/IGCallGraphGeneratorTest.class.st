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

	graph := IGCallGraphGenerator callGraph: IGTest class On: [].

	self assert: graph nodes equals: #()
]

{ #category : 'tests' }
IGCallGraphGeneratorTest >> testCreatingCallGraphOfThisClassRunningAnEmptyMethodCall [

	| graph |

	graph := IGCallGraphGenerator callGraph: IGTest class On: [ IGTest new emptyMethod ].

	self assert: graph nodes equals: #()
]

{ #category : 'tests' }
IGCallGraphGeneratorTest >> testCreatingCallGraphOfThisClassRunningAnSimpleMethodCall [

	| graph |

	graph := IGCallGraphGenerator callGraph: IGTest class On: [ IGTest new sequencialMethod ].
1 halt.
	self assert: graph nodes equals: #()
]
