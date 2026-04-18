Extension { #name : 'AllocationGraph' }

{ #category : '*Insight' }
AllocationGraph class >> from: aHistory [

	^ aHistory actions inject: self new into: [ :graph :action |
		"TODO: create the graph using the actions, we consume the stack actions and create new edges from them"
		"Example:
		#('push' #initialize) [ first ]
		#('pop' #initialize)
		#('push' #messageA:)
		#('push' #messageB:)
		#('pop' #messageA:) [ last ]"
		1 halt.
	]
]
