Class {
	#name : 'AfterHistoryAction',
	#superclass : 'CallGraphHistoryAction',
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'as yet unclassified' }
AfterHistoryAction >> do: methodNode [
	
	history pop: (methodNode propertyAt: 'compiledMethod')
]
