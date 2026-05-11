Class {
	#name : 'TimeTravelerTest',
	#superclass : 'TestCase',
	#category : 'Insight-Time Traveling',
	#package : 'Insight',
	#tag : 'Time Traveling'
}

{ #category : 'tests' }
TimeTravelerTest >> testCreatingTimeTravelerOfAnEmptyExecution [

	| traveler |

	traveler := IGTimeTraveler record: [] forClass: IGMock.

	self assert: (traveler events size) equals: 0
]

{ #category : 'tests' }
TimeTravelerTest >> testCreatingTimeTravelerOfaSelfMessageCalling [

	| traveler instance |
	
	instance := IGMock new.

	traveler := IGTimeTraveler record: [ instance messageA: '42' ] forClass: IGMock.

	self assert: (traveler events size) equals: 3
]
