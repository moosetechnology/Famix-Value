Extension { #name : 'FamixValueOfObject' }

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfObject >> containsCollection [

	^ value anySatisfy: [ :attribute |
		  attribute value containsCollection ]
]

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfObject >> containsObject [

	^ true
]

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfObject >> printValueOn: aStream [

	aStream << ${ << self value size asString << ' attribute'.
	self value size = 1 ifFalse: [ aStream nextPut: $s ].
	aStream nextPut: $}
]

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfObject >> relevantAttributes [

	^ value reject: [ :attribute |
		  attribute attribute isNil or: [ attribute attribute isStub ] ]
]
