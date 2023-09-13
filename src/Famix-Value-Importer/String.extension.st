Extension { #name : #String }

{ #category : #'*Famix-Value-Importer' }
String >> asJavaJacksonValueOn: importer [

	^ importer importPrimitive: self of: 'java.lang.String'
]
