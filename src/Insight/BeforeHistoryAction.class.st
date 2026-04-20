Class {
	#name : 'BeforeHistoryAction',
	#superclass : 'CallGraphHistoryAction',
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'as yet unclassified' }
BeforeHistoryAction >> do: methodNode [

	history push: (methodNode propertyAt: 'compiledMethod')
]
