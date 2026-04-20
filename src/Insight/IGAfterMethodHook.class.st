Class {
	#name : 'IGAfterMethodHook',
	#superclass : 'IGMethodHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGAfterMethodHook >> rewriteAcceptedNode: node [

	"TODO: we are duplicating this in each after hook"
	^ action rewriteOperationsAfterNode: node
]
