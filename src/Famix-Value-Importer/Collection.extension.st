Extension { #name : #Collection }

{ #category : #'*Famix-Value-Importer' }
Collection >> asJavaJacksonValueOn: importer [
	"List values are serialized as an array containing [1] the type name and [2] the array of elements."

	^ self hasJavaJacksonTypeInformation
		  ifTrue: [
			  importer
				  importValueFromList: (self at: 2)
				  of: (importer loadTypeNamed: (self at: 1)) ]
		  ifFalse: [
		  importer importValueFromList: self of: importer loadType ]
]

{ #category : #'*Famix-Value-Importer' }
Collection >> asPharoSTONValueOn: importer [

	^ importer
		  importCollection: self
		  of: (importer loadTypeNamed: self className)
]

{ #category : #'*Famix-Value-Importer' }
Collection >> hasJavaJacksonTypeInformation [

	^ self size = 2 and: [
		  (self at: 1) isString and: [ (self at: 2) isString not ] ]
]
