"
An attribute belonging to an object.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `attribute` | `FamixValueOfObjectAttribute` | `valueInObjects` | `FamixTAttribute` | |
| `object` | `FamixValueOfObjectAttribute` | `value` | `FamixValueOfObject` | |
| `value` | `FamixValueOfObjectAttribute` | `attributeInObjects` | `FamixValueOfType` | |



"
Class {
	#name : #FamixValueOfObjectAttribute,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#object => FMOne type: #FamixValueOfObject opposite: #value',
		'#value => FMOne type: #FamixValueOfType opposite: #attributeInObjects'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfObjectAttribute class >> annotation [

	<FMClass: #OfObjectAttribute super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> attribute [
	"Relation named: #attribute type: #FamixTAttribute opposite: #valueInObjects"

	<generated>
	<FMProperty: #attribute type: #FamixTAttribute opposite: #valueInObjects>
	^ self attributeAt: #attribute ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> attribute: anObject [

	<generated>
	self attributeAt: #attribute put: (FMMultivalueLink on: self update: #valueInObjects from: self attribute to: anObject).
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> object [
	"Relation named: #object type: #FamixValueOfObject opposite: #value"

	<generated>
	^ object
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> object: anObject [

	<generated>
	object := anObject
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #attributeInObjects"

	<generated>
	^ value
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> value: anObject [

	<generated>
	value := anObject
]

{ #category : #generate }
FamixValueOfObjectAttribute >> varName [

	^ self attribute
		  ifNotNil: [ :attribute | attribute name ]
		  ifNil: [ value varName ]
]
