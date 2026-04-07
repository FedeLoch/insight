Extension { #name : 'OCMethodNode' }

{ #category : '*Insight' }
OCMethodNode >> flattened [
	
	^ self copy body: (self body flattened); yourself
]
