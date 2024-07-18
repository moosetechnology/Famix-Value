"
A reference to a class.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `value` | `FamixValueOfClassReference` | `valueReferences` | `FamixTClass` | |



"
Class {
	#name : #FamixValueOfClassReference,
	#superclass : #FamixValueOfType,
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfClassReference class >> annotation [

	<FMClass: #OfClassReference super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #testing }
FamixValueOfClassReference >> isOfClassReference [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfClassReference >> value [
	"Relation named: #value type: #FamixTClass opposite: #valueReferences"

	<generated>
	<FMProperty: #value type: #FamixTClass opposite: #valueReferences>
	^ self attributeAt: #value ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfClassReference >> value: anObject [

	<generated>
	self attributeAt: #value put: (FMMultivalueLink on: self update: #valueReferences from: self value to: anObject).
]
