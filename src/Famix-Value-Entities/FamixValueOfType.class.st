"
Abstract superclass of all ValueOf_Type_ entities.
"
Class {
	#name : #FamixValueOfType,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#keyInDictionaries => FMMany type: #FamixValueOfDictionaryAssociation opposite: #key',
		'#valueInCollections => FMMany type: #FamixValueOfCollection opposite: #value',
		'#valueInDictionaries => FMMany type: #FamixValueOfDictionaryAssociation opposite: #value',
		'#valueInObjects => FMMany type: #FamixValueOfAttribute opposite: #value'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfType class >> annotation [

	<FMClass: #OfType super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixValueOfType >> addKeyInDictionary: anObject [
	<generated>
	^ self keyInDictionaries add: anObject
]

{ #category : #adding }
FamixValueOfType >> addValueInCollection: anObject [
	<generated>
	^ self valueInCollections add: anObject
]

{ #category : #adding }
FamixValueOfType >> addValueInDictionary: anObject [
	<generated>
	^ self valueInDictionaries add: anObject
]

{ #category : #adding }
FamixValueOfType >> addValueInObject: anObject [
	<generated>
	^ self valueInObjects add: anObject
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
	<FMProperty: #type type: #FamixTType opposite: #values>
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
	<FMProperty: #typedEntity type: #FamixTTypedEntity opposite: #values>
	^ self attributeAt: #typedEntity ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfType >> typedEntity: anObject [

	<generated>
	self attributeAt: #typedEntity put: (FMMultivalueLink on: self update: #values from: self typedEntity to: anObject).
]

{ #category : #accessing }
FamixValueOfType >> valueInCollections [
	"Relation named: #valueInCollections type: #FamixValueOfCollection opposite: #value"

	<generated>
	^ valueInCollections
]

{ #category : #accessing }
FamixValueOfType >> valueInCollections: anObject [

	<generated>
	valueInCollections value: anObject
]

{ #category : #accessing }
FamixValueOfType >> valueInDictionaries [
	"Relation named: #valueInDictionaries type: #FamixValueOfDictionaryAssociation opposite: #value"

	<generated>
	<derived>
	^ valueInDictionaries
]

{ #category : #accessing }
FamixValueOfType >> valueInDictionaries: anObject [

	<generated>
	valueInDictionaries value: anObject
]

{ #category : #accessing }
FamixValueOfType >> valueInObjects [
	"Relation named: #valueInObjects type: #FamixValueOfAttribute opposite: #value"

	<generated>
	<derived>
	^ valueInObjects
]

{ #category : #accessing }
FamixValueOfType >> valueInObjects: anObject [

	<generated>
	valueInObjects value: anObject
]
