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

{ #category : 'accessing' }
BeforeHistoryAction >> history: aHistory [

	history := aHistory
]
