Class {
	#name : #FamixValuePharoJacksonImporter,
	#superclass : #FamixValueAbstractImporter,
	#instVars : [
		'typeKey',
		'idKey',
		'refKey',
		'specialTypes'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #importing }
FamixValuePharoJacksonImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: 'Object'
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> getObjectIdentity: rawObject [
	"Keep track of objects by using the id given by Jackson.
	References to previously seen objects are serialized by using this id."

	^ rawObject removeKey: self idKey ifAbsent: nil
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> idKey [

	^ idKey ifNil: [ idKey := '@id' ]
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> idKey: aString [

	idKey := aString
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importAssociation: rawValue of: type [

	| association |
	association := self model newOfDictionaryAssociation type: type.
	objectDict at: (self getObjectIdentity: rawValue) put: association.
	association key: (self importValue: (rawValue at: 'key')).
	association value: (self importValue: (rawValue at: 'value')).
	^ association
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importCharacter: value of: type [

	^ self importPrimitive: (value at: 'value') asCharacter of: type name
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importClassReference: rawValue of: type [
	"The type has already been loaded during the inference.
	The raw value contains the fully qualified name of the referenced class."

	^ self model newOfClassReference
		  value: (self loadTypeNamed: rawValue);
		  type: type
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importCollection: rawValue of: type [

	^ objectDict
		  at: rawValue first
		  ifAbsentPut: [
		  super importCollection: rawValue allButFirst of: type ]
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importDictionary: rawValue of: type [
	"infer from type arguments, e.g. Map<String, MyClass>"

	| dictionary assoc |
	dictionary := self model newOfDictionary type: type.
	objectDict at: (self getObjectIdentity: rawValue) put: dictionary.
	rawValue associationsDo: [ :rawAssoc |
		assoc := self model newOfDictionaryAssociation dictionary:
			         dictionary.
		assoc key: (self importValue: rawAssoc key).
		assoc value: (self importValue: rawAssoc value) ].
	^ dictionary
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importObject: rawObject of: type [


	self specialTypes
		at: type name
		ifPresent: [ :block | ^ block value: rawObject value: type ].
	^ super importObject: rawObject of: type
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importObjectAttribute: rawValue of: type named: name [

	| attribute |
	(attribute := type findAttributeNamed: name).
	^ self
		  withTypeInference:
		  (attribute ifNotNil: [ attribute declaredType ])
		  do: [
			  self model newOfObjectAttribute
				  value: (self importValue: rawValue);
				  attribute: attribute ]
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importSpecialObject: rawValue of: type [
	"Some objects have special rules for serialization.
	They should have a corresponding type wrapper that knows how to handle them."

	self specialTypes
		at: type mooseNameWithDots
		ifPresent: [ :typeWrapper |
			^ typeWrapper import: rawValue wrapping: type on: self ].
	^ nil
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importValue: rawValue [

	^ rawValue asPharoJacksonValueOn: self
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importValueFromList: rawValue of: type [
	"Jackson can serialize different types of values in a list, so we need to find out which it is."

	rawValue isCollection ifTrue: [
		^ self importCollection: rawValue of: type ].
	type isUnknownType ifTrue: [
		^ self model newOfUnknownType
			  value: rawValue;
			  type: type ].
	(type usesFamixTrait: FamixTEnum) ifTrue: [
		^ self importEnumValue: rawValue of: type ].
	(self isPrimitiveType: type) ifTrue: [
		^ self model newOfPrimitiveType
			  value: rawValue;
			  type: type ].
	type isClass ifTrue: [ "might be a special object"
		(self importSpecialObject: rawValue of: type) ifNotNil: [ :object |
			^ object ] ].
	self error: 'Unknown type: ' , type mooseNameWithDots
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> isPrimitiveType: type [

	^ type isPrimitiveType or: [ "Classes wrapping primitives are also considered primitives."
		  type isPrimitiveWrapper ]
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> newReader [

	^ NeoJSONReader new
]

{ #category : #parsing }
FamixValuePharoJacksonImporter >> parseList: serializedValues [
	"Ignore first element which is the id of the array."

	^ (super parseList: serializedValues) allButFirst
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> refKey [

	^ refKey ifNil: [ refKey := '@ref' ]
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> refKey: aString [

	refKey := aString
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> specialTypes [

	^ specialTypes ifNil: [
		  specialTypes := Dictionary new.
		  specialTypes
			  at: 'Character'
			  put: [ :value :type | self importCharacter: value of: type ].
		  specialTypes
			  at: 'Association'
			  put: [ :value :type | self importAssociation: value of: type ].
		  specialTypes
			  at: 'OrderedCollection'
			  put: [ :value :type |
			  self importCollection: (value at: 'array') of: type ].
		  specialTypes
			  at: 'Set'
			  put: [ :value :type |
			  self importCollection: (value at: 'array') of: type ].
		  specialTypes ]
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> typeKey [

	^ typeKey ifNil: [ typeKey := '@type' ]
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> typeKey: aString [

	typeKey := aString
]
