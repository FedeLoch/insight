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

{ #category : 'break' }
IGInstrumentationContext >> break [

	^ OCMessageNode
		  receiver: OCVariableNode selfNode
		  selector: (OCSelectorNode value: #halt)
]

{ #category : 'accessing' }
IGInstrumentationContext >> receiver [

	^ OCVariableNode selfNode
]

{ #category : 'accessing - context' }
IGInstrumentationContext >> variableNamed: variableName [ 

	^ OCVariableNode named: variableName 
]
