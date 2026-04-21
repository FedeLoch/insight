Class {
	#name : 'IGCoverageMock',
	#superclass : 'Object',
	#category : 'IG-CodeCov-IG-CodeCoverageTest',
	#package : 'IG-CodeCov',
	#tag : 'IG-CodeCoverageTest'
}

{ #category : 'dummy methods' }
IGCoverageMock >> emptyMethod [

	
]

{ #category : 'initialization' }
IGCoverageMock >> initialize [

	super initialize
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
