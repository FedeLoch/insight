Class {
	#name : 'IGInstrumentationContext',
	#superclass : 'Object',
	#instVars : [
		'astNode'
	],
	#category : 'Insight-Context',
	#package : 'Insight',
	#tag : 'Context'
}

{ #category : 'accessing' }
IGInstrumentationContext >> astNode [

	^ OCLiteralNode value: astNode
]

{ #category : 'accessing' }
IGInstrumentationContext >> astNode: anObject [

	astNode := anObject
]

{ #category : 'accessing' }
IGInstrumentationContext >> receiver [

	^ OCVariableNode selfNode
]
