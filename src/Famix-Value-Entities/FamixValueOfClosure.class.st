"
A lexical closure.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `variables` | `FamixValueOfClosure` | `closure` | `FamixValueOfClosureVariable` | |


## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `sourceCode` | `String` | nil | The source code of the lexical closure.|

"
Class {
	#name : 'FamixValueOfClosure',
	#superclass : 'FamixValueOfType',
	#instVars : [
		'#sourceCode => FMProperty',
		'#variables => FMMany type: #FamixValueOfClosureVariable opposite: #closure'
	],
	#category : 'Famix-Value-Entities-Entities',
	#package : 'Famix-Value-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixValueOfClosure class >> annotation [

	<FMClass: #OfClosure super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : 'adding' }
FamixValueOfClosure >> addVariable: anObject [
	<generated>
	^ self variables add: anObject
]

{ #category : 'testing' }
FamixValueOfClosure >> isOfClosure [

	<generated>
	^ true
]

{ #category : 'accessing' }
FamixValueOfClosure >> sourceCode [

	<FMProperty: #sourceCode type: #String>
	<generated>
	<FMComment: 'The source code of the lexical closure.'>
	^ sourceCode
]

{ #category : 'accessing' }
FamixValueOfClosure >> sourceCode: anObject [
	<generated>
	sourceCode := anObject
]

{ #category : 'accessing' }
FamixValueOfClosure >> variables [
	"Relation named: #variables type: #FamixValueOfClosureVariable opposite: #closure"

	<generated>
	<derived>
	^ variables
]

{ #category : 'accessing' }
FamixValueOfClosure >> variables: anObject [

	<generated>
	variables value: anObject
]
