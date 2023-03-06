"
Abstract superclass of all ValueOf_Type_ entities.
"
Class {
	#name : #FamixValueOfType,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#keyInDictionary => FMOne type: #FamixValueOfDictionaryAssociation opposite: #key',
		'#valueInCollection => FMOne type: #FamixValueOfCollection opposite: #value',
		'#valueInDictionary => FMOne type: #FamixValueOfDictionaryAssociation opposite: #value',
		'#valueInObject => FMOne type: #FamixValueOfObject opposite: #value'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfType class >> annotation [

	<FMClass: #OfType super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^self
]

{ #category : #accessing }
FamixValueOfType >> keyInDictionary [
	"Relation named: #keyInDictionary type: #FamixValueOfDictionaryAssociation opposite: #key"

	<generated>
	<derived>
	^ keyInDictionary
]

{ #category : #accessing }
FamixValueOfType >> keyInDictionary: anObject [

	<generated>
	keyInDictionary := anObject
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
FamixValueOfType >> valueInCollection [
	"Relation named: #valueInCollection type: #FamixValueOfCollection opposite: #value"

	<generated>
	^ valueInCollection
]

{ #category : #accessing }
FamixValueOfType >> valueInCollection: anObject [

	<generated>
	valueInCollection := anObject
]

{ #category : #accessing }
FamixValueOfType >> valueInDictionary [
	"Relation named: #valueInDictionary type: #FamixValueOfDictionaryAssociation opposite: #value"

	<generated>
	<derived>
	^ valueInDictionary
]

{ #category : #accessing }
FamixValueOfType >> valueInDictionary: anObject [

	<generated>
	valueInDictionary := anObject
]

{ #category : #accessing }
FamixValueOfType >> valueInObject [
	"Relation named: #valueInObject type: #FamixValueOfObject opposite: #value"

	<generated>
	^ valueInObject
]

{ #category : #accessing }
FamixValueOfType >> valueInObject: anObject [

	<generated>
	valueInObject := anObject
]
