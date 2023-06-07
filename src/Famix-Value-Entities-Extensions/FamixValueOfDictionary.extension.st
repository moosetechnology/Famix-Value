Extension { #name : #FamixValueOfDictionary }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfDictionary >> printValueOn: aStream [

	aStream << ${ << self value size asString << ' association'.
	self value size = 1 ifFalse: [ aStream nextPut: $s ].
	aStream nextPut: $}
]
