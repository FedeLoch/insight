Class {
	#name : 'CallGraphHistoryAction',
	#superclass : 'IGDoAction',
	#instVars : [
		'history'
	],
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'accessing' }
CallGraphHistoryAction class >> history: history [

	^ self new history: history
]

{ #category : 'accessing' }
CallGraphHistoryAction >> history: aHistory [

	history := aHistory
]

{ #category : 'as yet unclassified' }
CallGraphHistoryAction >> reificationForContext: context [

	^ context astNode
]
