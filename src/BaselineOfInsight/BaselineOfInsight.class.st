BaselineOf subclass: #BaselineOfInsight
	slots: { }
	classVariables: { }
	package: 'BaselineOfInsight'

{ #category : 'baselines' }
BaselineOfInsight >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec package: 'Insight' with: [].
			spec group: 'default' with: #( 'Insight' ) ]
]
