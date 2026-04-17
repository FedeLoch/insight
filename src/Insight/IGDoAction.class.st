Class {
	#name : 'IGDoAction',
	#superclass : 'IGAction',
	#category : 'Insight-Actions',
	#package : 'Insight',
	#tag : 'Actions'
}

{ #category : 'as yet unclassified' }
IGDoAction >> do: value [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
IGDoAction >> instrumentationNodeFor: context [

	| reification |
	reification := self reificationForContext: context.

	^ OCMessageNode
		  receiver: (OCLiteralValueNode value: self)
		  selector: (OCSelectorNode value: #do:)
		  arguments: { reification nodeToReify }
]
