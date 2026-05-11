Class {
	#name : 'TimeTravelingAction',
	#superclass : 'IGDoAction',
	#instVars : [
		'traveler',
		'root',
		'currentNode',
		'snapshots'
	],
	#category : 'Insight-Time Traveling',
	#package : 'Insight',
	#tag : 'Time Traveling'
}

{ #category : 'as yet unclassified' }
TimeTravelingAction class >> traveler: aTraveler [

	^ self new traveler: aTraveler
]

{ #category : 'initialization' }
TimeTravelingAction >> initialize [ 
	
	super initialize.
	"It should insert a root node"
	root := nil.
	snapshots := OrderedCollection new.
	currentNode := nil
]

{ #category : 'accessing' }
TimeTravelingAction >> traveler: aTraveler [

	traveler := aTraveler
]
