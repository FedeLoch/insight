Class {
	#name : 'IGInstrumentation',
	#superclass : 'Object',
	#instVars : [
		'hooks',
		'oldMethod',
		'newMethod'
	],
	#category : 'Insight-Instrumentation',
	#package : 'Insight',
	#tag : 'Instrumentation'
}

{ #category : 'initialization' }
IGInstrumentation >> addHook: aHook [

	hooks add: aHook 
]

{ #category : 'initialization' }
IGInstrumentation >> initialize [ 
	
	super initialize.
	hooks := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> instrument: method [ 
	
	| ast |
	
	oldMethod := method.

	ast := (hooks inject: method ast copy into: [ :ast :hook |
		hook install: ast
	]).

	newMethod := method methodClass compiler ast: ast; compile.
	
	"TODO: refactor me, please"
	method methodClass methodDict at: newMethod selector put: newMethod.
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> instrument: method during: blockToEval [

	self instrument: method.
	
	^ blockToEval ensure: [ self uninstrument: method ].
	
	 
	
	
]

{ #category : 'as yet unclassified' }
IGInstrumentation >> uninstrument: method [

	method methodClass methodDict at: method selector put: method
]
