Extension { #name : 'AllocationGraph' }

{ #category : '*Insight' }
AllocationGraph >> buildFrom: aHistory [

	| callStack |
	
	callStack := Stack new.

	aHistory actions do: [ :action |
		action isPush ifTrue: [ callStack push: action method ]
			ifFalse: [ | caller callee edge |
				callee := action method.
				callStack isEmpty ifTrue: [ "root node, no action" ] ifFalse: [
					caller := callStack pop.
					edge := self edgeFrom: caller to: callee. "We are creating the edge here"
				]
			]
		].

	^ self
]

{ #category : '*Insight' }
AllocationGraph class >> from: aHistory [

	^ self new buildFrom: aHistory
]
