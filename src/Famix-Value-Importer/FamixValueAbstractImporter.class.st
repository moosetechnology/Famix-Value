"
I am the root FamixValue importer.
My subclasses parse values and generate corresponding entities to represent runtime data.
The entities are linked with a Famix model to represent their type and their optional value holder (such as a variable).
"
Class {
	#name : 'FamixValueAbstractImporter',
	#superclass : 'Object',
	#instVars : [
		'model',
		'typeInferences',
		'objectDict',
		'entityFinder',
		'ignoreUnknownAttributes'
	],
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'accessing' }
FamixValueAbstractImporter >> entityFinder [

	^ entityFinder ifNil: [ entityFinder := FamixEntityFinder new ]
]

{ #category : 'accessing' }
FamixValueAbstractImporter >> entityFinder: anEntityFinder [

	entityFinder := anEntityFinder
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: '<UnknownType>'
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> getObjectFromIdentity: id ifAbsent: aBlock [

	^ objectDict at: id ifAbsent: aBlock
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> getObjectIdentity: rawObject [
	"Subclasses should define unique identifier for objects."

	self subclassResponsibility
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> getUnknownTypeNamed: name [

	Warning signal: 'Unknown type named ' , name.
	^ (self model allWithType: FamixValueUnknownType)
		  detect: [ :type | type name = name ]
		  ifNone: [ self model newUnknownTypeNamed: name ]
]

{ #category : 'initialization' }
FamixValueAbstractImporter >> ignoreUnknownAttributes [

	^ ignoreUnknownAttributes
]

{ #category : 'initialization' }
FamixValueAbstractImporter >> ignoreUnknownAttributes: aBoolean [
	"Whether to raise an error when an attribute is not found in the code model."

	ignoreUnknownAttributes := aBoolean
]

{ #category : 'importing' }
FamixValueAbstractImporter >> importCollection: rawValue of: type [
	"Infer element types from type argument, e.g. List<String> => String"

	| collection |
	collection := self model newOfCollection type: type.
	self
		withTypeInference: ((self parametricTypeInferencesOf: type)
				 ifNotEmpty: [ :inferences | inferences first ]
				 ifEmpty: [ nil ])
		do: [
			rawValue do: [ :rawElement |
				collection addValue: (self model newOfCollectionElement value:
						 (self importValue: rawElement)) ] ].
	^ collection
]

{ #category : 'importing' }
FamixValueAbstractImporter >> importDictionary: rawDictionary of: type [
	"Infer from type arguments, e.g. Map<String, MyClass>"

	| dictionary keyType valueType assoc |
	dictionary := self model newOfDictionary type: type.
	(self parametricTypeInferencesOf: type)
		ifNotEmpty: [ :paramTypeInferences |
			keyType := paramTypeInferences at: 1.
			valueType := paramTypeInferences at: 2 ]
		ifEmpty: [ keyType := valueType := nil ].

	self iterate: rawDictionary keysAndValuesDo: [ :rawKey :rawValue |
		assoc := self model newOfDictionaryAssociation dictionary:
			         dictionary.
		self
			withTypeInference: keyType
			do: [ assoc key: (self importValue: rawKey) ].
		self
			withTypeInference: valueType
			do: [ assoc value: (self importValue: rawValue) ] ].
	^ dictionary
]

{ #category : 'importing' }
FamixValueAbstractImporter >> importEnumValue: rawValue of: type [

	^ self model newOfEnum
		  type: type;
		  value:
			  (type enumValues detect: [ :enumValue |
					   enumValue name = rawValue ])
]

{ #category : 'importing' }
FamixValueAbstractImporter >> importObject: rawObject of: type [

	| object |
	object := self model newOfObject type: type.
	(self getObjectIdentity: rawObject) ifNotNil: [ :id |
		objectDict at: id put: object ].

	self iterate: rawObject keysAndValuesDo: [ :name :value |
		(self importObjectAttribute: value of: type named: name) ifNotNil: [
			:attribute | attribute object: object ] ].
	^ object
]

{ #category : 'importing' }
FamixValueAbstractImporter >> importObjectAttribute: rawValue of: type named: name [

	| attribute |
	attribute := type findAttributeNamed: name.
	^ self
		  withTypeInference:
		  (attribute ifNotNil: [ attribute declaredType ])
		  do: [
			  self model newOfObjectAttribute
				  value: (self importValue: rawValue);
				  attribute: attribute ]
]

{ #category : 'importing' }
FamixValueAbstractImporter >> importPrimitive: rawValue of: typeName [
	"Expect to be given a type name instead of a type!"

	^ self model newOfPrimitiveType
		  value: rawValue;
		  type: (self loadTypeNamed: typeName)
]

{ #category : 'importing' }
FamixValueAbstractImporter >> importValue: rawValue [
	"This method must figure out the rawValue's type and dispatch to the corresponding importing method."

	self subclassResponsibility
]

{ #category : 'initialization' }
FamixValueAbstractImporter >> initialize [

	self reset.
	ignoreUnknownAttributes := false
]

{ #category : 'importing' }
FamixValueAbstractImporter >> iterate: rawObject keysAndValuesDo: aBlock [

	rawObject keysAndValuesDo: aBlock
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> loadType [
	"Return the inferred type if it exists, otherwise the type is unknown."

	^ self typeInference ifNil: [ self getDefaultUnknownType ]
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> loadTypeNamed: fullyQualifiedName [
	"Try to find type in model with finder, or fallback to the inferred type, or type is unknown."

	^ (self entityFinder findTypeNamed: fullyQualifiedName) ifNil: [
		  self typeInference ifNil: [
			  self getUnknownTypeNamed: fullyQualifiedName ] ]
]

{ #category : 'accessing' }
FamixValueAbstractImporter >> model [

	^ model ifNil: [ model := FamixValueModel new ]
]

{ #category : 'accessing' }
FamixValueAbstractImporter >> model: aModel [

	model := aModel
]

{ #category : 'private - utility' }
FamixValueAbstractImporter >> newReader [

	^ NeoJSONReader new mapClass: OrderedDictionary
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> parametricTypeInferencesOf: type [

	type isParametricEntity ifFalse: [ ^ {  } ].
	^ type isGenericEntity
		  ifTrue: [
			  self typeInference ifNil: [ {  } ] ifNotNil: [ :inference |
				  (inference isDictionaryType and: [
					   inference concreteParameters size = 1 ])
					  ifTrue: [
						  {
							  (inference concreteParameters at: 1).
							  (inference concreteParameters at: 1) } ]
					  ifFalse: [ inference concreteParameters ] ] ]
		  ifFalse: [ type allTypeParameters ]
]

{ #category : 'parsing' }
FamixValueAbstractImporter >> parseList: serializedValues [
	"Reify the raw values from a serialized list, useful for iterating."

	^ (self newReader on: serializedValues readStream) parseList
]

{ #category : 'parsing' }
FamixValueAbstractImporter >> parseValue: serializedValue [
	"Parse and import a serialized value."

	^ self importValue:
		  (self newReader on: serializedValue readStream) next
]

{ #category : 'initialization' }
FamixValueAbstractImporter >> reset [
	"Forget type inferences and previous object identities."

	typeInferences := Stack new.
	objectDict := Dictionary new
]

{ #category : 'enumerating' }
FamixValueAbstractImporter >> typeInference [

	^ typeInferences ifEmpty: [  ] ifNotEmpty: [ typeInferences top ]
]

{ #category : 'importing' }
FamixValueAbstractImporter >> withTypeInference: type do: block [

	| result |
	type == self typeInference ifTrue: [ ^ block value ].
	typeInferences push: type.
	result := block value.
	typeInferences pop.
	^ result
]
