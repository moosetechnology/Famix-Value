Extension { #name : #FamixValueOfCollectionElement }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfCollectionElement >> mooseNameOn: aStream [

	aStream << $[.
	self value mooseNameOn: aStream.
	aStream << $]
]
