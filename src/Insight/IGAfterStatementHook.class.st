Class {
	#name : 'IGAfterStatementHook',
	#superclass : 'IGStatementHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> insertHookNode: newNode for: statementNode [

	statementNode isReturn ifTrue: [ ^ self insertHookReturnNode: newNode for: statementNode ].

	statementNode parent replaceNode: statementNode withNodes: { statementNode . newNode }
]

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> insertHookReturnNode: newNode for: returnNode [ 
	
	| temp assignment newReturnNode |
	
	temp := OCVariableNode named: #______return______.
	returnNode parent addTemporaryNamed: temp name.
	assignment := OCAssignmentNode variable: temp value: returnNode value.
	newReturnNode := OCReturnNode value: temp copy.
	
	returnNode parent replaceNode: returnNode withNodes: { assignment . newNode . newReturnNode }
]
