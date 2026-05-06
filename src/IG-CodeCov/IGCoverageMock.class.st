Class {
	#name : 'IGCoverageMock',
	#superclass : 'Object',
	#category : 'IG-CodeCov-CodeCoverageTest',
	#package : 'IG-CodeCov',
	#tag : 'CodeCoverageTest'
}

{ #category : 'dummy methods' }
IGCoverageMock >> callSubMethod [

	self oneStatement.
	self twoStatements
]

{ #category : 'dummy methods' }
IGCoverageMock >> conditionalMethod: aBoolean [

	^ aBoolean ifTrue: [ 67 ]
		  ifFalse: [ 42 ]
]

{ #category : 'dummy methods' }
IGCoverageMock >> emptyMethod [
]

{ #category : 'dummy methods' }
IGCoverageMock >> oneStatement [

	^ 42
]

{ #category : 'dummy methods' }
IGCoverageMock >> twoStatements [

	| x |

	x := 1.
	^ x + 1
]
