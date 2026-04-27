Class {
	#name : 'IGMethodCoverageRecord',
	#superclass : 'Object',
	#instVars : [
		'method',
		'statementCounters'
	],
	#category : 'IG-CodeCov-IG-CodeCoverage',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverage'
}

{ #category : 'instance creation' }
IGMethodCoverageRecord class >> for: aMethod statementCounters: aDictionary [

	^self new
		 method: aMethod; statementCounters: aDictionary; yourself
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> executedStatements [

	^statementCounters select: [ :eachCounter | eachCounter > 0 ]
]

{ #category : 'querying' }
IGMethodCoverageRecord >> executionCountFor: aStatementNode [

	^statementCounters at: aStatementNode
		 ifAbsent: [
				 self error:
					 ('This node {1} is not a statement of the method {2}.' format:
						  {
							  aStatementNode printString.
							  method printString })
				 ]
]

{ #category : 'querying' }
IGMethodCoverageRecord >> isCovered [

	^self numberOfExecutedStatements = self numberOfStatements
]

{ #category : 'querying' }
IGMethodCoverageRecord >> isPartiallyCovered [

	^self numberOfExecutedStatements > 0 and: [ self numberOfNonExecutedStatements > 0 ]
]

{ #category : 'querying' }
IGMethodCoverageRecord >> isUncovered [

	^self numberOfExecutedStatements = 0
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> method [

	^method
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> method: aMethod [

	method := aMethod
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> nonExecutedStatements [

	^statementCounters select: [ :eachCounter | eachCounter = 0 ]
]

{ #category : 'querying' }
IGMethodCoverageRecord >> numberOfExecutedStatements [

	^self executedStatements size
]

{ #category : 'querying' }
IGMethodCoverageRecord >> numberOfNonExecutedStatements [

	^self nonExecutedStatements size
]

{ #category : 'querying' }
IGMethodCoverageRecord >> numberOfStatements [

	^statementCounters size
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> statementCounters [

	^statementCounters
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> statementCounters: aCollectionOfStatementCounters [

	statementCounters := aCollectionOfStatementCounters
]
