Extension { #name : #FamixValueOfDictionaryAssociation }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfDictionaryAssociation >> mooseNameOn: aStream [

	aStream << self key type name << $(.
	self key value printOn: aStream.
	aStream << ')->' << self value type name << $(.
	self value value printOn: aStream.
	aStream << $)
]
