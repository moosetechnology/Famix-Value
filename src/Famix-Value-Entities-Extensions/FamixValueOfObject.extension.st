Extension { #name : #FamixValueOfObject }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfObject >> printValueOn: aStream [

	aStream << ${ << self value size asString << ' attribute'.
	self value size = 1 ifFalse: [ aStream nextPut: $s ].
	aStream nextPut: $}
]
