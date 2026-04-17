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

{ #category : 'accessing' }
AfterHistoryAction >> history: aHistory [

	history := aHistory 
]
