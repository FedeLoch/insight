Class {
	#name : 'IGCoverageResultTest',
	#superclass : 'TestCase',
	#category : 'IG-CodeCov-IG-CodeCoverageTest',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverageTest'
}

{ #category : 'tests' }
IGCoverageResultTest >> testMethodCoverageForRaiseWhenMethodNotInScope [

	self should: [ IGCoverageResult new methodCoverageFor: #someMethod ]
		raise: Error
]
