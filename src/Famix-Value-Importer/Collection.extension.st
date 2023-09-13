Extension { #name : #Collection }

{ #category : #'*Famix-Value-Importer' }
Collection >> asJavaJacksonValueOn: importer [

	"List values are deserialized as an array containing [1] the type name and [2] the array of elements."

	^ importer
		  importValueFromList: (self at: 2)
		  of: (importer loadTypeNamed: (self at: 1))
]

{ #category : #'*Famix-Value-Importer' }
Collection >> asPharoSTONValueOn: importer [

	^ importer
		  importCollection: self
		  of: (importer loadTypeNamed: self className)
]
