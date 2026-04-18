Class {
	#name : 'AfterHistoryAction',
	#superclass : 'IGDoAction',
	#instVars : [
		'history'
	],
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'accessing' }
AfterHistoryAction class >> history: history [

	^ self new history: history
]

{ #category : 'as yet unclassified' }
AfterHistoryAction >> do: method [
	
	history pop: method
]

{ #category : 'accessing' }
AfterHistoryAction >> history: aHistory [

	history := aHistory 
]

{ #category : 'as yet unclassified' }
AfterHistoryAction >> reificationForContext: context [

	^ context astNode
]
