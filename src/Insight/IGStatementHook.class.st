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
IGStatementHook >> instrumentationNode: originalNode [

	^ action instrumentationNodeFor: (IGInstrumentationContext new astNode: originalNode).
]

{ #category : 'as yet unclassified' }
IGStatementHook >> rewriteAcceptedNode: node [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
IGStatementHook >> rewriteOperations: node [

	(self acceptsNode: node) ifFalse: [ ^ #() ].
	
	^ self rewriteAcceptedNode: node
]
