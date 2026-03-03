Class {
	#name : 'IGCollector',
	#superclass : 'Object',
	#instVars : [
		'collection'
	],
	#category : 'Insight',
	#package : 'Insight'
}

{ #category : 'testing' }
IGCollector >> includes: aValue [

	^ collection includes: aValue 
]

{ #category : 'initialization' }
IGCollector >> initialize [ 

	super initialize.
	collection := IdentitySet new.
]

{ #category : 'accessing' }
IGCollector >> value: aValue [

	collection add: aValue 
]
