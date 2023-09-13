Extension { #name : #Boolean }

{ #category : #'*Famix-Value-Importer' }
Boolean >> asJavaJacksonValueOn: importer [

	^ importer importPrimitive: self of: 'boolean'
]
