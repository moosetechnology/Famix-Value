"
A key-value pair of values belonging to a dictionary.
"
Class {
	#name : #FamixValueOfDictionaryAssociation,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#dictionary => FMOne type: #FamixValueOfDictionary opposite: #value',
		'#key => FMOne type: #FamixValueOfType opposite: #keyInDictionary',
		'#value => FMOne type: #FamixValueOfType opposite: #valueInDictionary'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfDictionaryAssociation class >> annotation [

	<FMClass: #OfDictionaryAssociation super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^self
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> dictionary [
	"Relation named: #dictionary type: #FamixValueOfDictionary opposite: #value"

	<generated>
	^ dictionary
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> dictionary: anObject [

	<generated>
	dictionary := anObject
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> key [
	"Relation named: #key type: #FamixValueOfType opposite: #keyInDictionary"

	<generated>
	^ key
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> key: anObject [

	<generated>
	key := anObject
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #valueInDictionary"

	<generated>
	^ value
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> value: anObject [

	<generated>
	value := anObject
]
