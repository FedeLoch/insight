Class {
	#name : 'BaselineOfInsight',
	#superclass : 'BaselineOf',
	#package : 'BaselineOfInsight'
}

{ #category : 'baselines' }
BaselineOfInsight >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec package: #Insight ]
]
