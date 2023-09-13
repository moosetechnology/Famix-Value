Extension { #name : #Boolean }

{ #category : #'*Famix-Value-Importer' }
Boolean >> asJavaJacksonValueOn: importer [

	^ importer importPrimitive: self of: 'boolean'
]

{ #category : #'*Famix-Value-Importer' }
Boolean >> asPharoSTONValueOn: importer [

	^ importer importPrimitive: self of: self className
]
