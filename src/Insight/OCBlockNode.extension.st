Extension { #name : 'OCBlockNode' }

{ #category : '*Insight' }
OCBlockNode >> flattened [

	^ self copy body: (body flattened); yourself
]

{ #category : '*Insight' }
OCBlockNode >> flattenedNodes [
	
	^ { self flattened }
]
