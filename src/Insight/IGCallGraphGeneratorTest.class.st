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

	graph := IGCallGraphGenerator callGraph: self class On: [].
	1 halt.
]
