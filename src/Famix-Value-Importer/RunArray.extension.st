Extension { #name : 'RunArray' }

{ #category : '*Famix-Value-Importer' }
RunArray >> asPharoJacksonValueOn: importer [

	^ importer
		  importObject: self
		  of: (importer loadTypeNamed: self className)
]

{ #category : '*Famix-Value-Importer' }
RunArray >> asPharoSTONValueOn: importer [

	^ importer
		  importObject: self
		  of: (importer loadTypeNamed: self className)
]
