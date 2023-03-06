"
A value of an unknwon type.
"
Class {
	#name : #FamixValueOfUnknownType,
	#superclass : #FamixValueOfType,
	#traits : 'FamixValueTWithValueProperty',
	#classTraits : 'FamixValueTWithValueProperty classTrait',
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfUnknownType class >> annotation [

	<FMClass: #OfUnknownType super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^self
]

{ #category : #testing }
FamixValueOfUnknownType >> isOfUnknownType [

	<generated>
	^ true
]
