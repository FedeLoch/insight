Extension { #name : 'OCMethodNode' }

{ #category : '*Insight' }
OCMethodNode >> allStatementsWithoutTemporaries [
	"return the statements ignoring variable definition."

	^OrderedCollection new addAll: super allStatements; yourself
]

{ #category : '*Insight' }
OCMethodNode >> flattened [
	
	^ self copy body: (self body flattened); yourself
]

{ #category : '*Insight' }
OCMethodNode >> flattenedNodes [

	^ self flattened
]
