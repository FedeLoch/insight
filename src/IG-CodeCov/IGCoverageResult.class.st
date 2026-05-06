"
Coverage object that exposes method coverage percentages as well as how many of them were fully covered.
"
Class {
	#name : 'IGCoverageResult',
	#superclass : 'Object',
	#instVars : [
		'methodRecordDictionary'
	],
	#category : 'IG-CodeCov-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'CodeCoverage'
}

{ #category : 'adding' }
IGCoverageResult >> addRecord: anIGMethodCoverageRecord [

	methodRecordDictionary at: anIGMethodCoverageRecord method
		put: anIGMethodCoverageRecord
]

{ #category : 'querying' }
IGCoverageResult >> coverageFor: aMethod [
	"Empty methods (no statements) report 0% coverage to avoid 0/0"

	| methodRecord |

	methodRecord := self recordFor: aMethod.
	methodRecord numberOfStatements = 0 ifTrue: [ ^ 0.0 ].
	^ (methodRecord numberOfExecutedStatements / methodRecord numberOfStatements * 100)
		  asFloat
]

{ #category : 'coverage' }
IGCoverageResult >> fullyCoveredMethods [

	^ (self getMethodsFromPredicate: #isCovered) values
]

{ #category : 'percentages' }
IGCoverageResult >> fullyCoveredPercentage [

	^ ((self getMethodsFromPredicate: #isCovered) size / methodRecordDictionary size * 100)
		  asFloat
]

{ #category : 'private' }
IGCoverageResult >> getMethodsFromPredicate: aPredicate [

	^ methodRecordDictionary select: aPredicate
]

{ #category : 'initialization' }
IGCoverageResult >> initialize [

	super initialize.
	"The key is the method, not its symbol.
    This allows method of the same name to be recorded separately."
	methodRecordDictionary := IdentityDictionary new
]

{ #category : 'querying' }
IGCoverageResult >> isEmpty [

	^ methodRecordDictionary isEmpty
]

{ #category : 'querying' }
IGCoverageResult >> numberOfRecordedMethod [

	^ methodRecordDictionary size
]

{ #category : 'coverage' }
IGCoverageResult >> partiallyCoveredMethods [

	^ (self getMethodsFromPredicate: #isPartiallyCovered) values
]

{ #category : 'percentages' }
IGCoverageResult >> partiallyCoveredPercentage [

	^ ((self getMethodsFromPredicate: #isPartiallyCovered) size / methodRecordDictionary size
	   * 100) asFloat
]

{ #category : 'accessing' }
IGCoverageResult >> recordFor: aMethod [
	"Raise an error if the method isn't present"

	^ methodRecordDictionary at: aMethod
		  ifAbsent: [
		  self error: ('Method {1} is not present.' format: { aMethod printString }) ]
]

{ #category : 'accessing' }
IGCoverageResult >> recordedMethodCollection [

	^ methodRecordDictionary
]

{ #category : 'coverage' }
IGCoverageResult >> uncoveredMethods [

	^ (self getMethodsFromPredicate: #isUncovered) values
]

{ #category : 'percentages' }
IGCoverageResult >> uncoveredPercentage [

	^ ((self getMethodsFromPredicate: #isUncovered) size / methodRecordDictionary size * 100)
		  asFloat
]
