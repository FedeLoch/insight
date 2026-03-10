Class {
	#name : 'IGAfterStatementHook',
	#superclass : 'IGStatementHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'as yet unclassified' }
IGAfterStatementHook >> rewriteAcceptedNode: node [

	^ { IGInsertAfter with: (self instrumentationNode: node) }
]
