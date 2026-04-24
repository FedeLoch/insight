Class {
	#name : 'IGCoverageMock',
	#superclass : 'Object',
	#category : 'IG-CodeCov-IG-CodeCoverageTest',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverageTest'
}

{ #category : 'dummy methods' }
IGCoverageMock >> callSubMethod [

	self oneStatement.
	self twoStatements
]

{ #category : 'dummy methods' }
IGCoverageMock >> conditionalMethodAAA: aBoolean [

	^aBoolean ifTrue: [ 67 ]
		 ifFalse: [ 42 ]
]

{ #category : 'dummy methods' }
IGCoverageMock >> emptyMethod [
]

{ #category : 'dummy methods' }
IGCoverageMock >> oneStatement [

	^42
]

{ #category : 'dummy methods' }
IGCoverageMock >> twoStatements [

	| x |

	x := 1.
	^x + 1
]
