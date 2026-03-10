Class {
	#name : 'IGAfterStatementHook',
	#superclass : 'IGStatementHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> insertHookNode: newNode for: originalStatementNode [

	| statementNode variableName |
	
	variableName := #______statementResult______.

	statementNode := OCAssignmentNode variable:
		(OCVariableNode named: variableName) value: originalStatementNode copy.
		
	(originalStatementNode parent temporaryNames includes: variableName) ifFalse: [
		originalStatementNode parent addTemporaryNamed: variableName
	].

	originalStatementNode isReturn ifTrue: [ ^ self insertHookReturnNode: newNode for: statementNode ].

	originalStatementNode parent replaceNode: originalStatementNode withNodes: { statementNode . newNode }
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

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> rewriteAcceptedNode: node [

	^ { IGInsertAfter with: (self instrumentationNode: node) }
]
