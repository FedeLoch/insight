Class {
	#name : 'BaselineOfInsight',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfInsight',
	#package : 'BaselineOfInsight'
}

{ #category : 'baselines' }
BaselineOfInsight >> baseline: spec [

	<baseline>
	
	spec baseline: 'IllimaniProfiler' with: [ spec repository: 'github://jordanmontt/illimani-memory-profiler:main' ].
	
	spec package: 'Insight' with: [ spec requires: #( 'IllimaniProfiler' ) ]
]
