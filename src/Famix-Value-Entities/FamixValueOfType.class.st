"
Abstract superclass of all ValueOf_Type_ entities.
"
Class {
	#name : #FamixValueOfType,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#attributeInObjects => FMMany type: #FamixValueOfObjectAttribute opposite: #value',
		'#elementInCollections => FMMany type: #FamixValueOfCollectionElement opposite: #value',
		'#keyInDictionaries => FMMany type: #FamixValueOfDictionaryAssociation opposite: #key',
		'#valueInDictionaries => FMMany type: #FamixValueOfDictionaryAssociation opposite: #value'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfType class >> annotation [

	<FMClass: #OfType super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	<abstract>
	^ self
]

{ #category : #testing }
FamixValueOfType class >> isAbstract [

	<generated>
	^ self == FamixValueOfType
]

{ #category : #adding }
FamixValueOfType >> addAttributeInObject: anObject [
	<generated>
	^ self attributeInObjects add: anObject
]

{ #category : #adding }
FamixValueOfType >> addElementInCollection: anObject [
	<generated>
	^ self elementInCollections add: anObject
]

{ #category : #adding }
FamixValueOfType >> addKeyInDictionary: anObject [
	<generated>
	^ self keyInDictionaries add: anObject
]

{ #category : #adding }
FamixValueOfType >> addValueInDictionary: anObject [
	<generated>
	^ self valueInDictionaries add: anObject
]

{ #category : #accessing }
FamixValueOfType >> attributeInObjects [
	"Relation named: #attributeInObjects type: #FamixValueOfObjectAttribute opposite: #value"

	<generated>
	<derived>
	<target>
	^ attributeInObjects
]

{ #category : #accessing }
FamixValueOfType >> attributeInObjects: anObject [

	<generated>
	attributeInObjects value: anObject
]

{ #category : #accessing }
FamixValueOfType >> elementInCollections [
	"Relation named: #elementInCollections type: #FamixValueOfCollectionElement opposite: #value"

	<generated>
	<derived>
	<target>
	^ elementInCollections
]

{ #category : #accessing }
FamixValueOfType >> elementInCollections: anObject [

	<generated>
	elementInCollections value: anObject
]

{ #category : #testing }
FamixValueOfType >> isOfType [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfType >> keyInDictionaries [
	"Relation named: #keyInDictionaries type: #FamixValueOfDictionaryAssociation opposite: #key"

	<generated>
	<derived>
	<target>
	^ keyInDictionaries
]

{ #category : #accessing }
FamixValueOfType >> keyInDictionaries: anObject [

	<generated>
	keyInDictionaries value: anObject
]

{ #category : #accessing }
FamixValueOfType >> type [
	"Relation named: #type type: #FamixTType opposite: #values"

	<generated>
	<source>
	<FMProperty: #type type: #FamixTType opposite: #values>
	<package: #'Famix-UnitTest-Entities'>
	^ self attributeAt: #type ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfType >> type: anObject [

	<generated>
	self attributeAt: #type put: (FMMultivalueLink on: self update: #values from: self type to: anObject).
]

{ #category : #accessing }
FamixValueOfType >> typedEntity [
	"Relation named: #typedEntity type: #FamixTTypedEntity opposite: #values"

	<generated>
	<source>
	<FMProperty: #typedEntity type: #FamixTTypedEntity opposite: #values>
	<package: #'Famix-UnitTest-Entities'>
	^ self attributeAt: #typedEntity ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfType >> typedEntity: anObject [

	<generated>
	self attributeAt: #typedEntity put: (FMMultivalueLink on: self update: #values from: self typedEntity to: anObject).
]

{ #category : #accessing }
FamixValueOfType >> valueInDictionaries [
	"Relation named: #valueInDictionaries type: #FamixValueOfDictionaryAssociation opposite: #value"

	<generated>
	<derived>
	<target>
	^ valueInDictionaries
]

{ #category : #accessing }
FamixValueOfType >> valueInDictionaries: anObject [

	<generated>
	valueInDictionaries value: anObject
]
