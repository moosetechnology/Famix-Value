"
A lexical closure.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `value` | `FamixValueOfClosure` | `closure` | `FamixValueOfType` | |


## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `value` | `Object` | nil | Value data represented as a native Smalltalk object.|

"
Class {
	#name : #FamixValueOfClosure,
	#superclass : #FamixValueOfType,
	#traits : 'FamixValueTWithValueProperty',
	#classTraits : 'FamixValueTWithValueProperty classTrait',
	#instVars : [
		'#value => FMOne type: #FamixValueOfType opposite: #closure'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfClosure class >> annotation [

	<FMClass: #OfClosure super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfClosure >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #closure"

	<generated>
	^ value
]

{ #category : #accessing }
FamixValueOfClosure >> value: anObject [

	<generated>
	value := anObject
]
