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
	^ self
]

{ #category : #visiting }
FamixValueUnknownType >> acceptValueVisitor: visitor forObject: object [

	self error: 'Exporting an unknown type is not (yet?) supported.'
]

{ #category : #converting }
FamixValueUnknownType >> asFASTJavaTypeExpressionOn: visitor [

	^ FASTBuilder current referType: self
]

{ #category : #testing }
FamixValueUnknownType >> isUnknownType [

	<generated>
	^ true
]
