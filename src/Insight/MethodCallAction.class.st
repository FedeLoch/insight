Class {
	#name : 'MethodCallAction',
	#superclass : 'Object',
	#instVars : [
		'method'
	],
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'instance creation' }
MethodCallAction class >> from: method [

	^ self new method: method
]

{ #category : 'accessing' }
MethodCallAction >> method [
	
	^ method
]

{ #category : 'accessing' }
MethodCallAction >> method: aMethod [

	method := aMethod
]
