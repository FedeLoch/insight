Class {
	#name : 'IGAssignmentHook',
	#superclass : 'IGHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'actions' }
IGAssignmentHook >> acceptsNode: node [

	^ node isAssignment and: [ node parent isSequence ]
]
