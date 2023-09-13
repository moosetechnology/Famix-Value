Extension { #name : #Float }

{ #category : #'*Famix-Value-Importer' }
Float >> asJavaJacksonValueOn: importer [

	^ importer importPrimitive: self of: 'double'
]
