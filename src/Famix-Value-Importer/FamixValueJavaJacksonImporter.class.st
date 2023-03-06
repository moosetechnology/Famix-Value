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

{ #category : #enumerating }
FamixValueJavaJacksonImporter >> findTypeNamed: fullyQualifiedName [

	| result name |
	result := self detectType:
		          ((fullyQualifiedName beginsWithAnyOf:
			            #( 'java.lang.' 'java.util.' ))
			           ifTrue: [ 
				           name := fullyQualifiedName copyAfterLast: $..
				           [ :type | type name = name ] ]
			           ifFalse: [ 
				           name := '::' join: (fullyQualifiedName splitOn: $.).
				           [ :type | type mooseName = name ] ]).
	result isUnknownType ifTrue: [ result name: fullyQualifiedName ].
	^ result
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> idKey [

	^ idKey ifNil: [ idKey := '@id' ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> idKey: anObject [

	idKey := anObject
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
		^ (self importCollection: rawValue) type: type ].
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
FamixValueJavaJacksonImporter >> parseValues: serializedValues [

	"Import the elements of a serialized list.
	The type of the containing list is ignored."

	^ ((NeoJSONReader on: serializedValues readStream) parseList at: 2) 
		  collect: [ :rawValue | self importValue: rawValue ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> typeKey [

	^ typeKey ifNil: [ typeKey := '@type' ]
]

{ #category : #accessing }
FamixValueJavaJacksonImporter >> typeKey: anObject [

	typeKey := anObject
]
