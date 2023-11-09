Extension { #name : #Text }

{ #category : #'*Famix-Value-Importer' }
Text >> asPharoSTONValueOn: importer [

	^ importer
		  importObject: self
		  of: (importer loadTypeNamed: self className)
]
