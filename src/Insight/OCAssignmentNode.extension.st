Extension { #name : 'OCAssignmentNode' }

{ #category : '*Insight' }
OCAssignmentNode >> isStatement [

	parent ifNil: [ ^ true ].
	
	^ parent isStatement not
]

OCAssignmentNode >> igAssignmentNodes [

	^ (self children flatCollect: #igAssignmentNodes), { self }
]
