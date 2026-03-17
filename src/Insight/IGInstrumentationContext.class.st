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

	^ IGGenericReification value: (OCLiteralNode value: astNode)
]

{ #category : 'accessing' }
IGInstrumentationContext >> astNode: anObject [

	astNode := anObject
]

{ #category : 'break' }
IGInstrumentationContext >> break [

	^ IGGenericReification value: (OCMessageNode
			   receiver: OCVariableNode selfNode
			   selector: (OCSelectorNode value: #halt))
]

{ #category : 'accessing' }
IGInstrumentationContext >> receiver [

	^ IGGenericReification value: OCVariableNode selfNode
]

{ #category : 'as yet unclassified' }
IGInstrumentationContext >> statementResult [

	^ OCVariableNode named: #______statementResult______
]

{ #category : 'accessing - context' }
IGInstrumentationContext >> variableNamed: variableName [

	^ IGGenericReification value: (OCVariableNode named: variableName)
]
