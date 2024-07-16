"
A value of an object.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `value` | `FamixValueOfObject` | `object` | `FamixValueOfObjectAttribute` | |



"
Class {
	#name : #FamixValueOfObject,
	#superclass : #FamixValueOfType,
	#instVars : [
		'#value => FMMany type: #FamixValueOfObjectAttribute opposite: #object'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfObject class >> annotation [

	<FMClass: #OfObject super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixValueOfObject >> addValue: anObject [
	<generated>
	^ self value add: anObject
]

{ #category : #converting }
FamixValueOfObject >> asPharoInitializationAST [

	^ RBMessageNode
		  receiver: (RBVariableNode named: self type name)
		  selector: #new
]

{ #category : #testing }
FamixValueOfObject >> isOfObject [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfObject >> value [
	"Relation named: #value type: #FamixValueOfObjectAttribute opposite: #object"

	<generated>
	<derived>
	^ value
]

{ #category : #accessing }
FamixValueOfObject >> value: anObject [

	<generated>
	value value: anObject
]
