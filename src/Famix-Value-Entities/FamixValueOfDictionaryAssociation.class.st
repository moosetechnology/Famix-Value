"
A key-value pair belonging to a dictionary.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `dictionary` | `FamixValueOfDictionaryAssociation` | `value` | `FamixValueOfDictionary` | |
| `key` | `FamixValueOfDictionaryAssociation` | `keyInDictionaries` | `FamixValueOfType` | |
| `value` | `FamixValueOfDictionaryAssociation` | `valueInDictionaries` | `FamixValueOfType` | |



"
Class {
	#name : #FamixValueOfDictionaryAssociation,
	#superclass : #FamixValueOfType,
	#instVars : [
		'#dictionary => FMOne type: #FamixValueOfDictionary opposite: #value',
		'#key => FMOne type: #FamixValueOfType opposite: #keyInDictionaries',
		'#value => FMOne type: #FamixValueOfType opposite: #valueInDictionaries'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfDictionaryAssociation class >> annotation [

	<FMClass: #OfDictionaryAssociation super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
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
	"Relation named: #key type: #FamixValueOfType opposite: #keyInDictionaries"

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
	"Relation named: #value type: #FamixValueOfType opposite: #valueInDictionaries"

	<generated>
	^ value
]

{ #category : #accessing }
FamixValueOfDictionaryAssociation >> value: anObject [

	<generated>
	value := anObject
]
