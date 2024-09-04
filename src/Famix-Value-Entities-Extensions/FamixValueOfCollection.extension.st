Extension { #name : 'FamixValueOfCollection' }

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfCollection >> containsCollection [

	^ true
]

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfCollection >> containsObject [

	^ value anySatisfy: [ :element | element value containsObject ]
]

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfCollection >> printValueOn: aStream [

	aStream << $[ << self value size asString << ' element'.
	self value size = 1 ifFalse: [ aStream nextPut: $s ].
	aStream nextPut: $]
]
