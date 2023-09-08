"
A key-value pair belonging to a dictionary.
"
Class {
	#name : #FamixValueOfDictionaryAssociation,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#dictionary => FMOne type: #FamixValueOfDictionary opposite: #value',
		'#key => FMOne type: #FamixValueOfType opposite: #keyInDictionaries',
		'#value => FMOne type: #FamixValueOfType opposite: #valueInDictionaries'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfDictionaryAssociation class >> annotation [

	<FMClass: #OfDictionaryAssociation super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> dictionary [
	"Relation named: #dictionary type: #FamixValueOfDictionary opposite: #value"

	<generated>
	<container>
	^ dictionary
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> dictionary: anObject [

	<generated>
	dictionary := anObject
]

{ #category : #navigation }
FamixValueOfDictionaryAssociation >> dictionaryGroup [
	<generated>
	<navigation: 'Dictionary'>
	^ MooseSpecializedGroup with: self dictionary
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> key [
	"Relation named: #key type: #FamixValueOfType opposite: #keyInDictionaries"

	<generated>
	<source>
	^ key
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> key: anObject [

	<generated>
	key := anObject
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #valueInDictionaries"

	<generated>
	<source>
	^ value
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> value: anObject [

	<generated>
	value := anObject
]
