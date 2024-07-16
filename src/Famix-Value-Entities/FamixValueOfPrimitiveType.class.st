"
A value of a primitive type.

## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `value` | `Object` | nil | Value data represented as a native Smalltalk object.|

"
Class {
	#name : #FamixValueOfPrimitiveType,
	#superclass : #FamixValueOfType,
	#traits : 'FamixValueTWithValueProperty',
	#classTraits : 'FamixValueTWithValueProperty classTrait',
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfPrimitiveType class >> annotation [

	<FMClass: #OfPrimitiveType super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #converting }
FamixValueOfPrimitiveType >> asPharoInitializationAST [

	^ RBLiteralNode value: self value
]

{ #category : #testing }
FamixValueOfPrimitiveType >> isOfPrimitiveType [

	<generated>
	^ true
]
