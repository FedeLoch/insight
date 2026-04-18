Class {
	#name : 'IGMock',
	#superclass : 'Object',
	#instVars : [
		'variable1',
		'variable2'
	],
	#category : 'Insight-Tests',
	#package : 'Insight',
	#tag : 'Tests'
}

{ #category : 'helper methods' }
IGMock >> emptyMethod [
]

{ #category : 'accessing' }
IGMock >> initialize [ 

	super initialize.
	variable1 := 0.
	variable2 := 0.
]

{ #category : 'helper methods' }
IGMock >> messageA: argument [

	self messageB: argument
]

{ #category : 'helper methods' }
IGMock >> messageB: argument [

	^ self yourself 
]

{ #category : 'accessing' }
IGMock >> variable1: var [

	variable1 := variable2 := var.
]

{ #category : 'accessing' }
IGMock >> variable2: var [

	variable2 := var
]
