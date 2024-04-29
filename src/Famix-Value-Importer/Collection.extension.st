Extension { #name : #Collection }

{ #category : #'*Famix-Value-Importer' }
Collection >> asJavaJacksonValueOn: importer [
	"List values are serialized as an array containing [1] the type name and [2] the array of elements."

	| type |
	type := importer entityFinder findTypeNamed: (self at: 1).

	"might be an evident Jackson TypeInfo wrapper"
	self hasJavaJacksonTypeInformation ifTrue: [
		^ importer importValueFromList: (self at: 2) of: type ].

	"might be an enumeration value"
	(type usesFamixTrait: FamixTEnum) ifTrue: [
		^ importer importEnumValue: (self at: 2) of: type ].

	"might be a special object"
	(importer importSpecialObject: (self at: 2) of: type) ifNotNil: [
		:value | ^ value ].

	"must be a regular list"
	^ importer importValueFromList: self of: importer loadType
]

{ #category : #'*Famix-Value-Importer' }
Collection >> asPharoJacksonValueOn: importer [

	^ importer
		  importCollection: self
		  of: (importer loadTypeNamed: self className)
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
