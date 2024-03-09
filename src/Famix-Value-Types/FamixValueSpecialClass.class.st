"
FamixValueSpecialClass represents a class that requires custom handling due to its unique characteristics or serialization format.

My subclasses are responsible for implementing the specific behavior required to handle special classes in a particular language.
"
Class {
	#name : #FamixValueSpecialClass,
	#superclass : #FamixValueSpecialType,
	#category : #'Famix-Value-Types'
}

{ #category : #testing }
FamixValueSpecialClass class >> isAbstract [

	^ self == FamixValueSpecialClass
]

{ #category : #importing }
FamixValueSpecialClass >> import: rawValue on: importer [
	"Wrap the value as a field in an object."

	^ importer model newOfObject
		  type: self;
		  addValue: (importer model newOfObjectAttribute value:
					   (self importSpecial: rawValue on: importer));
		  yourself
]

{ #category : #importing }
FamixValueSpecialClass >> importSpecial: rawValue on: importer [
	"By default, let the value import itself.
	Redefine this method to implement specific import logic."

	^ rawValue asJavaJacksonValueOn: importer
]
