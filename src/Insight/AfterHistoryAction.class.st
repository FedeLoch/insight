Class {
	#name : 'AfterHistoryAction',
	#superclass : 'CallGraphHistoryAction',
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
