Extension { #name : #Number }

{ #category : #'*Famix-Value-Importer' }
Number >> asPharoJacksonValueOn: importer [

	^ importer importPrimitive: self of: self className
]

{ #category : #'*Famix-Value-Importer' }
Number >> asPharoSTONValueOn: importer [

	^ importer importPrimitive: self of: self className
]
