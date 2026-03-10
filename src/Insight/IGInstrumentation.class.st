Class {
	#name : 'IGInstrumentation',
	#superclass : 'Object',
	#instVars : [
		'hooks',
		'oldMethod',
		'newMethod'
	],
	#category : 'Insight-Instrumentation',
	#package : 'Insight',
	#tag : 'Instrumentation'
}

{ #category : 'initialization' }
IGInstrumentation >> addHook: aHook [

	hooks add: aHook 
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> generateInstrumentedMethod: method [

	| originalAST instrumentedAST pairOfASTNodes |

	originalAST := method ast.
	instrumentedAST := originalAST copy.
	pairOfASTNodes := instrumentedAST allChildren collect:
		[ :child | { child . originalAST childAtPath: (child treePath) }
	].
	
	pairOfASTNodes do: [ :nodePair | hooks do: [ :hook | hook instrumentNodePair: nodePair ] ].

	^ method methodClass compiler ast: instrumentedAST; doSemanticAnalysis; compile.
]

{ #category : 'initialization' }
IGInstrumentation >> initialize [ 
	
	super initialize.
	hooks := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> instrument: method [

	oldMethod := method.
	newMethod := self generateInstrumentedMethod: method.

	"TODO: refactor me, please"
	method methodClass methodDict at: newMethod selector put: newMethod
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> instrument: method during: blockToEval [

	self instrument: method.
	
	^ blockToEval ensure: [ self uninstrument: method ].
	
	 
	
	
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> uninstrument: method [

	method methodClass methodDict at: method selector put: method
]
