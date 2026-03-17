Class {
	#name : 'IGGenericReification',
	#superclass : 'Object',
	#instVars : [
		'nodeToReify'
	],
	#category : 'Insight-Context',
	#package : 'Insight',
	#tag : 'Context'
}

{ #category : 'accessing' }
IGGenericReification class >> value: anOCLiteralValueNode [

	^ self new
		  nodeToReify: anOCLiteralValueNode;
		  yourself
]

{ #category : 'accessing' }
IGGenericReification >> nodeToReify [
	^ nodeToReify
]

{ #category : 'as yet unclassified' }
IGGenericReification >> nodeToReify: anOCLiteralValueNode [

	nodeToReify := anOCLiteralValueNode
]
