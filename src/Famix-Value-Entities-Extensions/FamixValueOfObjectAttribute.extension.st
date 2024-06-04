Extension { #name : #FamixValueOfObjectAttribute }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfObjectAttribute >> mooseNameOn: aStream [

	value printTypeOn: aStream.
	aStream << ' ' << (self attribute
		 ifNotNil: [ :attribute | attribute name ]
		 ifNil: [ '<attribute>' ]) << $=.
	value printValueOn: aStream
]
