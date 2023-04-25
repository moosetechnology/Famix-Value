Extension { #name : #Boolean }

{ #category : #'*Famix-Value-Importer' }
Boolean >> asJavaJacksonValueOn: importer [

	^ importer model newOfPrimitiveType
		  value: self;
		  type: (importer loadTypeNamed: 'boolean')
]
