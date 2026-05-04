Extension { #name : 'OCBlockNode' }

{ #category : '*Insight' }
OCBlockNode >> allStatementsWithoutTemporaries [
	"ignoring temp variable definition."

	^OrderedCollection new
		 addAll: super allStatements; yourself
]

{ #category : '*Insight' }
OCBlockNode >> flattened [

	^ self copy body: (body flattened); yourself
]

{ #category : '*Insight' }
OCBlockNode >> flattenedNodes [
	
	^ { self flattened }
]
