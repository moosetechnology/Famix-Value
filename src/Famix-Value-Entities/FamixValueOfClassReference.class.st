"
A reference to a class.
"
Class {
	#name : #FamixValueOfClassReference,
	#superclass : #FamixValueOfType,
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfClassReference class >> annotation [

	<FMClass: #OfClassReference super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfClassReference >> value [
	"Relation named: #value type: #FamixTClass opposite: #valueReferences"

	<generated>
	<FMProperty: #value type: #FamixTClass opposite: #valueReferences>
	^ self attributeAt: #value ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfClassReference >> value: anObject [

	<generated>
	self attributeAt: #value put: (FMMultivalueLink on: self update: #valueReferences from: self value to: anObject).
]
