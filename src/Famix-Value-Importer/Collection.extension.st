Extension { #name : 'Collection' }

{ #category : '*Famix-Value-Importer' }
Collection >> asJavaJacksonValueOn: importer [
	"List values are serialized as an array containing [1] the type name and [2] the array of elements.
	There's also the issue that Jackson <2.12 does array wrapping as a fallback with `JsonTypeInfo.As.PROPERTY`.
	This can lead to unexpected wrappers when it can also be a regular list, so we need to differentiate.
	The real solution is to only depend on `As.WRAPPER_ARRAY`, that should have been the choice from the start."

	| type |
	type := (self size = 2 and: [ (self at: 1) isString ]) ifTrue: [ "Maybe TypeInfo"
		        importer entityFinder findTypeNamed: (self at: 1) ].
	type
		ifNotNil: [ "Confirmed TypeInfo"
			^ importer importValueFromList: (self at: 2) of: type ]
		ifNil: [
			self hasJavaJacksonTypeInformation ifTrue: [ "Was TypeInfo but could not find type in model"
				self error: 'Type not in code model: ' , (self at: 1) ].
			type := importer loadType ].

	"Can be a class reference"
	type mooseName = 'java.lang.Class' ifTrue: [
		^ importer importTypeReference: (self at: 2) of: type ].

	"Can be an enumeration value"
	(type usesFamixTrait: FamixTEnum) ifTrue: [
		^ importer importEnumValue: (self at: 2) of: type ].

	"Can be a special object"
	(importer importSpecialObject: (self at: 2) of: type) ifNotNil: [
		:value | ^ value ].

	type isPrimitiveType ifTrue: [ "An array of primitives"
		self shouldBeImplemented ].

	"Must be a regular list"
	^ importer importValueFromList: self of: type
]

{ #category : '*Famix-Value-Importer' }
Collection >> asPharoJacksonValueOn: importer [

	^ importer
		  importArray: self
		  of: (importer loadTypeNamed: self className)
]

{ #category : '*Famix-Value-Importer' }
Collection >> asPharoSTONValueOn: importer [

	^ importer
		  importCollection: self
		  of: (importer loadTypeNamed: self className)
]

{ #category : '*Famix-Value-Importer' }
Collection >> hasJavaJacksonTypeInformation [

	^ self size = 2 and: [
		  (self at: 1) ifNil: [ false ] ifNotNil: [ :first |
			  first isString and: [
				  first isNotEmpty and: [
					  (self at: 2)
						  ifNil: [ false ]
						  ifNotNil: [ :second | second isString not ] ] ] ] ]
]
