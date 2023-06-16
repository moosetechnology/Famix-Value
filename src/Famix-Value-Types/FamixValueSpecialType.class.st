"
FamixValueSpecialType is an abstract superclass that represents a type in any programming language that requires custom handling due to its unique characteristics or serialization format.

These particular types are proxied using encapsulation, enabling customized importing and exporting mechanisms.

My subclasses are responsible for implementing the specific behavior required to handle special types in a particular language.
"
Class {
	#name : #FamixValueSpecialType,
	#superclass : #Object,
	#instVars : [
		'type'
	],
	#category : #'Famix-Value-Types'
}

{ #category : #'instance creation' }
FamixValueSpecialType class >> proxying: aFamixTType [

	^ self new type: aFamixTType
]

{ #category : #visiting }
FamixValueSpecialType >> acceptValueVisitor: visitor for: object [

	self subclassResponsibility
]

{ #category : #'reflective operations' }
FamixValueSpecialType >> doesNotUnderstand: aMessage [

	^ type perform: aMessage selector withArguments: aMessage arguments
]

{ #category : #accessing }
FamixValueSpecialType >> type [

	^ type
]

{ #category : #accessing }
FamixValueSpecialType >> type: aFamixTType [

	type := aFamixTType
]
