Extension { #name : 'OCAssignmentNode' }

{ #category : '*Insight' }
OCAssignmentNode >> flattenedNodes [

	| newSelf flattenedChildren |
	flattenedChildren := self value flattenedNodes.

	newSelf := self copy value: (value isAssignment
			            ifTrue: [ value variable ]
			            ifFalse: [ flattenedChildren first ]).

	^ (flattenedChildren reject: #isLeafNode) , { newSelf }
]

{ #category : '*Insight' }
OCAssignmentNode >> igAssignmentNodes [

	^ (self children flatCollect: #igAssignmentNodes), { self }
]

{ #category : '*Insight' }
OCAssignmentNode >> isStatement [

	parent ifNil: [ ^ true ].
	
	^ parent isStatement not
]
