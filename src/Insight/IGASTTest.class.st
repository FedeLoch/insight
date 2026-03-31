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
