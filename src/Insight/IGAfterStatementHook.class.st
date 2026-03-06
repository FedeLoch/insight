Class {
	#name : 'IGAfterStatementHook',
	#superclass : 'Object',
	#instVars : [
		'action'
	],
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'enumerating' }
IGAfterStatementHook >> do: anAction [

	action := anAction
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

	| afterNode context |
	context := IGInstrumentationContext new astNode: originalNode.

	afterNode := OCMessageNode
		             receiver: (OCLiteralNode value: action)
		             selector: #value:
		             arguments:
		             { (action collectionProperty value: context) }.

	statementNode parent replaceNode: statementNode withNodes: {
			statementNode.
			afterNode }
]
