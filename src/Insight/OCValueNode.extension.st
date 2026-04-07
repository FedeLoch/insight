Extension { #name : 'OCValueNode' }

{ #category : '*Insight' }
OCValueNode >> isLeafNode [ 

	^ self isAssignment not
]
