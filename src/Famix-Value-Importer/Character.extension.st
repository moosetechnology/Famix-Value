Extension { #name : 'Character' }

{ #category : '*Famix-Value-Importer' }
Character >> asPharoJacksonValueOn: importer [

	^ importer importPrimitive: self of: self className
]

{ #category : '*Famix-Value-Importer' }
Character >> asPharoSTONValueOn: importer [

	^ importer importPrimitive: self of: self className
]
