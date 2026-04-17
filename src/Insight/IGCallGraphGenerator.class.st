Class {
	#name : 'IGCallGraphGenerator',
	#superclass : 'Object',
	#category : 'Insight-Call Graph',
	#package : 'Insight',
	#tag : 'Call Graph'
}

{ #category : 'as yet unclassified' }
IGCallGraphGenerator class >> callGraph: aClass On: aBlock [

	| instrumentation history |
	
	history := CallHistory new.

	"IGAction do: [ :context | history push: context astNode ].
	afterAction := IGAction do: [ :context | history pop: context astNode ].
"
	instrumentation := IGInstrumentation new addHooks: {
		IGBeforeMethodHook new do: (BeforeHistoryAction history: history).
		IGAfterMethodHook new do: (AfterHistoryAction history: history)
	}; instrumentClass: aClass during: aBlock.
	
	^ AllocationGraph from: history
]
