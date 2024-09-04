"
Abstract superclass of all ValueOf_Type_ entities.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `attributeInObjects` | `FamixValueOfType` | `value` | `FamixValueOfObjectAttribute` | |
| `elementInCollections` | `FamixValueOfType` | `value` | `FamixValueOfCollectionElement` | |
| `keyInDictionaries` | `FamixValueOfType` | `key` | `FamixValueOfDictionaryAssociation` | |
| `type` | `FamixValueOfType` | `values` | `FamixTType` | |
| `typedEntity` | `FamixValueOfType` | `values` | `FamixTTypedEntity` | |
| `valueInDictionaries` | `FamixValueOfType` | `value` | `FamixValueOfDictionaryAssociation` | |
| `variableInClosures` | `FamixValueOfType` | `value` | `FamixValueOfClosureVariable` | |



"
Class {
	#name : 'FamixValueOfType',
	#superclass : 'FamixValueEntity',
	#instVars : [
		'#attributeInObjects => FMMany type: #FamixValueOfObjectAttribute opposite: #value',
		'#elementInCollections => FMMany type: #FamixValueOfCollectionElement opposite: #value',
		'#keyInDictionaries => FMMany type: #FamixValueOfDictionaryAssociation opposite: #key',
		'#valueInDictionaries => FMMany type: #FamixValueOfDictionaryAssociation opposite: #value',
		'#variableInClosures => FMMany type: #FamixValueOfClosureVariable opposite: #value'
	],
	#category : 'Famix-Value-Entities-Entities',
	#package : 'Famix-Value-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixValueOfType class >> annotation [

	<FMClass: #OfType super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	<abstract>
	^ self
]

{ #category : 'testing' }
FamixValueOfType class >> isAbstract [

	<generated>
	^ self == FamixValueOfType
]

{ #category : 'adding' }
FamixValueOfType >> addAttributeInObject: anObject [
	<generated>
	^ self attributeInObjects add: anObject
]

{ #category : 'adding' }
FamixValueOfType >> addElementInCollection: anObject [
	<generated>
	^ self elementInCollections add: anObject
]

{ #category : 'adding' }
FamixValueOfType >> addKeyInDictionary: anObject [
	<generated>
	^ self keyInDictionaries add: anObject
]

{ #category : 'adding' }
FamixValueOfType >> addValueInDictionary: anObject [
	<generated>
	^ self valueInDictionaries add: anObject
]

{ #category : 'adding' }
FamixValueOfType >> addVariableInClosure: anObject [
	<generated>
	^ self variableInClosures add: anObject
]

{ #category : 'accessing' }
FamixValueOfType >> attributeInObjects [
	"Relation named: #attributeInObjects type: #FamixValueOfObjectAttribute opposite: #value"

	<generated>
	<derived>
	^ attributeInObjects
]

{ #category : 'accessing' }
FamixValueOfType >> attributeInObjects: anObject [

	<generated>
	attributeInObjects value: anObject
]

{ #category : 'accessing' }
FamixValueOfType >> elementInCollections [
	"Relation named: #elementInCollections type: #FamixValueOfCollectionElement opposite: #value"

	<generated>
	<derived>
	^ elementInCollections
]

{ #category : 'accessing' }
FamixValueOfType >> elementInCollections: anObject [

	<generated>
	elementInCollections value: anObject
]

{ #category : 'testing' }
FamixValueOfType >> isOfType [

	<generated>
	^ true
]

{ #category : 'accessing' }
FamixValueOfType >> keyInDictionaries [
	"Relation named: #keyInDictionaries type: #FamixValueOfDictionaryAssociation opposite: #key"

	<generated>
	<derived>
	^ keyInDictionaries
]

{ #category : 'accessing' }
FamixValueOfType >> keyInDictionaries: anObject [

	<generated>
	keyInDictionaries value: anObject
]

{ #category : 'accessing' }
FamixValueOfType >> type [
	"Relation named: #type type: #FamixTType opposite: #values"

	<generated>
	<FMProperty: #type type: #FamixTType opposite: #values>
	^ self attributeAt: #type ifAbsent: [ nil ]
]

{ #category : 'accessing' }
FamixValueOfType >> type: anObject [

	<generated>
	self attributeAt: #type put: (FMMultivalueLink on: self update: #values from: self type to: anObject).
]

{ #category : 'accessing' }
FamixValueOfType >> typedEntity [
	"Relation named: #typedEntity type: #FamixTTypedEntity opposite: #values"

	<generated>
	<FMProperty: #typedEntity type: #FamixTTypedEntity opposite: #values>
	^ self attributeAt: #typedEntity ifAbsent: [ nil ]
]

{ #category : 'accessing' }
FamixValueOfType >> typedEntity: anObject [

	<generated>
	self attributeAt: #typedEntity put: (FMMultivalueLink on: self update: #values from: self typedEntity to: anObject).
]

{ #category : 'accessing' }
FamixValueOfType >> valueInDictionaries [
	"Relation named: #valueInDictionaries type: #FamixValueOfDictionaryAssociation opposite: #value"

	<generated>
	<derived>
	^ valueInDictionaries
]

{ #category : 'accessing' }
FamixValueOfType >> valueInDictionaries: anObject [

	<generated>
	valueInDictionaries value: anObject
]

{ #category : 'accessing' }
FamixValueOfType >> variableInClosures [
	"Relation named: #variableInClosures type: #FamixValueOfClosureVariable opposite: #value"

	<generated>
	<derived>
	^ variableInClosures
]

{ #category : 'accessing' }
FamixValueOfType >> variableInClosures: anObject [

	<generated>
	variableInClosures value: anObject
]
