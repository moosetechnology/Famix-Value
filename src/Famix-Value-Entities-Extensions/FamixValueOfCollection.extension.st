Extension { #name : #FamixValueOfCollection }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfCollection >> printValueOn: aStream [

	aStream << $[ << self value size asString << ' element'.
	self value size = 1 ifFalse: [ aStream nextPut: $s ].
	aStream nextPut: $]
]
