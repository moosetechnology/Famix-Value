"
I am a FamixValue importer for Java.
I understand the JSON format from the Jackson library, which must be configured to pair each value with the fully qualified name of its type.
"
Class {
	#name : #FamixValueJavaJacksonImporter,
	#superclass : #FamixValueAbstractImporter,
	#instVars : [
		'typeKey',
		'idKey',
		'specialTypes'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #enumerating }
FamixValueJavaJacksonImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: 'Object'
]

{ #category : #enumerating }
FamixValueJavaJacksonImporter >> getObjectIdentity: rawObject [

	"Keep track of objects by using the id given by Jackson.
	References to previously seen objects are serialized by using this id."

	^ rawObject removeKey: self idKey
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
FamixValueJavaJacksonImporter >> importDateObject: rawValue of: type [

	^ self model newOfObject
		  type: (self specialTypes
				   at: type name
				   ifAbsentPut: [ FamixValueJavaDate proxying: type ]);
		  addValue:
			  (model newOfObjectAttribute value: (model newOfPrimitiveType
						    value: rawValue;
						    type: (self typeFinder findTypeNamed: 'long')));
		  yourself
]

{ #category : #importing }
FamixValueJavaJacksonImporter >> importSpecialObject: rawValue of: type [

	"Some objects have special rules for serialization"

	(#( Date Timestamp ) includes: type name) ifTrue: [ 
		^ self importDateObject: rawValue of: type ].
	self error: 'Unknown special object: ' , type mooseNameWithDots
]

{ #category : #importing }
FamixValueJavaJacksonImporter >> importValue: rawValue [

	"Import a raw value, which has been parsed from JSON in Jackson format.
	It can be: nil, boolean, integer, string, array or dictionary."

	^ rawValue asJavaJacksonValueOn: self
]

{ #category : #importing }
FamixValueJavaJacksonImporter >> importValueFromList: rawValue of: type [

	"Jackson can serialize different types of values in a list, so we need to find out which."

	rawValue isCollection ifTrue: [ 
		^ self importCollection: rawValue of: type ].
	type isUnknownType ifTrue: [ 
		^ self model newOfUnknownType
			  value: rawValue;
			  type: type ].
	(type class usesTrait: FamixTEnum) ifTrue: [ 
		^ self importEnumValue: rawValue of: type ].
	(self isPrimitiveType: type) ifTrue: [ 
		^ self model newOfPrimitiveType
			  value: rawValue;
			  type: type ].
	type isClass ifTrue: [ ^ self importSpecialObject: rawValue of: type ].
	self error: 'Unknown type: ' , type mooseNameWithDots
]

{ #category : #'private - utility' }
FamixValueJavaJacksonImporter >> isDictionary: type [

	^ #( Map HashMap LinkedHashMap ) includes: type name
]

{ #category : #'private - utility' }
FamixValueJavaJacksonImporter >> isPrimitiveType: type [

	^ type isPrimitiveType or: [ 
		  #( Integer Float Double Long Short Byte ) includes: type name ]
]

{ #category : #'private - utility' }
FamixValueJavaJacksonImporter >> isProcedure: method [

	^ method declaredType name = 'void'
]

{ #category : #parsing }
FamixValueJavaJacksonImporter >> parseList: serializedValues [

	"Ignore the type information of the top level list."

	^ (super parseList: serializedValues) at: 2
]

{ #category : #parsing }
FamixValueJavaJacksonImporter >> rawValues: serializedValues do: block [

	"Ignore the type information of the top level list."

	self reset.
	((NeoJSONReader on: serializedValues readStream) parseList at: 2) 
		do: block
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> specialTypes [

	^ specialTypes ifNil: [ specialTypes := Dictionary new ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> typeKey [

	^ typeKey ifNil: [ typeKey := '@type' ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> typeKey: aString [

	typeKey := aString
]
