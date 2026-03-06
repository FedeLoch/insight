Class {
	#name : 'IGStatementHook',
	#superclass : 'Object',
	#instVars : [
		'action'
	],
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'actions' }
IGStatementHook >> acceptsNode: aNode [

	"If root its not a statement"
	aNode parent ifNil: [ ^ false ].
	
	"The node should be a child of a sequence"
	aNode parent isSequence ifFalse: [ ^ false ].
	
	"Then it should not be one of the temporary nodes, checked by identity, to be able to instrument variable nodes in statements"
	^ (aNode parent temporaries identityIncludes: aNode) not
]

{ #category : 'enumerating' }
IGStatementHook >> do: anAction [

	action := anAction
]

{ #category : 'as yet unclassified' }
IGStatementHook >> insertHookNode: newNode for: statementNode [

	self subclassResponsibility 

]

{ #category : 'actions' }
IGStatementHook >> install: ast original: originalAST [

	(ast allStatements collect: [ :statement | { statement . originalAST childAtPath: (statement treePath) } ]) do: [ :pair |
		self rewrite: pair first original: pair second
	].
	
	^ ast
]

{ #category : 'actions' }
IGStatementHook >> instrumentNodePair: nodePair [

	(self acceptsNode: nodePair second) ifFalse: [ ^ self ].
	
	self rewrite: nodePair first original: nodePair second
]

{ #category : 'as yet unclassified' }
IGStatementHook >> rewrite: statementNode original: originalNode [

	| newNode context |
	context := IGInstrumentationContext new astNode: originalNode.

	newNode := OCMessageNode
		             receiver: (OCLiteralNode value: action)
		             selector: #value:
		             arguments:
		             { (action collectionProperty value: context) }.

	self insertHookNode: newNode for: statementNode.

]
