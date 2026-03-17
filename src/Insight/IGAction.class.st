Class {
	#name : 'IGAction',
	#superclass : 'Object',
	#category : 'Insight-Instrumentation Action',
	#package : 'Insight',
	#tag : 'Instrumentation Action'
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
	instrumentationContext := (IGInstrumentationContext new astNode: node).
	instrumentationNode := self instrumentationNodeFor: instrumentationContext.
	reification := self reificationForContext: instrumentationContext.
	^ { IGInsertAfter with: instrumentationNode } , (reification rewriteOperationsForNode: node)
]
