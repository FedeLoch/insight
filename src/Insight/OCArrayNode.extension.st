Extension { #name : 'OCArrayNode' }

{ #category : '*Insight' }
OCArrayNode >> allStatementsWithoutTemporaries [

	^self allStatements
]

{ #category : '*Insight' }
OCArrayNode >> flattenedNodes [

	| newSelf flattenedChildren |

	flattenedChildren := OrderedCollection new.
	newSelf := self copy.

	newSelf statements: (self statements collect: [ :stmt |
				 | flattenedStmt |

				 flattenedStmt := stmt flattenedNodes.
				 flattenedChildren addAll: flattenedStmt.
				 stmt isAssignment ifTrue: [ stmt variable copy ]
					 ifFalse: [ flattenedStmt first ] ]).

	^ (flattenedChildren reject: #isLeafNode) asArray , { newSelf }
]
