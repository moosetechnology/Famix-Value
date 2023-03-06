Extension { #name : #Integer }

{ #category : #'*Famix-Value-Importer' }
Integer >> asJavaJacksonValueOn: importer [

	^ importer newValueOfPrimitiveType
		  value: self;
		  type: (importer findTypeNamed: 'int')
]
