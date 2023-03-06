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
		'linkedModel'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #enumerating }
FamixValueAbstractImporter >> detectType: block [

	^ (self typeEntity isTrait
		   ifTrue: [ linkedModel allUsing: self typeEntity ]
		   ifFalse: [ linkedModel allWithSubTypesOf: self typeEntity ])
		  detect: block
		  ifNone: [ self newUnknownType ]
]

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
FamixValueAbstractImporter >> findTypeNamed: name [

	^ self detectType: [ :type | type name = name ]
]

{ #category : #'entity creation' }
FamixValueAbstractImporter >> getAnonymousUnknownType [

	^ (self model allWithType: FamixValueUnknownType)
		  detect: [ :type | type name = '<UnknownType>' ]
		  ifNone: [ self newUnknownType name: '<UnknownType>' ]
]

{ #category : #importing }
FamixValueAbstractImporter >> importCollection: rawValue [

	| value |
	value := self newValueOfCollection.
	rawValue do: [ :rawElement | 
		value addValue: (self importValue: rawElement) ].
	^ value
]

{ #category : #importing }
FamixValueAbstractImporter >> importDictionary: rawValue [

	| value |
	value := self newValueOfDictionary.
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

	| value |
	value := self newValueOfObject type: type.
	rawValue associationsDo: [ :assoc | 
		(self importValue: assoc value)
			valueInObject: value;
			typedEntity: (self findAttribute: assoc key of: type) ].
	^ value
]

{ #category : #importing }
FamixValueAbstractImporter >> importValue: rawValue [

	self subclassResponsibility
]

{ #category : #testing }
FamixValueAbstractImporter >> isProcedure: method [

	^ method declaredType isNil
]

{ #category : #accessing }
FamixValueAbstractImporter >> linkedModel [

	^ linkedModel
]

{ #category : #accessing }
FamixValueAbstractImporter >> linkedModel: famixModel [

	linkedModel := famixModel
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
FamixValueAbstractImporter >> parseValues: rawValues [

	self subclassResponsibility
]
