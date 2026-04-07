Extension { #name : 'OCSequenceNode' }

{ #category : '*Insight' }
OCSequenceNode >> flattened [

	| newStatements |
	
	newStatements := statements flatCollect: #flattenedNodes.

	^ self copy statements: newStatements; yourself
]
