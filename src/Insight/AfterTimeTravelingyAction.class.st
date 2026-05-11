Class {
	#name : 'AfterTimeTravelingyAction',
	#superclass : 'TimeTravelingAction',
	#category : 'Insight-Time Traveling',
	#package : 'Insight',
	#tag : 'Time Traveling'
}

{ #category : 'as yet unclassified' }
AfterTimeTravelingyAction >> do: snapshot [

	"an snapshot of:
		- The receiver ( so, it's final state ),
		- The method called"
	
	traveler addAfterMethodSnapshot: snapshot
]

{ #category : 'as yet unclassified' }
AfterTimeTravelingyAction >> reificationForContext: context [

	1 halt. "
		It should save, an snapshot of the receiver ( so, it's final state ),
		The method called"
	^ context astNode
]
