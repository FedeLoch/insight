Extension { #name : 'MethodCallGraphProfiler' }

{ #category : '*Insight' }
MethodCallGraphProfiler class >> from: callHistory [

	| graph |

	graph := self new.

	callHistory actions do: [ :action |
			action isPush
				ifTrue: [ graph enteringMethod: action method ]
				ifFalse: [ graph exitingMethod ] ].

	^ graph
]
