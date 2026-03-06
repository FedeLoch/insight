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

	| instrumentedAST originalAST |
	oldMethod := method.

	originalAST := method ast.

	instrumentedAST := hooks
		                   inject: originalAST copy
		                   into: [ :currAST :hook |
		                   hook install: currAST original: originalAST ].

	newMethod := method methodClass compiler
		             ast: instrumentedAST;
		             doSemanticAnalysis;
		             compile.

	"TODO: refactor me, please"
	method methodClass methodDict at: newMethod selector put: newMethod
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
