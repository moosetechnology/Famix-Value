"
FamixValueSpecialClass represents a class that requires custom handling due to its unique characteristics or serialization format.

My subclasses are responsible for implementing the specific behavior required to handle special classes in a particular language.
"
Class {
	#name : 'FamixValueSpecialClass',
	#superclass : 'FamixValueSpecialType',
	#category : 'Famix-Value-Types',
	#package : 'Famix-Value-Types'
}

{ #category : 'testing' }
FamixValueSpecialClass class >> isAbstract [

	^ self == FamixValueSpecialClass
]
