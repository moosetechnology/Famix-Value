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
		'typeFinder'
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
FamixValueAbstractImporter >> findTypeNamed: fullyQualifiedName [

	"Try to find type in model with finder, or fallback to the inferred type, or type is unknown."

	^ (self typeFinder findTypeNamed: fullyQualifiedName) ifNil: [ 
		  self typeInference ifNil: [ 
			  self newUnknownType name: fullyQualifiedName ] ]
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> getDefaultUnknownType [

	^ (self model allWithType: FamixValueUnknownType)
		  detect: [ :type | type name = '<UnknownType>' ]
		  ifNone: [ self newUnknownType name: '<UnknownType>' ]
]

{ #category : #importing }
FamixValueAbstractImporter >> importCollection: rawValue of: type [

	| value |
	value := self newValueOfCollection type: type.
	rawValue do: [ :rawElement | 
		value addValue: (self importValue: rawElement) ].
	^ value
]

{ #category : #importing }
FamixValueAbstractImporter >> importDictionary: rawValue of: type [

	| value |
	value := self newValueOfDictionary type: type.
	rawValue associationsDo: [ :rawAssoc | 
		self newValueOfDictionaryAssociation
			key: (self importValue: rawAssoc key);
			value: (self importValue: rawAssoc value);
			dictionary: value ].
	^ value
]

{ #category : #importing }
FamixValueAbstractImporter >> importEnumValue: rawValue of: type [

	^ self newValueOfEnum
		  type: type;
		  value:
			  (type enumValues detect: [ :enumValue | 
					   enumValue name = rawValue ])
]

{ #category : #importing }
FamixValueAbstractImporter >> importObject: rawValue of: type [

	| value attribute |
	value := self newValueOfObject type: type.
	rawValue associationsDo: [ :assoc | 
		attribute := self findAttribute: assoc key of: type.
		self
			withTypeInference: (attribute ifNotNil: [ attribute declaredType ])
			do: [ 
				(self importValue: assoc value)
					valueInObject: value;
					typedEntity: attribute ] ].
	^ value
]

{ #category : #importing }
FamixValueAbstractImporter >> importValue: rawValue [

	"This method must figure out the rawValue's type and dispatch to the corresponding importing method."

	self subclassResponsibility
]

{ #category : #testing }
FamixValueAbstractImporter >> isProcedure: method [

	^ method declaredType isNil
]

{ #category : #accessing }
FamixValueAbstractImporter >> model [

	^ model ifNil: [ model := FamixValueModel new ]
]

{ #category : #accessing }
FamixValueAbstractImporter >> model: aModel [

	model := aModel
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newUnknownType [

	^ self model add: FamixValueUnknownType new
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newValueOfCollection [

	^ self model add: FamixValueOfCollection new
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newValueOfDictionary [

	^ self model add: FamixValueOfDictionary new
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newValueOfDictionaryAssociation [

	^ self model add: FamixValueOfDictionaryAssociation new
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newValueOfEnum [

	^ self model add: FamixValueOfEnum new
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newValueOfObject [

	^ self model add: FamixValueOfObject new
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newValueOfPrimitiveType [

	^ self model add: FamixValueOfPrimitiveType new
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> newValueOfUnknownType [

	^ self model add: FamixValueOfUnknownType new
]

{ #category : #parsing }
FamixValueAbstractImporter >> parseValue: rawValue [

	self subclassResponsibility
]

{ #category : #parsing }
FamixValueAbstractImporter >> rawValues: serializedValues do: block [

	"Iterate over the raw values from a serialized list."

	(NeoJSONReader on: serializedValues readStream) parseList do: block
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

	^ self typeInferences ifEmpty: nil ifNotEmpty: [ typeInferences top ]
]

{ #category : #accessing }
FamixValueAbstractImporter >> typeInferences [

	^ typeInferences ifNil: [ typeInferences := Stack new ]
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
