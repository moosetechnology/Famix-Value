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
		'typeFinder',
		'objectDict'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #enumerating }
FamixValueAbstractImporter >> findAttribute: name of: type [

	^ type attributes detect: [ :attr | attr name = name ] ifNone: [ 
		  (type isClass
			   ifTrue: [ type ]
			   ifFalse: [ type parameterizableClass ]) inheritedAttributes
			  detect: [ :attr | attr name = name ]
			  ifNone: nil ]
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: '<UnknownType>'
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getObjectFromIdentity: id [

	^ objectDict at: id
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getObjectIdentity: rawObject [

	"Subclasses should define unique identifier for objects."

	self subclassResponsibility
]

{ #category : #enumerating }
FamixValueAbstractImporter >> getUnknownTypeNamed: name [

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
		(type isParameterizedType ifTrue: [ type arguments first ])
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
	(type isUnknownType not and: [ type isParameterizedType ])
		ifTrue: [ 
			keyType := type keyArgument.
			valueType := type valueArgument ]
		ifFalse: [ keyType := valueType := nil ].
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
	objectDict at: (self getObjectIdentity: rawObject) put: object.
	rawObject associationsDo: [ :assoc | 
		attribute := self findAttribute: assoc key of: type.
		self
			withTypeInference: (attribute ifNotNil: [ attribute declaredType ])
			do: [ "attribute and value's typedEntity may differ"
				self model newOfObjectAttribute
					value: ((self importValue: assoc value) typedEntity: attribute);
					object: object;
					attribute: attribute ] ].
	^ object
]

{ #category : #importing }
FamixValueAbstractImporter >> importValue: rawValue [

	"This method must figure out the rawValue's type and dispatch to the corresponding importing method."

	self subclassResponsibility
]

{ #category : #initialization }
FamixValueAbstractImporter >> initialize [

	typeInferences := Stack new
]

{ #category : #'private - utility' }
FamixValueAbstractImporter >> isProcedure: method [

	^ method declaredType isNil
]

{ #category : #enumerating }
FamixValueAbstractImporter >> loadTypeNamed: fullyQualifiedName [

	"Try to find type in model with finder, or fallback to the inferred type, or type is unknown."

	^ (self typeFinder findTypeNamed: fullyQualifiedName) ifNil: [ 
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

{ #category : #parsing }
FamixValueAbstractImporter >> parseValue: serializedValue [

	"Parse and import a serialized value."

	self reset.
	^ self importValue:
		  (NeoJSONReader on: serializedValue readStream) parseValue
]

{ #category : #parsing }
FamixValueAbstractImporter >> rawValues: serializedValues do: block [

	"Iterate over the raw values from a serialized list."

	self reset.
	(NeoJSONReader on: serializedValues readStream) parseList do: block
]

{ #category : #initialization }
FamixValueAbstractImporter >> reset [

	"Forget previous object identities."

	objectDict := Dictionary new
]

{ #category : #accessing }
FamixValueAbstractImporter >> typeFinder [

	^ typeFinder ifNil: [ typeFinder := FamixTTypeFinder new ]
]

{ #category : #accessing }
FamixValueAbstractImporter >> typeFinder: aTypeFinder [

	typeFinder := aTypeFinder
]

{ #category : #enumerating }
FamixValueAbstractImporter >> typeInference [

	^ typeInferences ifEmpty: nil ifNotEmpty: [ typeInferences top ]
]

{ #category : #importing }
FamixValueAbstractImporter >> withTypeInference: type do: block [

	| result |
	type = self typeInference ifTrue: [ ^ block value ].
	typeInferences push: type.
	result := block value.
	typeInferences pop.
	^ result
]
