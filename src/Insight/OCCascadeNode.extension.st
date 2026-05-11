Extension { #name : 'OCCascadeNode' }

{ #category : '*Insight' }
OCCascadeNode >> flattenedNodes [

	| newSelf flattenedChildren |

	flattenedChildren := OrderedCollection new.
	newSelf := self copy.

	newSelf messages: (self messages collect: [ :message |
				 | flattenedMessage |

				 flattenedMessage := message flattenedNodes.
				 flattenedChildren addAll: flattenedMessage.
				 flattenedMessage last ]) asOrderedCollection.

	^ (flattenedChildren reject: #isLeafNode) asArray , { newSelf }
]
