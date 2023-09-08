"
An attribute belonging to an object.
"
Class {
	#name : #FamixValueOfObjectAttribute,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#object => FMOne type: #FamixValueOfObject opposite: #value',
		'#value => FMOne type: #FamixValueOfType opposite: #attributeInObjects'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfObjectAttribute class >> annotation [

	<FMClass: #OfObjectAttribute super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> attribute [
	"Relation named: #attribute type: #FamixTAttribute opposite: #valueInObjects"

	<generated>
	<source>
	<FMProperty: #attribute type: #FamixTAttribute opposite: #valueInObjects>
	^ self attributeAt: #attribute ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> attribute: anObject [

	<generated>
	self attributeAt: #attribute put: (FMMultivalueLink on: self update: #valueInObjects from: self attribute to: anObject).
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> object [
	"Relation named: #object type: #FamixValueOfObject opposite: #value"

	<generated>
	<container>
	^ object
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> object: anObject [

	<generated>
	object := anObject
]

{ #category : #navigation }
FamixValueOfObjectAttribute >> objectGroup [
	<generated>
	<navigation: 'Object'>
	^ MooseSpecializedGroup with: self object
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #attributeInObjects"

	<generated>
	<source>
	^ value
]

{ #category : #accessing }
FamixValueOfObjectAttribute >> value: anObject [

	<generated>
	value := anObject
]
