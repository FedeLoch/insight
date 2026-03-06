Class {
	#name : 'IGAfterStatementHook',
	#superclass : 'IGStatementHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> insertHookNode: newNode for: statementNode [

	statementNode parent replaceNode: statementNode withNodes: { statementNode . newNode }
]
