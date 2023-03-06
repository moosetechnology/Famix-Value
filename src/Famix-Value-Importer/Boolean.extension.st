Extension { #name : #Boolean }

{ #category : #'*Famix-Value-Importer' }
Boolean >> asJavaJacksonValueOn: importer [

	^ importer newValueOfPrimitiveType
		  value: self;
		  type: (importer findTypeNamed: 'boolean')
]
