Extension { #name : #Association }

{ #category : #'*Famix-Value-Importer' }
Association >> asPharoSTONValueOn: importer [

	^ importer model newOfDictionaryAssociation
		  key: (importer importValue: key);
		  value: (importer importValue: value)
]
