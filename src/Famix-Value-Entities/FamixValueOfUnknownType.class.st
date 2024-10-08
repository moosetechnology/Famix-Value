"
A value of an unknwon type.

## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `value` | `Object` | nil | Value data represented as a native Smalltalk object.|

"
Class {
	#name : 'FamixValueOfUnknownType',
	#superclass : 'FamixValueOfType',
	#traits : 'FamixValueTWithValueProperty',
	#classTraits : 'FamixValueTWithValueProperty classTrait',
	#category : 'Famix-Value-Entities-Entities',
	#package : 'Famix-Value-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixValueOfUnknownType class >> annotation [

	<FMClass: #OfUnknownType super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : 'testing' }
FamixValueOfUnknownType >> isOfUnknownType [

	<generated>
	^ true
]
