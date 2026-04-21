Class {
	#name : 'IGMethodCoverage',
	#superclass : 'Object',
	#instVars : [
		'method',
		'executedStatements'
	],
	#category : 'IG-CodeCov-IG-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverage'
}

{ #category : 'instance creation' }
IGMethodCoverage class >> method: aMethod executedStatements: aDictionary [

	^self new
		 method: aMethod; executedStatements: aDictionary; yourself
]

{ #category : 'accessing' }
IGMethodCoverage >> executedStatements [

	^executedStatements
]

{ #category : 'accessing' }
IGMethodCoverage >> executedStatements: aDictionnary [

	executedStatements := aDictionnary
]

{ #category : 'querying' }
IGMethodCoverage >> executionCountFor: aNode [

	^executedStatements at: aNode
		 ifAbsent: [ 0 ]
]

{ #category : 'initialization' }
IGMethodCoverage >> initialize [

	super initialize.
	executedStatements := IdentityDictionary new
]

{ #category : 'accessing' }
IGMethodCoverage >> method [

	^method
]

{ #category : 'accessing' }
IGMethodCoverage >> method: aMethod [

	method := aMethod
]
