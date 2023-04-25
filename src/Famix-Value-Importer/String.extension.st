Extension { #name : #String }

{ #category : #'*Famix-Value-Importer' }
String >> asJavaJacksonValueOn: importer [

	^ importer model newOfPrimitiveType
		  value: self;
		  type: (importer loadTypeNamed: 'java.lang.String')
]
