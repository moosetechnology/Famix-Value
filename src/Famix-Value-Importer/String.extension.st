Extension { #name : #String }

{ #category : #'*Famix-Value-Importer' }
String >> asJavaJacksonValueOn: importer [

	^ importer newValueOfPrimitiveType
		  value: self;
		  type: (importer findTypeNamed: 'java.lang.String')
]
