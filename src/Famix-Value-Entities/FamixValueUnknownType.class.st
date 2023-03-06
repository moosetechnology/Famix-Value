"
An unknown type.
"
Class {
	#name : #FamixValueUnknownType,
	#superclass : #FamixValueEntity,
	#traits : 'FamixTType',
	#classTraits : 'FamixTType classTrait',
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueUnknownType class >> annotation [

	<FMClass: #UnknownType super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^self
]

{ #category : #testing }
FamixValueUnknownType >> isUnknownType [

	<generated>
	^ true
]
