"
I am a FamixValue importer for Java.
I understand the JSON format from the Jackson library, which must be configured to pair each value with the fully qualified name of its type.
"
Class {
	#name : #FamixValueJavaJacksonImporter,
	#superclass : #FamixValueAbstractImporter,
	#instVars : [
		'typeKey',
		'idKey'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #'entity creation' }
FamixValueJavaJacksonImporter >> getDefaultUnknownType [

	^ (self model allWithType: FamixValueUnknownType)
		  detect: [ :type | type name = 'Object' ]
		  ifNone: [ self newUnknownType name: 'Object' ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> idKey [

	^ idKey ifNil: [ idKey := '@id' ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> idKey: aString [

	idKey := aString
]

{ #category : #importing }
FamixValueJavaJacksonImporter >> importCollection: rawCollection of: type [

	"infer from type argument, e.g. List<String> => String"

	^ self
		  withTypeInference: (type isParameterizedType
				   ifTrue: [ type arguments first ]
				   ifFalse: nil)
		  do: [ super importCollection: rawCollection of: type ]
]

{ #category : #importing }
FamixValueJavaJacksonImporter >> importDictionary: rawValue of: type [

	"infer from type arguments, e.g. Map<String, MyClass>"

	| value keyType valueType assoc |
	value := self newValueOfDictionary type: type.
	(type isUnknownType not and: [ type isParameterizedType ])
		ifTrue: [ 
			keyType := type arguments first.
			valueType := type arguments second ]
		ifFalse: [ keyType := valueType := nil ].
	rawValue associationsDo: [ :rawAssoc | 
		assoc := self newValueOfDictionaryAssociation dictionary: value.
		self
			withTypeInference: keyType
			do: [ assoc key: (self importValue: rawAssoc key) ].
		self
			withTypeInference: valueType
			do: [ assoc value: (self importValue: rawAssoc value) ] ].
	^ value
]

{ #category : #importing }
FamixValueJavaJacksonImporter >> importValue: rawValue [

	"Import a raw value, which has been parsed from JSON in Jackson format.
	It can be: nil, boolean, integer, string, array or dictionary."

	^ rawValue asJavaJacksonValueOn: self
]

{ #category : #importing }
FamixValueJavaJacksonImporter >> importValueFromList: rawValue of: type [

	rawValue isCollection ifTrue: [ 
		^ self importCollection: rawValue of: type ].
	type isUnknownType ifTrue: [ 
		^ self newValueOfUnknownType
			  value: rawValue;
			  type: type ].
	^ (self isPrimitiveType: type)
		  ifTrue: [ 
			  self newValueOfPrimitiveType
				  value: rawValue;
				  type: type ]
		  ifFalse: [ self importEnumValue: rawValue of: type ]
]

{ #category : #'private - utility' }
FamixValueJavaJacksonImporter >> isDictionary: type [

	^ #( Map HashMap LinkedHashMap ) includes: type name
]

{ #category : #'private - utility' }
FamixValueJavaJacksonImporter >> isPrimitiveType: type [

	^ type isPrimitiveType or: [ 
		  #( Integer Float Double Long Short Byte Timestamp ) includes:
			  type name ]
]

{ #category : #testing }
FamixValueJavaJacksonImporter >> isProcedure: method [

	^ method declaredType name = 'void'
]

{ #category : #parsing }
FamixValueJavaJacksonImporter >> parseValue: serializedValue [

	"Import a serialized value."

	^ self importValue:
		  (NeoJSONReader on: serializedValue readStream) parseValue
]

{ #category : #parsing }
FamixValueJavaJacksonImporter >> rawValues: serializedValues do: block [

	((NeoJSONReader on: serializedValues readStream) parseList at: 2) 
		do: block
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> typeKey [

	^ typeKey ifNil: [ typeKey := '@type' ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> typeKey: aString [

	typeKey := aString
]
