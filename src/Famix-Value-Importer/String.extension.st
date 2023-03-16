Extension { #name : #String }

{ #category : #'*Famix-Value-Importer' }
String >> asJavaJacksonValueOn: importer [

	^ importer newValueOfPrimitiveType
		  value: self;
		  type: (importer loadTypeNamed: 'java.lang.String')
]
