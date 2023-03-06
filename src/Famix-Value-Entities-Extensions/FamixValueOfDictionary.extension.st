Extension { #name : #FamixValueOfDictionary }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfDictionary >> printValueOn: aStream [

	aStream << ${ << self value size asString << ' association'.
	self value size ~= 1 ifTrue: [ aStream << $s ].
	aStream << $}
]
