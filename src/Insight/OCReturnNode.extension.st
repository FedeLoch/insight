Extension { #name : 'OCReturnNode' }

{ #category : '*Insight' }
OCReturnNode >> flattenedNodes [

	| newSelf flattenedChildren |
	flattenedChildren := self value flattenedNodes.

	newSelf := self copy value: (value isAssignment
			            ifTrue: [ value variable copy ]
			            ifFalse: [ flattenedChildren first ]).

	^ (flattenedChildren reject: #isLeafNode) , { newSelf }
]

{ #category : '*Insight' }
OCReturnNode >> isStatement [ 

	^ true
]
