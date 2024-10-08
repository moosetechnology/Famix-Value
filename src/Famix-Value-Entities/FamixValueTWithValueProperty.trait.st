"
My users have the value data represented by a Smalltalk object as a property.

## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `value` | `Object` | nil | Value data represented as a native Smalltalk object.|

"
Trait {
	#name : 'FamixValueTWithValueProperty',
	#instVars : [
		'#value => FMProperty'
	],
	#category : 'Famix-Value-Entities-Traits',
	#package : 'Famix-Value-Entities',
	#tag : 'Traits'
}

{ #category : 'meta' }
FamixValueTWithValueProperty classSide >> annotation [

	<FMClass: #TWithValueProperty super: #Object>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixValueTWithValueProperty >> value [

	<FMProperty: #value type: #Object>
	<generated>
	<FMComment: 'Value data represented as a native Smalltalk object.'>
	^ value
]

{ #category : 'accessing' }
FamixValueTWithValueProperty >> value: anObject [
	<generated>
	value := anObject
]
