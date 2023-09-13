Extension { #name : #Object }

{ #category : #'*Famix-Value-Importer' }
Object >> asPharoSTONValueOn: importer [

	^ importer
		  importObject: self
		  of: (importer loadTypeNamed: self className)
]
