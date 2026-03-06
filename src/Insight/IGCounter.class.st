Class {
	#name : 'IGCounter',
	#superclass : 'IGAction',
	#instVars : [
		'count',
		'keyBlock',
		'allKey'
	],
	#category : 'Insight-Instrumentation Action',
	#package : 'Insight',
	#tag : 'Instrumentation Action'
}

{ #category : 'initialization' }
IGCounter >> allKey [

	^ allKey
]

{ #category : 'as yet unclassified' }
IGCounter >> allKeyValue [

	^ nil
]

{ #category : 'as yet unclassified' }
IGCounter >> count [

	^ self countAt: self allKeyValue
]

{ #category : 'as yet unclassified' }
IGCounter >> countAt: key [

	^ count at: key ifAbsent: 0
]

{ #category : 'as yet unclassified' }
IGCounter >> countKeyBy: block [

	keyBlock := block 	
]

{ #category : 'as yet unclassified' }
IGCounter >> incrementAt: key [

	count at: key update: [ :v | v + 1 ] initial: 1
	
]

{ #category : 'initialization' }
IGCounter >> initialize [

	super initialize.
	count := Dictionary new.
	allKey := OCLiteralNode value: self allKeyValue.
	keyBlock := [ :_ | self allKey ]
]

{ #category : 'as yet unclassified' }
IGCounter >> instrumentationNodeFor: context [

	^ OCMessageNode
		  receiver: (OCLiteralValueNode value: self)
		  selector: (OCSelectorNode value: #incrementAt:)
			arguments: { keyBlock value: context }
]
