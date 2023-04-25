Extension { #name : #UndefinedObject }

{ #category : #'*Famix-Value-Importer' }
UndefinedObject >> asJavaJacksonValueOn: importer [

	^ importer model newOfUnknownType
		  value: self;
		  type:
			  (importer typeInference ifNil: [ importer getDefaultUnknownType ])
]
