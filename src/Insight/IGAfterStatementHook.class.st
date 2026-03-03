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
IGAfterStatementHook >> install: ast [
	
	ast allStatements do: [ :statement | self rewrite: statement ].
	
	^ ast
]

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> rewrite: statementNode [ 

	| afterNode |
	
	afterNode := OCMessageNode receiver: (OCLiteralNode value: block) selector: #value: arguments: { OCLiteralNode value: statementNode }.

	statementNode parent replaceNode: statementNode withNodes: { statementNode . afterNode }
]
