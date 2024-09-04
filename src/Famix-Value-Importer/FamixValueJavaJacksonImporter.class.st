"
I am a FamixValue importer for Java.
I understand the JSON format of the Jackson library up to and including version `2.10`.
The ObjectMapper must be configured to associate each value with the fully qualified name of its type.

```language=text
@JsonIdentityInfo(generator = ObjectIdGenerators.IntSequenceGenerator.class, property = ""@id"")
@JsonTypeInfo(use = JsonTypeInfo.Id.CLASS, include = JsonTypeInfo.As.PROPERTY, property = ""@type"")
interface MixIn {}

new ObjectMapper().addMixIn(Object.class, MixIn.class);
```
"
Class {
	#name : 'FamixValueJavaJacksonImporter',
	#superclass : 'FamixValueAbstractImporter',
	#instVars : [
		'typeKey',
		'idKey',
		'specialTypes'
	],
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'enumerating' }
FamixValueJavaJacksonImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: 'Object'
]

{ #category : 'enumerating' }
FamixValueJavaJacksonImporter >> getObjectIdentity: rawObject [
	"Keep track of objects by using the id given by Jackson.
	References to previously seen objects are serialized by using this id."

	^ rawObject removeKey: self idKey ifAbsent: nil
]

{ #category : 'enumerating' }
FamixValueJavaJacksonImporter >> getObjectType: rawObject [

	^ rawObject removeKey: self typeKey ifAbsent: nil
]

{ #category : 'accessing' }
FamixValueJavaJacksonImporter >> idKey [

	^ idKey ifNil: [ idKey := '@id' ]
]

{ #category : 'accessing' }
FamixValueJavaJacksonImporter >> idKey: aString [

	idKey := aString
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> importObjectAttribute: rawValue of: type named: name [

	| attribute |
	type isInterface ifTrue: [
		Error signal:
			'Cannot find attributes in interfaces. Signaled for attribute `'
			, name , '` and interface `' , type name , '`.' ].
	(attribute := type findAttributeNamed: name) ifNotNil: [ "Skip transient attributes."
		attribute isTransient ifTrue: [ ^ nil ] ].
	^ self
		  withTypeInference:
		  (attribute ifNotNil: [ attribute declaredType ])
		  do: [
			  self model newOfObjectAttribute
				  value: (self importValue: rawValue);
				  attribute: attribute ]
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> importSpecialObject: rawValue of: type [
	"Some objects have special rules for serialization.
	They should have a corresponding type wrapper that knows how to handle them."

	self specialTypes
		at: type mooseNameWithDots
		ifPresent: [ :typeWrapper |
			^ typeWrapper import: rawValue wrapping: type on: self ].
	^ nil
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> importTypeReference: rawValue of: type [
	"The type has already been loaded during the inference.
	The raw value contains the fully qualified name of the referenced class."

	^ self model newOfTypeReference
		  value: (self loadTypeNamed: rawValue);
		  type: type
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> importValue: rawValue [
	"Import a raw value, which has been parsed from JSON in Jackson format.
	It can be: nil, boolean, integer, string, array or dictionary."

	^ rawValue asJavaJacksonValueOn: self
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> importValueFromList: rawValue of: type [
	"Jackson can serialize different types of values in a list, so we need to find out which it is."

	rawValue isCollection ifTrue: [
		^ self importCollection: rawValue of: type ].
	type isUnknownType ifTrue: [
		^ self model newOfUnknownType
			  value: rawValue;
			  type: type ].
	(type usesFamixTrait: FamixTEnum) ifTrue: [
		^ self importEnumValue: rawValue of: type ].
	(self isPrimitiveType: type) ifTrue: [
		^ self model newOfPrimitiveType
			  value: rawValue;
			  type: type ].
	type isClass ifTrue: [ "might be a special object"
		(self importSpecialObject: rawValue of: type) ifNotNil: [ :object |
			^ object ] ].
	self error: 'Unknown type: ' , type mooseNameWithDots
]

{ #category : 'private - utility' }
FamixValueJavaJacksonImporter >> isPrimitiveType: type [

	^ type isPrimitiveType or: [ "Classes wrapping primitives are also considered primitives."
		  type isPrimitiveWrapper ]
]

{ #category : 'parsing' }
FamixValueJavaJacksonImporter >> parseList: serializedValues [

	| rawValues |
	rawValues := super parseList: serializedValues.
	^ rawValues hasJavaJacksonTypeInformation
		  ifTrue: [ "ignore the type information of the top level list."
			  rawValues at: 2 ]
		  ifFalse: [ rawValues ]
]

{ #category : 'accessing' }
FamixValueJavaJacksonImporter >> specialTypes [

	^ specialTypes ifNil: [
		  (specialTypes := Dictionary new)
			  at: 'java.util.Date' put: FamixValueJavaDate;
			  at: 'java.sql.Date' put: FamixValueJavaSQLDate;
			  at: 'java.sql.Timestamp' put: FamixValueJavaDate;
			  yourself ]
]

{ #category : 'accessing' }
FamixValueJavaJacksonImporter >> typeKey [

	^ typeKey ifNil: [ typeKey := '@type' ]
]

{ #category : 'accessing' }
FamixValueJavaJacksonImporter >> typeKey: aString [

	typeKey := aString
]
