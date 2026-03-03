Extension { #name : 'OCProgramNode' }

{ #category : '*Insight' }
OCProgramNode >> childAtPath: aPath [

    "Return the AST node following aPath from myself.
    aPath is a list of indexes, each index is the index of the child in the children collection.
    
    See #treePath"
    
    aPath ifEmpty: [ ^ self ].
    ^ (self children at: aPath first) childAtPath: aPath allButFirst
]

{ #category : '*Insight' }
OCProgramNode >> treePath [

    "Return the index path to get to self from the method node.

    See #childAtPath:"

    ^ self treePathUpTo: self methodNode
]

{ #category : '*Insight' }
OCProgramNode >> treePathUpTo: aParent [

    "Return the index path to get to self from aParent.
    
    See #childAtPath:"

    aParent == self ifTrue: [ ^ #(  ) ].
    ^ (self parent treePathUpTo: aParent) , { (self parent children indexOf: self) }
]
