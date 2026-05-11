Class {
	#name : 'BeforeTimeTravelingAction',
	#superclass : 'TimeTravelingAction',
	#category : 'Insight-Time Traveling',
	#package : 'Insight',
	#tag : 'Time Traveling'
}

{ #category : 'as yet unclassified' }
BeforeTimeTravelingAction >> do: snapshot [
	
	"an snapshot of
		- the receiver ( so, it's state ),
		- The method called,
		- An snapshot of their arguments"""

	traveler addBeforeMethodSnapshot: snapshot
]

{ #category : 'as yet unclassified' }
BeforeTimeTravelingAction >> reificationForContext: context [

	1 halt. "
		It should save, an snapshot of the receiver ( so, it's state ),
		The method called,
		An snapshot of their arguments"
	^ context astNode
]
