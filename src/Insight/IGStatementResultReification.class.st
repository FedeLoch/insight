Class {
	#name : 'IGStatementResultReification',
	#superclass : 'Object',
	#instVars : [
		'tempVarName'
	],
	#category : 'Insight-Context',
	#package : 'Insight',
	#tag : 'Context'
}

{ #category : 'initialization' }
IGStatementResultReification >> initialize [

	super initialize.
	tempVarName := #______statementResult______
]

{ #category : 'accessing' }
IGStatementResultReification >> nodeToReify [

	^ OCVariableNode named: tempVarName
]

{ #category : 'as yet unclassified' }
IGStatementResultReification >> rewriteOperationsForNode: anOCMessageNode [

	^ {
		  (IGWrapStatement with: (OCAssignmentNode
				    variable: (OCVariableNode named: tempVarName)
				    value: anOCMessageNode copy)).
		  (IGAddNewTemp with: (OCVariableNode named: tempVarName)) }
]
