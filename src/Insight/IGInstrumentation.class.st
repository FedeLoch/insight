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

{ #category : 'adding' }
IGInstrumentation >> addHooks: collection [

	hooks addAll: collection
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> generateInstrumentedAST: method [

	| originalAST instrumentedAST rewriteOperationsPerNode |

	originalAST := method ast.

	originalAST nodesDo: [ :node | node propertyAt: #original put: node ].

	instrumentedAST := originalAST flattened. 
	rewriteOperationsPerNode := IdentityDictionary new.

	instrumentedAST nodesDo: [ :node | | operations |
		operations := rewriteOperationsPerNode at: node ifAbsentPut: [ Set new ].
			hooks do: [ :hook | | subNode |
				subNode := node propertyAt: #original.
				operations addAll: (hook rewriteOperations: subNode) ] ].

	instrumentedAST allChildrenPostOrder do: [ :node |
			(rewriteOperationsPerNode at: node) ifNotEmpty: [ :operations |
				self rewriteNode: node with: operations ] ].

	^ instrumentedAST
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> generateInstrumentedMethod: method [

	| instrumentedAST |

	instrumentedAST := self generateInstrumentedAST: method.

	^ method methodClass compiler ast: instrumentedAST; doSemanticAnalysis; compile
]

{ #category : 'initialization' }
IGInstrumentation >> initialize [ 
	
	super initialize.
	hooks := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> instrumentClass: aClass during: blockToEval [

	| previousMethods |

	previousMethods := aClass localMethods.  
	aClass localMethods do: [ :method | self instrumentMethod: method ].

	^ blockToEval ensure: [
		previousMethods do: [ :method | self uninstrumentMethod: method ]
	]
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> instrumentMethod: method [

	oldMethod := method.
	newMethod := self generateInstrumentedMethod: method.

	"TODO: refactor me, please"
	method methodClass methodDict at: newMethod selector put: newMethod
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> instrumentMethod: method during: blockToEval [

	self instrumentMethod: method.
	
	^ blockToEval ensure: [ self uninstrumentMethod: method ].
	
	 
	
	
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> rewriteAssignment: node before: beforeNodes after: afterNodes wrapped: wrappedNode [

	| newNodes |
	
	newNodes := beforeNodes asArray, { node }, afterNodes asArray.
	
	^ node parent replaceNode: node withNodes: newNodes
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> rewriteMethod: method before: beforeNodes after: afterNodes [ 

	| methodBody newNode |
	
	methodBody := method body.
	newNode := OCSequenceNode statements: (beforeNodes asArray, { methodBody }, afterNodes asArray).
	"TODO: should we replace the current method by a new one that call have a sequence with:
		- beforeNodes
		- call method: sameArgs
		- afterNodes"
	method replaceNode: methodBody withNode: newNode
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> rewriteNode: node with: operations [

	| beforeNodes afterNodes wrapStatements wrappedNode newTempNodes |
	
	wrapStatements := operations select: [ :e | e isWrapStatement ].
	wrappedNode := wrapStatements ifEmpty: [ node copy ] ifNotEmpty: [
		wrapStatements anyOne instrumentationNode
	].

	newTempNodes := operations select: #isAddNewTemp thenCollect: #instrumentationNode.
	beforeNodes := operations select: #isBeforeAction thenCollect: #instrumentationNode.
	afterNodes := operations select: #isAfterAction thenCollect: #instrumentationNode.

	newTempNodes do: [ :e | node parent addTemporaryNamed: e name ].

	node isReturn ifTrue: [
		self rewriteReturnNode: node before: beforeNodes after: afterNodes wrapped: wrappedNode.
		"RETURNING"
		^ self
	].

	"Assignment case"
	node isAssignment ifTrue: [
		self rewriteAssignment: node before: beforeNodes after: afterNodes wrapped: wrappedNode.
		"RETURNING"
		^ self
	].

	"Method case"
	node isMethod ifTrue: [
		self rewriteMethod: node before: beforeNodes after: afterNodes.
		"RETURNING"
		^ self
	].

	"Default case"
	node parent replaceNode: node withNodes:
		beforeNodes asArray, { wrappedNode }, afterNodes asArray
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> rewriteReturnNode: node before: beforeNodes after: afterNodes wrapped: wrappedNode [

	| assigmentNode newReturnNode returnValueNode |
	
	returnValueNode := wrappedNode value.
	node parent addTemporaryNamed: 'returnVal'.
	assigmentNode := OCAssignmentNode
		variable: (OCVariableNode named: 'returnVal') value: returnValueNode.

	newReturnNode := OCReturnNode value: (OCVariableNode named: 'returnVal').

	^ node parent replaceNode: node withNodes:
		beforeNodes asArray, { assigmentNode }, afterNodes asArray, { newReturnNode }
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> uninstrumentMethod: method [

	method methodClass methodDict at: method selector put: method
]
