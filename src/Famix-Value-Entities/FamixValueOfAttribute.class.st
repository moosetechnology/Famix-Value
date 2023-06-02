"
A value of an attribute that belongs to an object.
"
Class {
	#name : #FamixValueOfAttribute,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#object => FMOne type: #FamixValueOfObject opposite: #value',
		'#value => FMOne type: #FamixValueOfType opposite: #valueInObjects'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfAttribute class >> annotation [

	<FMClass: #OfAttribute super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfAttribute >> attribute [
	"Relation named: #attribute type: #FamixTAttribute opposite: #valueInObjects"

	<generated>
	<FMProperty: #attribute type: #FamixTAttribute opposite: #valueInObjects>
	^ self attributeAt: #attribute ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfAttribute >> attribute: anObject [

	<generated>
	self attributeAt: #attribute put: (FMMultivalueLink on: self update: #valueInObjects from: self attribute to: anObject).
]

{ #category : #accessing }
FamixValueOfAttribute >> object [
	"Relation named: #object type: #FamixValueOfObject opposite: #value"

	<generated>
	^ object
]

{ #category : #accessing }
FamixValueOfAttribute >> object: anObject [

	<generated>
	object := anObject
]

{ #category : #accessing }
FamixValueOfAttribute >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #valueInObjects"

	<generated>
	^ value
]

{ #category : #accessing }
FamixValueOfAttribute >> value: anObject [

	<generated>
	value := anObject
]
