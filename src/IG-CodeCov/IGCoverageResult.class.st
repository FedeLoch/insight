"
Coverage object that can expose the percentages of coverage of methods and has well as how many of them where fully covered.
"
Class {
	#name : 'IGCoverageResult',
	#superclass : 'Object',
	#instVars : [
		'methodCoverages'
	],
	#category : 'IG-CodeCov-IG-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverage'
}

{ #category : 'adding' }
IGCoverageResult >> addMethodCoverage: anIGMethodCoverage [

	methodCoverages at: anIGMethodCoverage method put: anIGMethodCoverage
]

{ #category : 'initialization' }
IGCoverageResult >> initialize [

	super initialize.
	methodCoverages := IdentityDictionary new
]

{ #category : 'accessing' }
IGCoverageResult >> methodCoverageFor: aMethod [
	"Raise an error if the method isn't present"

	^ methodCoverages at: aMethod ifAbsent: [
		self error: ('Method {1} is not present.' format: { aMethod printString }) ]
]

{ #category : 'accessing' }
IGCoverageResult >> methodCoverages [

	^ methodCoverages values
]

{ #category : 'accessing' }
IGCoverageResult >> numberOfMethods [

	^methodCoverages size
]
