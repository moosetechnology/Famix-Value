Extension { #name : #Association }

{ #category : #'*Famix-Value-Importer' }
Association >> asPharoJacksonValueOn: importer [

	^ importer importAssociation: self
]

{ #category : #'*Famix-Value-Importer' }
Association >> asPharoSTONValueOn: importer [

	^ importer model newOfDictionaryAssociation
		  key: (importer importValue: key);
		  value: (importer importValue: value)
]
