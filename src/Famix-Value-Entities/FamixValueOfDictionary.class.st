"
A value of a dictionary type.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `value` | `FamixValueOfDictionary` | `dictionary` | `FamixValueOfDictionaryAssociation` | |



"
Class {
	#name : #FamixValueOfDictionary,
	#superclass : #FamixValueOfType,
	#instVars : [
		'#value => FMMany type: #FamixValueOfDictionaryAssociation opposite: #dictionary'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfDictionary class >> annotation [

	<FMClass: #OfDictionary super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixValueOfDictionary >> addValue: anObject [
	<generated>
	^ self value add: anObject
]

{ #category : #testing }
FamixValueOfDictionary >> isOfDictionary [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfDictionary >> value [
	"Relation named: #value type: #FamixValueOfDictionaryAssociation opposite: #dictionary"

	<generated>
	<derived>
	^ value
]

{ #category : #accessing }
FamixValueOfDictionary >> value: anObject [

	<generated>
	value value: anObject
]
