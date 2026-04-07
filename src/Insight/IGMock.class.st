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

{ #category : 'accessing' }
IGMock >> initialize [ 

	super initialize.
	variable1 := 0.
	variable2 := 0.
]

{ #category : 'accessing' }
IGMock >> variable1: var [

	variable1 := variable2 := var.
]

{ #category : 'accessing' }
IGMock >> variable2: var [

	variable2 := var
]
