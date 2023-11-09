Extension { #name : #FamixValueOfPrimitiveType }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfPrimitiveType >> printValueOn: aStream [

	aStream nextPutAll: (value printStringLimitedTo: 50)
]
