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
		'specialTypes',
		'skipTransientAttributes'
	],
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> findAttributeNamed: name in: type [
	"Find the attribute using its name in the given type's hierarchy.
	Handle Java synthetic fields: they are created by the compiler and do not appear in the source code."

	type isInterface ifTrue: [ "This should not happen because we should have the runtime type, which cannot be an interface.
		If it still happens, it probably means the source of the value, or possibly the model, is missing the type"
		FamixValueImporterError signal:
			'Cannot find the attribute `' , name , '` in the interface `'
			, type name , '`.' ].

	"Search the attribute in the code model"
	(type findAttributeNamed: name) ifNotNil: [ :attribute | ^ attribute ].

	"The attribute was not found in the model: it may be synthetic.
	The check for synthetic fields is based on the naming convention of the Java compiler.
	However, the names it gives are also valid in source code, even if it is unlikely.
	For this reason, the regular check must be done before the following checks."

	(name beginsWith: 'this$') ifTrue: [ "Reference from the inner class instance to the outer class instance.
		This is not represented in Famix, so we create the attribute artificially.
		Inner classes can be nested, and the fields are named with a suffix to avoid collisions: this$0, this$1, etc.
		There can only be one such field in a class.
		Do not create a relation to the code model, such as parentType or declaredType, to keep it 'special' and resetable."
		^ type cacheAt: #syntheticOuterInstance ifAbsentPut: [
			  (FamixValueJavaSyntheticAttribute named: name)
				  parentType: type;
				  declaredType: type typeContainer ] ].

	"TODO fields from anonymous classes and lambdas storing variables captured by closure (named `val$<varName>`)"

	"Attribute not found -> probably declared in a stub superclass"
	ignoreUnknownAttributes ifTrue: [ ^ nil ].
	FamixValueImporterError signal:
		'Attribute `' , name , '` not found in hierarchy of `'
		, type mooseName , '`'
]

{ #category : 'enumerating' }
FamixValueJavaJacksonImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: 'Object'
]

{ #category : 'enumerating' }
FamixValueJavaJacksonImporter >> getObjectIdentity: rawObject [
	"Keep track of objects by using the id given by Jackson.
	References to previously seen objects are serialized by using this id."

	^ rawObject at: self idKey ifAbsent: nil
]

{ #category : 'enumerating' }
FamixValueJavaJacksonImporter >> getObjectType: rawObject [

	^ rawObject at: self typeKey ifAbsent: nil
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

	| attribute inference |
	attribute := self findAttributeNamed: name in: type.

	(attribute isNil or: [
		 attribute isTransient and: [ self skipTransientAttributes ] ])
		ifTrue: [ ^ nil ].

	"If the attribute type is a TypeParameter, and the runtime type is a concretization
	=> inference is the concretization of the TypeParameter"
	inference := nil.
	attribute ifNotNil: [
		attribute declaredType ifNotNil: [ :declaredType |
			declaredType isParameterType
				ifFalse: [ "not parametric" inference := declaredType ]
				ifTrue: [ "wait what's happening here? why do we need a detect? investigate, fix(?), and explain with a comment"
					declaredType concretizations
						detect: [ :paramType |
						paramType concretizations first concreteEntity == type ]
						ifFound: [ :paramType |
						inference := paramType concreteParameter ].
					inference ifNotNil: [ self halt ] ] ] ].

	"Check if the value is an array"
	(rawValue isCollection and: [
		 inference isNotNil and: [ self isPrimitiveType: inference ] ])
		ifTrue: [ "TODO check is too strict, arrays can be everywhere -> add info in metamodel!"
			^ self model newOfObjectAttribute
				  value: (self
						   importCollection: rawValue
						   of: ((FamixValueJavaArray wrapping: inference) dimensions:
									    (self readDimensionsOfAttribute: attribute)));
				  attribute: attribute ].

	^ self withTypeInference: inference do: [
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
		  type isClass and: [ type isPrimitiveWrapper ] ]
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> iterate: rawValue keysAndValuesDo: aBlock [

	rawValue keysAndValuesDo: [ :key :value |
		(key = self idKey or: [ key = self typeKey ]) ifFalse: [
			aBlock value: key value: value ] ]
]

{ #category : 'parsing' }
FamixValueJavaJacksonImporter >> parseList: serializedValues [

	| rawValues |
	rawValues := super parseList: serializedValues.
	^ rawValues hasJavaJacksonTypeInformation
		  ifTrue: [ "Ignore the type information of the top level list."
			  ^ rawValues at: 2 "TODO Only a specific version of jackson does this, investigate" ]
		  ifFalse: [ rawValues ]
]

{ #category : 'private - utility' }
FamixValueJavaJacksonImporter >> readDimensionsOfAttribute: attribute [
	"Famix ignores the dimensions of an attribute, so we have to read it manually.
	The source anchor is used to look for square brackets in the attribute definition.
	The square brackets can appear on the type or on the identifier.
	e.g. `int[] a, b[];`, var a has 1 dimension, var b has 2."

	| source char index dimensions |
	source := WriteStream on: (String new: 100).
	attribute sourceAnchor fileReference readStreamDo: [ :rs |
		| start |
		"We don't know where the attribute definition starts
		because the source anchor only applies to the identifier
		so we read the source starting from the class start position."
		start := attribute parentType sourceAnchor startPos.
		rs skip: start.
		start to: attribute sourceAnchor endPos do: [ :i |
		source nextPut: rs next ].
		"Additionally read from endPos until:
		- next declarator, eg. `int a, b`
		- end of definition, eg. `int a;`
		- initialization, eg. `int a = 1`"
		[ ',;=' includes: (char := rs next) ] whileFalse: [
			source nextPut: char ] ].

	"Source contains (at least) the attribute definition, now we count the square brackets"
	source := source contents.
	index := source size.
	dimensions := 0.
	[ "Read backwards until:
	- block opener, eg. `class C { int a;`
	- block closer, eg. `int f(){} int a;`
	- end of statement, eg. `int b; int a;`"
	char := source at: (index := index - 1).
	char == $]
		ifTrue: [
			dimensions := dimensions + 1.
			false ]
		ifFalse: [ '{};' includes: char ] ] whileFalse.
	^ dimensions
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> skipTransientAttributes [

	^ skipTransientAttributes ifNil: [ skipTransientAttributes := true ]
]

{ #category : 'importing' }
FamixValueJavaJacksonImporter >> skipTransientAttributes: aBoolean [

	skipTransientAttributes := aBoolean
]

{ #category : 'accessing' }
FamixValueJavaJacksonImporter >> specialTypes [

	^ specialTypes ifNil: [
		  (specialTypes := Dictionary new)
			  at: 'java.util.Calendar' put: FamixValueJavaCalendar;
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
