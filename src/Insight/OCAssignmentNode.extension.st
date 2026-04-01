Extension { #name : 'OCAssignmentNode' }

{ #category : '*Insight' }
OCAssignmentNode >> igAssignmentNodes [

	^ (self children flatCollect: #igAssignmentNodes), { self }
]
