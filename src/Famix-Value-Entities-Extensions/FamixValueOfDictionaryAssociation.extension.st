Extension { #name : #FamixValueOfDictionaryAssociation }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfDictionaryAssociation >> mooseNameOn: aStream [

	aStream << (key ifNotNil: [ key type name ] ifNil: [ '<keyType>' ])
	<< $(.
	self key printValueOn: aStream.
	aStream << ')->'
	<< (value ifNotNil: [ value type name ] ifNil: [ '<valueType>' ])
	<< $(.
	self value printValueOn: aStream.
	aStream nextPut: $)
]
