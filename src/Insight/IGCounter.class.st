Class {
	#name : 'IGCounter',
	#superclass : 'IGAction',
	#instVars : [
		'count'
	],
	#category : 'Insight-Instrumentation Action',
	#package : 'Insight',
	#tag : 'Instrumentation Action'
}

{ #category : 'as yet unclassified' }
IGCounter >> count [

	^ count
]

{ #category : 'as yet unclassified' }
IGCounter >> increment [

	count := count + 1.
]

{ #category : 'initialization' }
IGCounter >> initialize [

	super initialize.
	count := 0.
]

{ #category : 'as yet unclassified' }
IGCounter >> instrumentationNodeFor: context [

	^ OCMessageNode
		  receiver: (OCLiteralValueNode value: self)
		  selector: (OCSelectorNode value: #increment)
]
