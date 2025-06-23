"
FamixValueSpecialType is an abstract superclass that represents a type in any programming language that requires custom handling due to its unique characteristics or serialization format.

These special types are wrapped using encapsulation, allowing for custom import and export mechanisms.

My subclasses are responsible for implementing the specific behavior required to handle special types in a particular language.
"
Class {
	#name : 'FamixValueSpecialType',
	#superclass : 'Object',
	#instVars : [
		'type'
	],
	#category : 'Famix-Value-Types',
	#package : 'Famix-Value-Types'
}

{ #category : 'instance creation' }
FamixValueSpecialType class >> import: rawValue wrapping: type on: importer [
	"Wrap an object and use custom import mechanism."

	^ (self new type: type) import: rawValue on: importer
]

{ #category : 'testing' }
FamixValueSpecialType class >> isAbstract [

	^ self == FamixValueSpecialType
]

{ #category : 'instance creation' }
FamixValueSpecialType class >> wrapping: aFamixTType [
	"Wrap an object for custom import/export mechanisms."

	^ self new type: aFamixTType
]

{ #category : 'reflective operations' }
FamixValueSpecialType >> doesNotUnderstand: aMessage [
	"Defer to the wrapped type."

	^ type perform: aMessage selector withArguments: aMessage arguments
]

{ #category : 'importing' }
FamixValueSpecialType >> import: rawValue on: importer [

	self subclassResponsibility
]

{ #category : 'printing' }
FamixValueSpecialType >> mooseName [

	^ type mooseName
]

{ #category : 'accessing' }
FamixValueSpecialType >> type [

	^ type
]

{ #category : 'accessing' }
FamixValueSpecialType >> type: aFamixTType [

	type := aFamixTType
]
