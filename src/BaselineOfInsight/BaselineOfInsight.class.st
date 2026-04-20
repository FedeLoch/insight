Class {
	#name : 'BaselineOfInsight',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfInsight',
	#package : 'BaselineOfInsight'
}

{ #category : 'baselines' }
BaselineOfInsight >> baseline: spec [

	<baseline>
	
	spec baseline: 'MethodCallGraph' with: [ spec repository: 'github://jordanmontt/MethodCallGraph:main' ].
	
	spec package: 'Insight' with: [ spec requires: #( 'MethodCallGraph' ) ]
]
