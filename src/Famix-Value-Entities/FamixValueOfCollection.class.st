"
A value of a collection type.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `value` | `FamixValueOfCollection` | `collection` | `FamixValueOfCollectionElement` | |



"
Class {
	#name : #FamixValueOfCollection,
	#superclass : #FamixValueOfType,
	#instVars : [
		'#value => FMMany type: #FamixValueOfCollectionElement opposite: #collection'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfCollection class >> annotation [

	<FMClass: #OfCollection super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixValueOfCollection >> addValue: anObject [
	<generated>
	^ self value add: anObject
]

{ #category : #converting }
FamixValueOfCollection >> asPharoInitializationAST [

	^ RBMessageNode
		  receiver: (RBVariableNode named: self type name)
		  selector: #basicNew
]

{ #category : #testing }
FamixValueOfCollection >> isOfCollection [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfCollection >> value [
	"Relation named: #value type: #FamixValueOfCollectionElement opposite: #collection"

	<generated>
	<derived>
	^ value
]

{ #category : #accessing }
FamixValueOfCollection >> value: anObject [

	<generated>
	value value: anObject
]
