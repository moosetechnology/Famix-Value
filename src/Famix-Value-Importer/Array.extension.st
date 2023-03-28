Extension { #name : #Array }

{ #category : #'*Famix-Value-Importer' }
Array >> asJavaJacksonValueOn: importer [

	^ importer
		  importValueFromList: (self at: 2)
		  of:
		  (importer typeInference ifNil: [ 
			   importer loadTypeNamed: (self at: 1) ])
]
