Class {
	#name : 'IGAction',
	#superclass : 'Object',
	#category : 'Insight-Actions',
	#package : 'Insight',
	#tag : 'Actions'
}

{ #category : 'as yet unclassified' }
IGAction >> instrumentationNodeFor: context [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
IGAction >> reificationForContext: context [

	^ self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
IGAction >> rewriteOperationsAfterNode: node [

	| instrumentationNode reification instrumentationContext |
	
	instrumentationContext := IGInstrumentationContext new astNode: node.
	instrumentationNode := self instrumentationNodeFor: instrumentationContext.
	
	reification := self reificationForContext: instrumentationContext.
	
	^ { IGInsertAfter with: instrumentationNode }, (reification rewriteOperationsForNode: node)
]

{ #category : 'as yet unclassified' }
IGAction >> rewriteOperationsBeforeNode: node [

	| instrumentationNode instrumentationContext |
	
	instrumentationContext := IGInstrumentationContext new astNode: node.
	instrumentationNode := self instrumentationNodeFor: instrumentationContext.

	^ { IGInsertBefore with: instrumentationNode }
]
