Class {
	#name : 'CallHistory',
	#superclass : 'Object',
	#instVars : [
		'actions'
	],
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'api - actions' }
CallHistory >> actions [
	
	^ actions
]

{ #category : 'adding' }
CallHistory >> initialize [ 

	super initialize.
	actions := OrderedCollection new
]

{ #category : 'testing' }
CallHistory >> isEmpty [
	
	^ actions isEmpty 
]

{ #category : 'adding' }
CallHistory >> pop: method [

	actions add: { 'pop' . method }
]

{ #category : 'adding' }
CallHistory >> push: method [

	actions add: { 'push' . method }
]
