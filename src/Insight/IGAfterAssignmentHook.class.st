Class {
	#name : 'IGAfterAssignmentHook',
	#superclass : 'IGStatementHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'actions' }
IGAfterAssignmentHook >> acceptsNode: node [

	^ node isAssignment and: [ node parent isSequence ]
]

{ #category : 'as yet unclassified' }
IGAfterAssignmentHook >> rewriteAcceptedNode: node [

	^ action rewriteOperationsAssignmentAfterNode: node
]
