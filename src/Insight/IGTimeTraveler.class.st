Class {
	#name : 'IGTimeTraveler',
	#superclass : 'Object',
	#category : 'Insight-Time Traveling',
	#package : 'Insight',
	#tag : 'Time Traveling'
}

{ #category : 'as yet unclassified' }
IGTimeTraveler class >> record: aBlock forClass: aClass [

	| instrumentation timeTraveler |
	
	timeTraveler := self new.

	instrumentation := IGInstrumentation new addHooks: {
		IGBeforeMethodHook new do: (BeforeTimeTravelingAction traveler: timeTraveler).
		IGAfterMethodHook new do: (AfterTimeTravelingyAction traveler: timeTraveler)
	}; instrumentClass: aClass during: aBlock.
	
	^ timeTraveler
]

{ #category : 'adding' }
IGTimeTraveler >> addAfterMethodSnapshot: snapshot [

	1 halt.
]

{ #category : 'adding' }
IGTimeTraveler >> addBeforeMethodSnapshot: snapshot [

	1 halt.
]
