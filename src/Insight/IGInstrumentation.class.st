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

	| originalAST instrumentedAST rewriteOperationsPerNode |

	originalAST := method ast.
	instrumentedAST := originalAST copy.
	rewriteOperationsPerNode := IdentityDictionary new.

	instrumentedAST nodesDo: [ :node | | operations |
		operations := rewriteOperationsPerNode at: node ifAbsentPut: [ Set new ].
		hooks do: [ :hook | operations addAll: (hook rewriteOperations:
			(originalAST childAtPath: (node treePath)))
		]
	].

	instrumentedAST allChildrenPostOrder do: [ :node |
		(rewriteOperationsPerNode at: node) ifNotEmpty: [
			:operations | self rewriteNode: node with: operations
		]
	].

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
IGInstrumentation >> rewriteNode: node with: operations [ 

	| beforeNodes afterNodes |
	
	beforeNodes := operations select: #isBeforeAction thenCollect: #instrumentationNode.
	afterNodes := operations reject: #isBeforeAction thenCollect: #instrumentationNode.
	
	node parent replaceNode: node withNodes: beforeNodes asArray, { node copy }, afterNodes asArray.
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> uninstrument: method [

	method methodClass methodDict at: method selector put: method
]
