Class {
	#name : 'IGMethodCoverageRecord',
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
IGMethodCoverageRecord class >> for: aMethod executedStatements: aDictionary [

	^self new
		 method: aMethod; executedStatements: aDictionary; yourself
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> executedStatements [

	^executedStatements
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> executedStatements: aCollectionOfStatementNodes [

	executedStatements := aCollectionOfStatementNodes
]

{ #category : 'querying' }
IGMethodCoverageRecord >> executionCountFor: aStatementNode [

	^executedStatements at: aStatementNode
		 ifAbsent: [
				 self error:
					 ('This node {1} is not a statement of the method {2}.' format:
						  {
							  aStatementNode printString.
							  method printString })
				 ]
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> method [

	^method
]

{ #category : 'accessing' }
IGMethodCoverageRecord >> method: aMethod [

	method := aMethod
]

{ #category : 'querying' }
IGMethodCoverageRecord >> numberOfExecutedStatements [

	^(executedStatements values select: [ :eachValue | eachValue > 0 ])
		 size
]

{ #category : 'querying' }
IGMethodCoverageRecord >> numberOfStatements [

	^executedStatements size
]
