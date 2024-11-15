Class {
	#name : 'FamixValueJavaXStreamImporter',
	#superclass : 'FamixValueAbstractImporter',
	#instVars : [
		'specialTypes'
	],
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'as yet unclassified' }
FamixValueJavaXStreamImporter >> findTypeDimensions: aFamixJavaAttribute [
	"Nothing in the XML tells if it is an array, so we have to check the source code"

	| dimensions source index char |
	dimensions := 0.
	source := aFamixJavaAttribute sourceAnchor fileReference contents.

	"search after attribute name"
	index := aFamixJavaAttribute sourceAnchor endPos.
	[
	char := source at: (index := index + 1).
	char == $[ ifTrue: [ dimensions := dimensions + 1 ].
	char == $= or: [ char == $; ] ] whileFalse.

	"search before"
	index := aFamixJavaAttribute sourceAnchor startPos.
	[
	char := source at: (index := index - 1).
	char == $[ ifTrue: [ dimensions := dimensions + 1 ].
	char isAlphaNumeric ] whileFalse.

	^ dimensions
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importArray: aXMLElement of: type [
	"element type should already be inferred by the caller, normally in the context of an object attribute"

	| collection |
	collection := self model newOfCollection type: type.
	objectDict at: aXMLElement put: collection.

	aXMLElement nodes ifNotEmpty: [ :nodes |
		nodes reject: [ :node | node isStringNode ] thenDo: [ :rawElement |
			self model newOfCollectionElement
				collection: collection;
				value: (rawElement name = 'null'
						 ifTrue: [
							 model newOfPrimitiveType
								 value: 'null';
								 type: self loadType ]
						 ifFalse: [
							 self
								 importValue: rawElement
								 of: (self loadTypeNamed: rawElement name) ]) ] ].
	^ collection
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importCollection: rawValue of: type [
	"infer element types from type argument, e.g. List<String> => String"

	| collection |
	collection := self model newOfCollection type: type.
	objectDict at: rawValue put: collection.
	rawValue nodes ifEmpty: [ ^ collection ].
	self
		withTypeInference: ((self parametricTypeInferencesOf: type)
				 ifNotEmpty: [ :inferences | inferences first ]
				 ifEmpty: [ nil ])
		do: [
			rawValue nodes
				reject: [ :node | node isStringNode ]
				thenDo: [ :rawElement |
					collection addValue:
						(self model newOfCollectionElement value: (self
								  importValue: rawElement
								  of: (self loadTypeNamed: rawElement name))) ] ].
	^ collection
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importDictionary: rawValue of: type [
	"infer from type arguments, e.g. Map<String, MyClass>"

	| dictionary keyType valueType assoc |
	dictionary := self model newOfDictionary type: type.
	objectDict at: rawValue put: dictionary.

	(self parametricTypeInferencesOf: type)
		ifNotEmpty: [ :paramTypeInferences |
			keyType := paramTypeInferences at: 1.
			valueType := paramTypeInferences at: 2 ]
		ifEmpty: [ keyType := valueType := nil ].

	rawValue nodes
		reject: [ :node | node isStringNode ]
		thenDo: [ :entryNode |
			| nodes keyNode valueNode |
			assoc := self model newOfDictionaryAssociation dictionary:
				         dictionary.

			nodes := entryNode nodes reject: [ :node | node isStringNode ].
			nodes size = 2 ifFalse: [
				Error signal: 'Expected 2 nodes in a table entry' ].
			keyNode := nodes first.
			valueNode := nodes second.

			self withTypeInference: keyType do: [
				| nodeType |
				nodeType := keyNode name = 'string'
					            ifTrue: [ self loadTypeNamed: 'String' ]
					            ifFalse: [ self loadTypeNamed: keyNode name ].
				assoc key: (self importValue: keyNode of: nodeType) ].

			self withTypeInference: valueType do: [
				| nodeType |
				nodeType := valueNode name = 'string'
					            ifTrue: [ self loadTypeNamed: 'String' ]
					            ifFalse: [ self loadTypeNamed: valueNode name ].
				assoc value: (self importValue: valueNode of: nodeType) ] ].
	^ dictionary
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importObject: rawObject of: type [

	| object |
	object := self model newOfObject type: type.
	objectDict at: rawObject put: object.
	rawObject nodes
		reject: [ :node | node isStringNode ]
		thenDo: [ :node |
			(self importObjectAttribute: node of: type named: node name)
				ifNotNil: [ :attribute | attribute object: object ] ].
	^ object
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importObjectAttribute: rawValue of: type named: name [

	| attribute dimensions |
	attribute := type findAttributeNamed: name.
	dimensions := self findTypeDimensions: attribute.

	^ self withTypeInference: attribute declaredType do: [
		  self model newOfObjectAttribute
			  attribute: attribute;
			  value: (dimensions == 0
					   ifTrue: [ "regular type" self importValue: rawValue ]
					   ifFalse: [ "array type"
						   self
							   importArray: rawValue
							   of:
								   ((FamixValueJavaArray wrapping: attribute declaredType)
									    dimensions: dimensions) ]) ]
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importPrimitive: rawValue of: type [
	"Expect to be given a type name instead of a type!"

	^ self model newOfPrimitiveType
		  value: rawValue nodes first string;
		  type: type
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importValue: aXMLElement [

	| type |
	(aXMLElement attributeAt: 'reference') ifNotEmpty: [ :reference |
		^ self resolve: reference from: aXMLElement ].
	type := aXMLElement parent isDocument
		        ifTrue: [ self loadTypeNamed: aXMLElement name ]
		        ifFalse: [
			        (aXMLElement attributeAt: 'class')
				        ifNotEmpty: [ :className | self loadTypeNamed: className ]
				        ifEmpty: [ self loadType ] ].
	^ type value: aXMLElement asJavaXStreamValueOn: self
]

{ #category : 'importing' }
FamixValueJavaXStreamImporter >> importValue: aXMLElement of: type [

	(aXMLElement attributeAt: 'reference') ifNotEmpty: [ :reference |
		^ self resolve: reference from: aXMLElement ].
	^ type value: aXMLElement asJavaXStreamValueOn: self
]

{ #category : 'private - utility' }
FamixValueJavaXStreamImporter >> newReader [

	self shouldNotImplement
]

{ #category : 'parsing' }
FamixValueJavaXStreamImporter >> parseList: serializedValues [

	self halt
]

{ #category : 'parsing' }
FamixValueJavaXStreamImporter >> parseValue: serializedValue [
	"Parse and import a serialized value."

	^ (XMLDOMParser on: serializedValue readStream) parseDocument nodes
		  ifEmpty: [ Error signal: 'Empty data' ]
		  ifNotEmpty: [ :nodes |
			  nodes size = 1 ifFalse: [ Error signal: 'Multiple root nodes' ].
			  self importValue: nodes first ]
]

{ #category : 'as yet unclassified' }
FamixValueJavaXStreamImporter >> resolve: aString from: sourceNode [
	"Resolve a reference relative to the source node"

	| node |
	node := sourceNode.
	($/ split: aString) do: [ :path |
		path = '..'
			ifTrue: [ node := node parent ]
			ifFalse: [
				| index |
				index := path indexOf: $[.
				index > 0
					ifFalse: [ node := node elementAt: path ]
					ifTrue: [
						| name |
						name := path first: index - 1.
						index := (path copyFrom: index + 1 to: path size - 1) asInteger.
						node := (node nodes select: [ :n |
							         n isStringNode not and: [ n name = name ] ]) at: index ] ] ].
	^ self
		  getObjectFromIdentity: node
		  ifAbsent: [ Error signal: 'Failed to resolve reference' ]
]
