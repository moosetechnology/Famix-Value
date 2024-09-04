Class {
	#name : 'FamixValuePharoJacksonImporter',
	#superclass : 'FamixValueAbstractImporter',
	#instVars : [
		'typeKey',
		'idKey',
		'refKey',
		'specialTypes',
		'closureSources'
	],
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'enumerating' }
FamixValuePharoJacksonImporter >> getDefaultUnknownType [

	^ self getUnknownTypeNamed: 'Object'
]

{ #category : 'enumerating' }
FamixValuePharoJacksonImporter >> getObjectIdentity: rawObject [
	"Keep track of objects by using the id given by Jackson.
	References to previously seen objects are serialized by using this id."

	^ rawObject removeKey: self idKey ifAbsent: nil
]

{ #category : 'enumerating' }
FamixValuePharoJacksonImporter >> getObjectReference: rawObject [

	^ rawObject removeKey: self refKey ifAbsent: nil
]

{ #category : 'enumerating' }
FamixValuePharoJacksonImporter >> getObjectType: rawObject [

	^ rawObject removeKey: self typeKey ifAbsent: nil
]

{ #category : 'accessing' }
FamixValuePharoJacksonImporter >> idKey [

	^ idKey ifNil: [ idKey := '@id' ]
]

{ #category : 'accessing' }
FamixValuePharoJacksonImporter >> idKey: aString [

	idKey := aString
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importArray: rawValue of: type [

	^ objectDict
		  at: rawValue first
		  ifAbsentPut: [
		  super importCollection: rawValue allButFirst of: type ]
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importAssociation: rawValue of: type [

	| association |
	association := self model newOfDictionaryAssociation type: type.
	objectDict at: (self getObjectIdentity: rawValue) put: association.
	association key: (self importValue: (rawValue at: 'key')).
	association value: (self importValue: (rawValue at: 'value')).
	^ association
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importCharacter: value of: type [

	^ self importPrimitive: (value at: 'value') asCharacter of: type name
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importClosure: value of: type [

	| closure compiledBlock source |
	compiledBlock := value at: 'compiledBlock'.
	source := compiledBlock
		          at: '@ref'
		          ifPresent: [ :id | closureSources at: id ]
		          ifAbsent: [
			          closureSources
				          at: (self getObjectIdentity: compiledBlock)
				          put: (compiledBlock at: 'source') ].
	closure := self model newOfClosure
		           type: type;
		           sourceCode: source.
	value at: 'vars' ifPresent: [ :vars |
		vars associationsDo: [ :assoc |
			closure addVariable: (self model newOfClosureVariable
					 name: assoc key;
					 value: (self importValue: assoc value)) ] ].
	^ closure
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importCollection: rawValue of: type [

	| collection |
	collection := self model newOfCollection type: type.
	objectDict at: (self getObjectIdentity: rawValue) put: collection.
	(rawValue at: '@') do: [ :rawElement |
		collection addValue: (self model newOfCollectionElement value:
				 (self importValue: rawElement)) ].
	^ collection
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importDictionary: rawValue of: type [

	| dictionary |
	dictionary := self model newOfDictionary type: type.
	objectDict at: (self getObjectIdentity: rawValue) put: dictionary.
	(rawValue at: '@') do: [ :rawAssoc |
		(rawAssoc asPharoJacksonValueOn: self) dictionary: dictionary ].
	^ dictionary
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importObject: rawObject of: type [

	self specialTypes
		at: type name
		ifPresent: [ :block | ^ block value: rawObject value: type ].
	^ super importObject: rawObject of: type
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importObjectAttribute: rawValue of: type named: name [

	name = '@' ifFalse: [ "regular attribute"
		^ super importObjectAttribute: rawValue of: type named: name ].
	"The object is indexable *and* has instance variables.
	There is nothing to represent this in the Value model (yet), so instead use a placeholder attribute with a collection."
	^ self model newOfObjectAttribute
		  attribute: (FamixStAttribute named: '@');
		  value:
			  (model newOfCollection value: (rawValue collect: [ :rawElement |
							    model newOfCollectionElement value:
									    (self importValue: rawElement) ]))
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importSymbol: rawObject of: type [

	^ objectDict
		  at: (self getObjectIdentity: rawObject)
		  put: (self model newOfPrimitiveType
				   value: (rawObject at: 'value') asSymbol;
				   type: type)
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importTypeReference: rawValue of: type [
	"The type has already been loaded during the inference.
	The raw value contains the fully qualified name of the referenced class."

	^ self model newOfTypeReference
		  value: (self loadTypeNamed: (rawValue at: 'name'));
		  type: type
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> importValue: rawValue [

	^ rawValue asPharoJacksonValueOn: self
]

{ #category : 'initialization' }
FamixValuePharoJacksonImporter >> initialize [

	super initialize.

	closureSources := Dictionary new
]

{ #category : 'importing' }
FamixValuePharoJacksonImporter >> newReader [

	^ super newReader.
	"^ STONReader new acceptUnknownClasses: true"
]

{ #category : 'parsing' }
FamixValuePharoJacksonImporter >> parseList: serializedValues [
	"Ignore first element which is the id of the array."

	^ (super parseList: serializedValues) allButFirst
]

{ #category : 'accessing' }
FamixValuePharoJacksonImporter >> refKey [

	^ refKey ifNil: [ refKey := '@ref' ]
]

{ #category : 'accessing' }
FamixValuePharoJacksonImporter >> refKey: aString [

	refKey := aString
]

{ #category : 'accessing' }
FamixValuePharoJacksonImporter >> specialTypes [

	^ specialTypes ifNil: [
		  specialTypes := Dictionary new.
		  specialTypes
			  at: 'Character'
			  put: [ :value :type | self importCharacter: value of: type ].
		  specialTypes
			  at: 'Association'
			  put: [ :value :type | self importAssociation: value of: type ].
		  specialTypes
			  at: 'OrderedCollection'
			  put: [ :value :type | self importCollection: value of: type ].
		  specialTypes
			  at: 'Set'
			  put: [ :value :type | self importCollection: value of: type ].
			  specialTypes
			  at: 'ConstantBlockClosure'
			  put: [ :value :type | self importClosure: value of: type ].  specialTypes
			  at: 'CleanBlockClosure'
			  put: [ :value :type | self importClosure: value of: type ].
		  specialTypes
			  at: 'FullBlockClosure'
			  put: [ :value :type | self importClosure: value of: type ].
		  specialTypes
			  at: 'ByteSymbol'
			  put: [ :value :type | self importSymbol: value of: type ].
		  specialTypes
			  at: 'WideSymbol'
			  put: [ :value :type | self importSymbol: value of: type ].
		  specialTypes
			  at: 'Dictionary'
			  put: [ :value :type | self importDictionary: value of: type ].
		  specialTypes
			  at: 'OrderedDictionary'
			  put: [ :value :type | self importDictionary: value of: type ].
		  specialTypes ]
]

{ #category : 'accessing' }
FamixValuePharoJacksonImporter >> typeKey [

	^ typeKey ifNil: [ typeKey := '@type' ]
]

{ #category : 'accessing' }
FamixValuePharoJacksonImporter >> typeKey: aString [

	typeKey := aString
]
