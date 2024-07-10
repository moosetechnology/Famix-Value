"
A variable binding in a lexical closure.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `closure` | `FamixValueOfClosureVariable` | `variables` | `FamixValueOfClosure` | |
| `value` | `FamixValueOfClosureVariable` | `variableInClosures` | `FamixValueOfType` | |


## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `name` | `String` | nil | Name of the variable bound to the closure.|

"
Class {
	#name : #FamixValueOfClosureVariable,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#name => FMProperty',
		'#closure => FMOne type: #FamixValueOfClosure opposite: #variables',
		'#value => FMOne type: #FamixValueOfType opposite: #variableInClosures'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfClosureVariable class >> annotation [

	<FMClass: #OfClosureVariable super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfClosureVariable >> closure [
	"Relation named: #closure type: #FamixValueOfClosure opposite: #variables"

	<generated>
	^ closure
]

{ #category : #accessing }
FamixValueOfClosureVariable >> closure: anObject [

	<generated>
	closure := anObject
]

{ #category : #accessing }
FamixValueOfClosureVariable >> name [

	<FMProperty: #name type: #String>
	<generated>
	<FMComment: 'Name of the variable bound to the closure.'>
	^ name
]

{ #category : #accessing }
FamixValueOfClosureVariable >> name: anObject [
	<generated>
	name := anObject
]

{ #category : #accessing }
FamixValueOfClosureVariable >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #variableInClosures"

	<generated>
	^ value
]

{ #category : #accessing }
FamixValueOfClosureVariable >> value: anObject [

	<generated>
	value := anObject
]

{ #category : #generate }
FamixValueOfClosureVariable >> varName [

	^ name
]
