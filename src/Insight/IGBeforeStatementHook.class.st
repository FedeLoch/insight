Class {
	#name : 'IGBeforeStatementHook',
	#superclass : 'IGStatementHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGBeforeStatementHook >> rewriteAcceptedNode: node [

	^ { IGInsertBefore with: (self instrumentationNode: node) }
	
]
