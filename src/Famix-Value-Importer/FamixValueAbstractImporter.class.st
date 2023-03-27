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
		'objectResolutions',
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

{ #category : #'entity creation' }
FamixValueAbstractImporter >> getDefaultUnknownType [

	^ (self model allWithType: FamixValueUnknownType)
		  detect: [ :type | type name = '<UnknownType>' ]
		  ifNone: [ self newUnknownType name: '<UnknownType>' ]
]

{ #category : #importing }
FamixValueAbstractImporter >> importCollection: rawValue of: type [

	| collection |
	collection := self newValueOfCollection type: type.
	rawValue do: [ :rawElement | 
		self
			onResolved: (self importValue: rawElement)
			do: [ :value | collection addValue: value ] ].
	^ collection
]

{ #category : #importing }
FamixValueAbstractImporter >> importDictionary: rawValue of: type [

	| dictionary assoc |
	dictionary := self newValueOfDictionary type: type.
	rawValue associationsDo: [ :rawAssoc | 
		assoc := self newValueOfDictionaryAssociation dictionary: dictionary.
		self
			onResolved: (self importValue: rawAssoc key)
			do: [ :key | assoc key: key ].
		self
			onResolved: (self importValue: rawAssoc value)
			do: [ :value | assoc value: value ] ].
	^ dictionary
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

	| object attribute |
	object := self newValueOfObject type: type.
	rawValue associationsDo: [ :assoc | 
		attribute := self findAttribute: assoc key of: type.
		self
			withTypeInference: (attribute ifNotNil: [ attribute declaredType ])
			do: [ 
				self onResolved: (self importValue: assoc value) do: [ :value | 
					self newValueOfAttribute
						value: value;
						object: object;
						attribute: attribute ] ] ].
	^ object
]

{ #category : #importing }
FamixValueAbstractImporter >> importValue: rawValue [

	"This method must figure out the rawValue's type and dispatch to the corresponding importing method."

	self subclassResponsibility
]

{ #category : #initialization }
FamixValueAbstractImporter >> initialize [

	typeInferences := Stack new.
	self reset
]

{ #category : #testing }
FamixValueAbstractImporter >> isProcedure: method [

	^ method declaredType isNil
]

{ #category : #enumerating }
FamixValueAbstractImporter >> loadTypeNamed: fullyQualifiedName [

	"Try to find type in model with finder, or fallback to the inferred type, or type is unknown."

	^ (self typeFinder findTypeNamed: fullyQualifiedName) ifNil: [ 
		  self typeInference ifNil: [ 
			  self newUnknownType name: fullyQualifiedName ] ]
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

{ #category : #'private-entity-creation' }
FamixValueAbstractImporter >> newValueOfAttribute [

	^ self model add: FamixValueOfAttribute new
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

{ #category : #importing }
FamixValueAbstractImporter >> onResolved: value do: aBlock [

	value isInteger
		ifFalse: [ aBlock value: value ]
		ifTrue: [ 
			objectResolutions
				at: value
				ifPresent: [ :resolutions | resolutions add: aBlock ]
				ifAbsentPut: [ OrderedCollection with: aBlock ] ]
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

{ #category : #initialization }
FamixValueAbstractImporter >> reset [

	"Forget previous object references."

	objectDict := Dictionary new.
	objectResolutions := Dictionary new
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
