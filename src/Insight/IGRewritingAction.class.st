Class {
	#name : 'IGRewritingAction',
	#superclass : 'Object',
	#instVars : [
		'instrumentationNode'
	],
	#category : 'Insight-Instrumentation',
	#package : 'Insight',
	#tag : 'Instrumentation'
}

{ #category : 'instance creation' }
IGRewritingAction class >> with: instrumentationNode [

	^ self new instrumentationNode: instrumentationNode
]

{ #category : 'accessing' }
IGRewritingAction >> instrumentationNode [

	^ instrumentationNode
]

{ #category : 'accessing' }
IGRewritingAction >> instrumentationNode: aNode [

	instrumentationNode := aNode
]

{ #category : 'testing' }
IGRewritingAction >> isAddNewTemp [

	^ false
]

{ #category : 'testing' }
IGRewritingAction >> isAfterAction [

	^ false
]

{ #category : 'testing' }
IGRewritingAction >> isBeforeAction [

	^ false
]

{ #category : 'testing' }
IGRewritingAction >> isWrapStatement [

	^ false
]
