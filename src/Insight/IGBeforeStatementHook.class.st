Class {
	#name : 'IGBeforeStatementHook',
	#superclass : 'IGStatementHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGBeforeStatementHook >> insertHookNode: newNode for: statementNode [

	statementNode parent replaceNode: statementNode withNodes: { newNode . statementNode }
]
