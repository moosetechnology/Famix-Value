"
A reference to a type.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `value` | `FamixValueOfTypeReference` | `valueReferences` | `FamixTType` | |



"
Class {
	#name : 'FamixValueOfTypeReference',
	#superclass : 'FamixValueOfType',
	#category : 'Famix-Value-Entities-Entities',
	#package : 'Famix-Value-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixValueOfTypeReference class >> annotation [

	<FMClass: #OfTypeReference super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : 'testing' }
FamixValueOfTypeReference >> isOfTypeReference [

	<generated>
	^ true
]

{ #category : 'accessing' }
FamixValueOfTypeReference >> value [
	"Relation named: #value type: #FamixTType opposite: #valueReferences"

	<generated>
	<FMProperty: #value type: #FamixTType opposite: #valueReferences>
	^ self attributeAt: #value ifAbsent: [ nil ]
]

{ #category : 'accessing' }
FamixValueOfTypeReference >> value: anObject [

	<generated>
	self attributeAt: #value put: (FMMultivalueLink on: self update: #valueReferences from: self value to: anObject).
]
