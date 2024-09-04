Extension { #name : 'FamixValueOfCollectionElement' }

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfCollectionElement >> mooseNameOn: aStream [

	aStream nextPut: $[.
	self value mooseNameOn: aStream.
	aStream nextPut: $]
]
