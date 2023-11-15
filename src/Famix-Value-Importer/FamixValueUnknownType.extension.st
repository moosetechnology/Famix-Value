Extension { #name : #FamixValueUnknownType }

{ #category : #'*Famix-Value-Importer' }
FamixValueUnknownType >> searchAttributeNamed: attributeName [

	Warning signal:
		'Trying to find attribute `' , attributeName , '` in unknown type `'
		, name , '`.'.
	^ nil
]
