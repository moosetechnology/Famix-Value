"
A value of an enumeration.
"
Class {
	#name : #FamixValueOfEnum,
	#superclass : #FamixValueOfType,
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfEnum class >> annotation [

	<FMClass: #OfEnum super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #testing }
FamixValueOfEnum >> isOfEnum [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfEnum >> value [
	"Relation named: #value type: #FamixTEnumValue opposite: #valueInstances"

	<generated>
	<FMProperty: #value type: #FamixTEnumValue opposite: #valueInstances>
	^ self attributeAt: #value ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfEnum >> value: anObject [

	<generated>
	self attributeAt: #value put: (FMMultivalueLink on: self update: #valueInstances from: self value to: anObject).
]
