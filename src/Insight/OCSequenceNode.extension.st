Extension { #name : 'OCSequenceNode' }

{ #category : '*Insight' }
OCSequenceNode >> allStatementsWithoutTemporaries [

	^self allStatements
]

{ #category : '*Insight' }
OCSequenceNode >> flattened [

	| newStatements |
	
	newStatements := statements flatCollect: #flattenedNodes.

	^ self copy statements: newStatements; yourself
]
