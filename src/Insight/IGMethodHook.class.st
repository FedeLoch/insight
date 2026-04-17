Class {
	#name : 'IGMethodHook',
	#superclass : 'IGHook',
	#category : 'Insight-Hooks',
	#package : 'Insight',
	#tag : 'Hooks'
}

{ #category : 'actions' }
IGMethodHook >> acceptsNode: node [

	^ node isMethod
]
