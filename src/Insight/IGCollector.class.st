Class {
	#name : 'IGCollector',
	#superclass : 'IGAction',
	#instVars : [
		'collection',
		'collectionProperty'
	],
	#category : 'Insight-Instrumentation Action',
	#package : 'Insight',
	#tag : 'Instrumentation Action'
}

{ #category : 'enumerating' }
IGCollector class >> collect: aBlock [

	^ self new collectionProperty: aBlock
]

{ #category : 'accessing' }
IGCollector >> collection [

	^ collection
]

{ #category : 'accessing' }
IGCollector >> collectionProperty [

	^ collectionProperty
]

{ #category : 'accessing' }
IGCollector >> collectionProperty: anObject [

	collectionProperty := anObject
]

{ #category : 'testing' }
IGCollector >> includes: aValue [

	^ collection includes: aValue 
]

{ #category : 'initialization' }
IGCollector >> initialize [ 

	super initialize.
	collection := OrderedCollection new.
	collectionProperty := [ :instrumentationContext | instrumentationContext astNode ]
]

{ #category : 'as yet unclassified' }
IGCollector >> instrumentationNodeFor: context [

	^ OCMessageNode
		  receiver: (OCLiteralNode value: self)
		  selector: #value:
		  arguments: { (collectionProperty value: context) }
]

{ #category : 'accessing' }
IGCollector >> value: value [

	collection add: value
]
