Extension { #name : #UndefinedObject }

{ #category : #'*Famix-Value-Importer' }
UndefinedObject >> asJavaJacksonValueOn: importer [

	^ importer newValueOfUnknownType
		  value: self;
		  type: importer getAnonymousUnknownType
]
