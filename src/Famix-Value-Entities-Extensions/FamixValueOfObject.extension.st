Extension { #name : #FamixValueOfObject }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfObject >> printValueOn: aStream [

	aStream << ${.
	self value
		do: [ :attribute | attribute printValueOn: aStream ]
		separatedBy: [ aStream << $, ].
	aStream << $}
]
