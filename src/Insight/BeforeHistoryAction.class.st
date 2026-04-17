Class {
	#name : 'BeforeHistoryAction',
	#superclass : 'IGDoAction',
	#instVars : [
		'history'
	],
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'accessing' }
BeforeHistoryAction class >> history: history [

	^ self new history: history
]

{ #category : 'as yet unclassified' }
BeforeHistoryAction >> do: value [
	
	1 halt.
]

{ #category : 'accessing' }
BeforeHistoryAction >> history: aHistory [

	history := aHistory
]

{ #category : 'as yet unclassified' }
BeforeHistoryAction >> reificationForContext: context [

	^ context astNode
]
