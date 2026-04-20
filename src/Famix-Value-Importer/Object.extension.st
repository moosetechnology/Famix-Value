Extension { #name : 'Object' }

{ #category : '*Famix-Value-Importer' }
Object >> asPharoJacksonValueOn: importer [

	^ importer
		  importObject: self
		  of: (importer loadTypeNamed: self className)
]

{ #category : '*Famix-Value-Importer' }
Object >> asPharoSTONValueOn: importer [

	^ importer
		  importObject: self
		  of: (importer loadTypeNamed: self className)
]
