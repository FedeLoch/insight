Extension { #name : 'OCAssignmentNode' }

{ #category : '*Insight' }
OCAssignmentNode >> isStatement [

	parent ifNil: [ ^ true ].
	
	^ parent isStatement not
]
