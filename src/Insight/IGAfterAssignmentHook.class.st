Class {
	#name : 'IGAfterAssignmentHook',
	#superclass : 'IGAssignmentHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGAfterAssignmentHook >> rewriteAcceptedNode: node [

	^ action rewriteOperationsAfterNode: node
]
