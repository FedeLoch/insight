Class {
	#name : 'IGBeforeAssignmentHook',
	#superclass : 'IGAssignmentHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGBeforeAssignmentHook >> rewriteAcceptedNode: node [

	^ action rewriteOperationsBeforeNode: node
]
