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

{ #category : #enumerating }
FamixValuePharoJacksonImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: 'Object'
]

{ #category : #enumerating }
FamixValuePharoJacksonImporter >> getObjectIdentity: rawObject [
	"Keep track of objects by using the id given by Jackson.
	References to previously seen objects are serialized by using this id."

	^ rawObject removeKey: self idKey ifAbsent: nil
]

{ #category : #accessing }
FamixValuePharoJacksonImporter >> idKey [

	^ idKey ifNil: [ idKey := '@id' ]
]

{ #category : #accessing }
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
		  value: (self loadTypeNamed: (rawValue at: 'name'));
		  type: type
]

{ #category : #importing }
FamixValuePharoJacksonImporter >> importClosure: value of: type [

	self flag: #TODO. "handle FullBlockClosure, add FamixValueOfClosure entity with `variables` relation to FamixValueOfType"
	^ self model newOfUnknownType
		  value: value;
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
FamixValuePharoJacksonImporter >> importValue: rawValue [

	^ rawValue asPharoJacksonValueOn: self
]

{ #category : #parsing }
FamixValuePharoJacksonImporter >> parseList: serializedValues [
	"Ignore first element which is the id of the array."

	^ (super parseList: serializedValues) allButFirst
]

{ #category : #accessing }
FamixValuePharoJacksonImporter >> refKey [

	^ refKey ifNil: [ refKey := '@ref' ]
]

{ #category : #accessing }
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
		  specialTypes
			  at: 'FullBlockClosure'
			  put: [ :value :type | self importClosure: value of: type ].
		  specialTypes ]
]

{ #category : #accessing }
FamixValuePharoJacksonImporter >> typeKey [

	^ typeKey ifNil: [ typeKey := '@type' ]
]

{ #category : #accessing }
FamixValuePharoJacksonImporter >> typeKey: aString [

	typeKey := aString
]
