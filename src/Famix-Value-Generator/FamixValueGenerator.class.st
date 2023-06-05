"
I generate entities to modelize runtime values.
Each value entity has a relation with its type (`FamixTType` subtraits) and has a specific way to hold the value data:
- instances contain values as attributes,
- enum values are expressed with a relation to `FamixTEnumValue`,
- primitives are expressed using Smalltalk primitives.
They can also have a relation with a typed entity (`FamixTTypedEntity`) to represent an affectation.
"
Class {
	#name : #FamixValueGenerator,
	#superclass : #FamixMetamodelGenerator,
	#instVars : [
		'value',
		'primitive',
		'object',
		'enumValue',
		'collection',
		'dictionary',
		'dictionaryAssociation',
		'ofUnknownType',
		'unknownType',
		'tWithValueProperty',
		'tType',
		'collectionElement',
		'objectAttribute'
	],
	#category : #'Famix-Value-Generator'
}

{ #category : #accessing }
FamixValueGenerator class >> packageName [

	<ignoreForCoverage>
	^ #'Famix-Value-Entities'
]

{ #category : #accessing }
FamixValueGenerator class >> prefix [

	<ignoreForCoverage>
	^ #FamixValue
]

{ #category : #accessing }
FamixValueGenerator class >> submetamodels [

	^ { FamixGenerator }
]

{ #category : #definition }
FamixValueGenerator >> defineClasses [

	value := (builder
		          newClassNamed: #OfType
		          comment:
			          'Abstract superclass of all ValueOf_Type_ entities.')
		         isAbstractClass: true;
		         withTesting.
	object := (builder
		           newClassNamed: #OfObject
		           comment: 'A value of an object.') withTesting.
	objectAttribute := builder
		                   newClassNamed: #OfObjectAttribute
		                   comment: 'An attribute belonging to an object.'.
	primitive := (builder
		              newClassNamed: #OfPrimitiveType
		              comment: 'A value of a primitive type.') withTesting.
	enumValue := (builder
		              newClassNamed: #OfEnum
		              comment: 'A value of an enumeration.') withTesting.
	collection := (builder
		               newClassNamed: #OfCollection
		               comment: 'A value of a collection type.') withTesting.
	collectionElement := builder
		                     newClassNamed: #OfCollectionElement
		                     comment:
		                     'An element belonging to a collection.'.
	dictionary := (builder
		               newClassNamed: #OfDictionary
		               comment: 'A value of a dictionary type.') withTesting.

	dictionaryAssociation := builder
		                         newClassNamed: #OfDictionaryAssociation
		                         comment:
		                         'A key-value pair belonging to a dictionary.'.
	ofUnknownType := (builder
		                  newClassNamed: #OfUnknownType
		                  comment: 'A value of an unknwon type.')
		                 withTesting.
	unknownType := (builder
		                newClassNamed: #UnknownType
		                comment: 'An unknown type.') withTesting
]

{ #category : #definition }
FamixValueGenerator >> defineHierarchy [

	object --|> value.
	primitive --|> value.
	enumValue --|> value.
	collection --|> value.
	dictionary --|> value.
	ofUnknownType --|> value.

	primitive --|> tWithValueProperty.
	ofUnknownType --|> tWithValueProperty.

	unknownType --|> tType
]

{ #category : #definition }
FamixValueGenerator >> defineProperties [

	(tWithValueProperty property: #value type: #Object) comment:
		'Value data represented as a native Smalltalk object.'
]

{ #category : #definition }
FamixValueGenerator >> defineRelations [

	value *- (tType property: #values).
	value
	*- ((self remoteTrait: #TTypedEntity withPrefix: #Famix) property:
			 #values).

	(object property: #value) -* (objectAttribute property: #object).
	(objectAttribute property: #value)
	*- (value property: #attributeInObjects).
	(objectAttribute property: #attribute)
	*- ((self remoteTrait: #TAttribute withPrefix: #Famix) property:
			 #valueInObjects).

	(enumValue property: #value)
	*- ((self remoteTrait: #TEnumValue withPrefix: #Famix) property:
			 #valueReferences).

	(collection property: #value)
	-* (collectionElement property: #collection).
	(collectionElement property: #value)
	*- (value property: #elementInCollections).

	(dictionary property: #value)
	-* (dictionaryAssociation property: #dictionary).
	(dictionaryAssociation property: #key)
	*- (value property: #keyInDictionaries).
	(dictionaryAssociation property: #value)
	*- (value property: #valueInDictionaries)
]

{ #category : #definition }
FamixValueGenerator >> defineTraits [

	tWithValueProperty := builder
		                      newTraitNamed: #TWithValueProperty
		                      comment:
		                      'My users have the value data represented by a Smalltalk object as a property.'.

	tType := self remoteTrait: #TType withPrefix: #Famix
]
