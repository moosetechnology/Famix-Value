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

	^ rawObject removeKey: self idKey ifAbsent: nil
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
FamixValueJavaJacksonImporter >> importClassReference: rawValue of: type [

	"The type has already been loaded during the inference.
	The raw value contains the fully qualified name of the referenced class."

	^ self model newOfClassReference
		  value: (self loadTypeNamed: rawValue);
		  type: type
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
						    type: (self entityFinder findTypeNamed: 'long')));
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

	| rawValues |
	rawValues := super parseList: serializedValues.
	^ rawValues hasJavaJacksonTypeInformation
		  ifTrue: [ "ignore the type information of the top level list." 
			  rawValues at: 2 ]
		  ifFalse: [ rawValues ]
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
