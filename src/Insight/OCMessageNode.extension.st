Extension { #name : 'OCMessageNode' }

{ #category : '*Insight' }
OCMessageNode >> flattenedNodes [
	
	| newSelf flattenedChildren flattenedReceier |
	
	flattenedChildren := OrderedCollection new.
	
	newSelf := self copy.
	
	flattenedReceier := receiver flattenedNodes.
	flattenedChildren addAll: flattenedReceier.
	newSelf receiver: (receiver isAssignment ifTrue: [ receiver variable copy ] ifFalse: [ flattenedReceier first ]).

	newSelf arguments: (self arguments collect: [ :arg | | flattenedArg |
		flattenedArg := arg flattenedNodes.
		flattenedChildren addAll: flattenedArg.
		arg isAssignment ifTrue: [ arg variable copy ] ifFalse: [ flattenedArg first ]
	]).

	^ (flattenedChildren reject: #isLeafNode) asArray, { newSelf }
]
