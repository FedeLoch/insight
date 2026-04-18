Class {
	#name : 'BeforeHistoryAction',
	#superclass : 'CallGraphHistoryAction',
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
	
	history push: value
]
