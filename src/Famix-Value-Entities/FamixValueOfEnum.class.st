"
A value of an enumeration.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `value` | `FamixValueOfEnum` | `valueReferences` | `FamixTEnumValue` | |



"
Class {
	#name : #FamixValueOfEnum,
	#superclass : #FamixValueOfType,
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfEnum class >> annotation [

	<FMClass: #OfEnum super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #testing }
FamixValueOfEnum >> isOfEnum [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfEnum >> value [
	"Relation named: #value type: #FamixTEnumValue opposite: #valueReferences"

	<generated>
	<FMProperty: #value type: #FamixTEnumValue opposite: #valueReferences>
	^ self attributeAt: #value ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfEnum >> value: anObject [

	<generated>
	self attributeAt: #value put: (FMMultivalueLink on: self update: #valueReferences from: self value to: anObject).
]
