Extension { #name : #FamixValueOfObject }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfObject >> printValueOn: aStream [

	aStream << ${.
	self value
		do: [ :attribute | attribute value printValueOn: aStream ]
		separatedBy: [ aStream << $, ].
	aStream << $}
]
