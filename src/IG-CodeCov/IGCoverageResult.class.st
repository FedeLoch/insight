"
Coverage object that exposes method coverage percentages as well as how many of them were fully covered.
"
Class {
	#name : 'IGCoverageResult',
	#superclass : 'Object',
	#instVars : [
		'methodRecordDictionary'
	],
	#category : 'IG-CodeCov-IG-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverage'
}

{ #category : 'adding' }
IGCoverageResult >> addRecord: anIGMethodCoverageRecord [

	methodRecordDictionary at: anIGMethodCoverageRecord method
		put: anIGMethodCoverageRecord
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

	^methodRecordDictionary isEmpty
]

{ #category : 'accessing' }
IGCoverageResult >> methodRecordDictionary [

    ^ methodRecordDictionary
]

{ #category : 'querying' }
IGCoverageResult >> numberOfRecordedMethods [

    ^ methodRecordDictionary size
]

{ #category : 'accessing' }
IGCoverageResult >> recordFor: aMethod [
	"Raise an error if the method isn't present"

	^methodRecordDictionary at: aMethod
		 ifAbsent: [
				 self error:
					 ('Method {1} is not present.' format: { aMethod printString })
				 ]
]
