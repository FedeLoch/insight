Class {
	#name : 'IGAfterStatementHook',
	#superclass : 'Object',
	#instVars : [
		'block'
	],
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'enumerating' }
IGAfterStatementHook >> do: aBlock [

	block := aBlock
]

{ #category : 'actions' }
IGAfterStatementHook >> install: ast original: originalAST [

	(ast allStatements collect: [ :statement | { statement . originalAST childAtPath: (statement treePath) } ]) do: [ :pair |
		self rewrite: pair first original: pair second 
	].
	
	^ ast
]

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> rewrite: statementNode original: originalNode [

	| afterNode |
	
	afterNode := OCMessageNode receiver: (OCLiteralNode value: block) selector: #value: arguments: {
		OCLiteralNode value: originalNode
	}.

	statementNode parent replaceNode: statementNode withNodes: { statementNode . afterNode }
]
