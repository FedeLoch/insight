Class {
	#name : 'IGBeforeMethodHook',
	#superclass : 'IGMethodHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGBeforeMethodHook >> rewriteAcceptedNode: node [

	"TODO: we are duplicating this in each after hook"
	^ action rewriteOperationsBeforeNode: node
]
