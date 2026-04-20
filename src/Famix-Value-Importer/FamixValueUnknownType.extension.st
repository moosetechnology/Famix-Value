Extension { #name : 'FamixValueUnknownType' }

{ #category : '*Famix-Value-Importer' }
FamixValueUnknownType >> findAttributeNamed: attributeName [

	Warning signal:
		'Trying to find attribute `' , attributeName , '` in unknown type `'
		, name , '`.'.
	^ nil
]
