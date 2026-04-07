Class {
	#name : 'IGASTTest',
	#superclass : 'TestCase',
	#category : 'Insight-Tests',
	#package : 'Insight',
	#tag : 'Tests'
}

{ #category : 'tests' }
IGASTTest >> testAssignmentNodeToList [

	| assignment1 assignment2 |
	
	assignment2 := OCAssignmentNode variable: (OCVariableNode named: 'var2') value: (OCLiteralNode value: 8).
	
	assignment1 := OCAssignmentNode variable: (OCVariableNode named: 'var1') value: assignment2.
	
	self assertCollection: assignment1 igAssignmentNodes equals: { assignment2 . assignment1 }
	

]

{ #category : 'tests' }
IGASTTest >> testAssignmentNodeToList1 [

	| assignment1 |
	
	assignment1 := OCAssignmentNode variable: (OCVariableNode named: 'var2') value: (OCLiteralNode value: 8).

	self assertCollection: assignment1 igAssignmentNodes equals: { assignment1 }
	

]

{ #category : 'tests' }
IGASTTest >> testFlattenedNodesAssignment1 [

	| assignment1 |

	"var2 := 8"	
	assignment1 := OCAssignmentNode variable: (OCVariableNode named: 'var2') value: (OCLiteralNode value: 8).

	self assertCollection: assignment1 flattenedNodes equals: { assignment1 }
	

]

{ #category : 'tests' }
IGASTTest >> testFlattenedNodesAssignment2 [

	"todo: refactor me please or I will die"
	| assignment1 assignment2 flattenedNode |
	
	assignment2 := OCAssignmentNode variable: (OCVariableNode named: 'var2') value: (OCLiteralNode value: 8).
	
	assignment1 := OCAssignmentNode variable: (OCVariableNode named: 'var1') value: assignment2.
	
	flattenedNode := OCAssignmentNode variable: (OCVariableNode named: 'var1') value: (OCVariableNode named: 'var2').

	self assertCollection: assignment1 flattenedNodes equals: { assignment2 . flattenedNode }
]

{ #category : 'tests' }
IGASTTest >> testFlattenedNodesAssignment3 [

	| assignment1 innerNode flattenedNode1 flattenedNode2 |
	
	assignment1 := OCParser parseExpression: 'var1 := var2 := var3 := 8'.
	
	innerNode := OCParser parseExpression: 'var3 := 8'.
	flattenedNode1 := OCParser parseExpression: 'var1 := var2'.
	flattenedNode2 := OCParser parseExpression: 'var2 := var3'.
	
	self assertCollection: assignment1 flattenedNodes equals: { innerNode . flattenedNode2 . flattenedNode1 }
]

{ #category : 'tests' }
IGASTTest >> testFlattenedNodesAssignmentInArguments [

	| assignment1 innerNode flattenedNode1 |
	
	assignment1 := OCParser parseExpression: 'a msg: (b := 7)'.
	
	innerNode := OCParser parseExpression: 'b := 7'.
	flattenedNode1 := OCParser parseExpression: 'a msg: b'.
	
	self assertCollection: assignment1 flattenedNodes equals: { innerNode . flattenedNode1 }
]

{ #category : 'tests' }
IGASTTest >> testFlattenedNodesAssignmentInReceiver [

	| assignment1 innerNode flattenedNode1 |
	
	assignment1 := OCParser parseExpression: '(a := 42) msg: 7'.
	
	innerNode := OCParser parseExpression: 'a := 42'.
	
	flattenedNode1 := OCParser parseExpression: 'a msg: 7'.
	
	self assertCollection: assignment1 flattenedNodes equals: { innerNode . flattenedNode1 }
]
