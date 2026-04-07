BaselineOf subclass: #BaselineOfInsight
	slots: { }
	classVariables: { }
	package: 'BaselineOfInsight'

BaselineOfInsight class >> baseline: spec
	<baseline>
	spec
		for: #pharo
		do: [ 
			spec package: 'Insight' with: [ spec repository: 'tonel://./src' ].
			spec group: 'default' with: #('Insight') ]
