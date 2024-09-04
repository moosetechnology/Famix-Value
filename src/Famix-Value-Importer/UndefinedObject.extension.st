Extension { #name : 'UndefinedObject' }

{ #category : '*Famix-Value-Importer' }
UndefinedObject >> asJavaJacksonValueOn: importer [

	^ importer model newOfUnknownType
		  value: self;
		  type:
			  (importer typeInference ifNil: [ importer getDefaultUnknownType ])
]

{ #category : '*Famix-Value-Importer' }
UndefinedObject >> asPharoJacksonValueOn: importer [

	^ importer importPrimitive: self of: self className
]

{ #category : '*Famix-Value-Importer' }
UndefinedObject >> asPharoSTONValueOn: importer [

	^ importer importPrimitive: self of: self className
]
