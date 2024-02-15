"
I am the root FamixValue importer.
My subclasses parse values and generate corresponding entities to represent runtime data.
The entities are linked with a Famix model to represent their type and their optional value holder (such as a variable).
"
Class {
	#name : #FamixValueAbstractImporter,
	#superclass : #Object,
	#instVars : [
		'model',
		'typeInferences',
		'objectDict',
		'entityFinder'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #accessing }
FamixValueAbstractImporter >> entityFinder [

	^ entityFinder ifNil: [ entityFinder := FamixEntityFinder new ]
]

{ #category : #accessing }
FamixValueAbstractImporter >> entityFinder: anEntityFinder [

	entityFinder := anEntityFinder
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: '<UnknownType>'
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getObjectFromIdentity: id ifAbsent: aBlock [

	^ objectDict at: id ifAbsent: aBlock
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getObjectIdentity: rawObject [
	"Subclasses should define unique identifier for objects."

	self subclassResponsibility
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getUnknownTypeNamed: name [

	Warning signal: 'Unknown type named ' , name.
	^ (self model allWithType: FamixValueUnknownType)
		  detect: [ :type | type name = name ]
		  ifNone: [ self model newUnknownTypeNamed: name ]
]

{ #category : #importing }
FamixValueAbstractImporter >> importCollection: rawValue of: type [
	"infer element types from type argument, e.g. List<String> => String"

	| collection |
	collection := self model newOfCollection type: type.
	self
		withTypeInference:
		(type isParametricEntity ifTrue: [ type allTypeParameters first ])
		do: [
			rawValue do: [ :rawElement |
				collection addValue: (self model newOfCollectionElement value:
						 (self importValue: rawElement)) ] ].
	^ collection
]

{ #category : #importing }
FamixValueAbstractImporter >> importDictionary: rawValue of: type [
	"infer from type arguments, e.g. Map<String, MyClass>"

	| dictionary keyType valueType assoc |
	dictionary := self model newOfDictionary type: type.
	(self parametricTypeInferencesOf: type)
		ifNotNil: [ :paramTypeInferences |
			keyType := paramTypeInferences at: 1.
			valueType := paramTypeInferences at: 2 ]
		ifNil: [ keyType := valueType := nil ].
	rawValue associationsDo: [ :rawAssoc |
		assoc := self model newOfDictionaryAssociation dictionary:
			         dictionary.
		self
			withTypeInference: keyType
			do: [ assoc key: (self importValue: rawAssoc key) ].
		self
			withTypeInference: valueType
			do: [ assoc value: (self importValue: rawAssoc value) ] ].
	^ dictionary
]

{ #category : #importing }
FamixValueAbstractImporter >> importEnumValue: rawValue of: type [

	^ self model newOfEnum
		  type: type;
		  value:
			  (type enumValues detect: [ :enumValue |
					   enumValue name = rawValue ])
]

{ #category : #importing }
FamixValueAbstractImporter >> importObject: rawObject of: type [

	| object attribute |
	object := self model newOfObject type: type.
	(self getObjectIdentity: rawObject) ifNotNil: [ :id |
		objectDict at: id put: object ].
	rawObject associationsDo: [ :assoc |
		attribute := type findAttributeNamed: assoc key.
		self
			withTypeInference: (attribute ifNotNil: [ attribute declaredType ])
			do: [
				self model newOfObjectAttribute
					value: (self importValue: assoc value);
					object: object;
					attribute: attribute ] ].
	^ object
]

{ #category : #importing }
FamixValueAbstractImporter >> importPrimitive: rawValue of: typeName [
	"Expect to be given a type name instead of a type!"

	^ self model newOfPrimitiveType
		  value: rawValue;
		  type: (self loadTypeNamed: typeName)
]

{ #category : #importing }
FamixValueAbstractImporter >> importValue: rawValue [
	"This method must figure out the rawValue's type and dispatch to the corresponding importing method."

	self subclassResponsibility
]

{ #category : #initialization }
FamixValueAbstractImporter >> initialize [

	self reset
]

{ #category : #enumerating }
FamixValueAbstractImporter >> loadType [
	"Return the inferred type if it exists, otherwise the type is unknown."

	^ self typeInference ifNil: [ self getDefaultUnknownType ]
]

{ #category : #enumerating }
FamixValueAbstractImporter >> loadTypeNamed: fullyQualifiedName [
	"Try to find type in model with finder, or fallback to the inferred type, or type is unknown."

	^ (self entityFinder findTypeNamed: fullyQualifiedName) ifNil: [
		  self typeInference ifNil: [
			  self getUnknownTypeNamed: fullyQualifiedName ] ]
]

{ #category : #accessing }
FamixValueAbstractImporter >> model [

	^ model ifNil: [ model := FamixValueModel new ]
]

{ #category : #accessing }
FamixValueAbstractImporter >> model: aModel [

	model := aModel
]

{ #category : #'private - utility' }
FamixValueAbstractImporter >> newReader [

	^ NeoJSONReader new mapClass: OrderedDictionary
]

{ #category : #'as yet unclassified' }
FamixValueAbstractImporter >> parametricTypeInferencesOf: type [

	type isParametricEntity ifFalse: [ ^ nil ].
	^ type isGenericEntity
		  ifTrue: [
			  self typeInference ifNotNil: [ :inference |
				  (inference isDictionaryType and: [
					   inference concreteParameters size = 1 ])
					  ifTrue: [
						  {
							  (inference concreteParameters at: 1).
							  (inference concreteParameters at: 1) } ]
					  ifFalse: [ inference concreteParameters ] ] ]
		  ifFalse: [
			  self halt.
			  type allTypeParameters ]
]

{ #category : #parsing }
FamixValueAbstractImporter >> parseList: serializedValues [
	"Reify the raw values from a serialized list, useful for iterating."

	^ (self newReader on: serializedValues readStream) parseList
]

{ #category : #parsing }
FamixValueAbstractImporter >> parseValue: serializedValue [
	"Parse and import a serialized value."

	^ self importValue:
		  (self newReader on: serializedValue readStream) next
]

{ #category : #initialization }
FamixValueAbstractImporter >> reset [
	"Forget type inferences and previous object identities."

	typeInferences := Stack new.
	objectDict := Dictionary new
]

{ #category : #enumerating }
FamixValueAbstractImporter >> typeInference [

	^ typeInferences ifEmpty: [  ] ifNotEmpty: [ typeInferences top ]
]

{ #category : #importing }
FamixValueAbstractImporter >> withTypeInference: type do: block [

	| result |
	type == self typeInference ifTrue: [ ^ block value ].
	typeInferences push: type.
	result := block value.
	typeInferences pop.
	^ result
]
