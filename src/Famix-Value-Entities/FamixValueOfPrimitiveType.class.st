"
A value of a primitive type.
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

{ #category : #testing }
FamixValueOfPrimitiveType >> isOfPrimitiveType [

	<generated>
	^ true
]
