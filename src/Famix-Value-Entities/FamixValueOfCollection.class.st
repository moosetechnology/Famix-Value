"
A value of a collection type.
"
Class {
	#name : #FamixValueOfCollection,
	#superclass : #FamixValueOfType,
	#instVars : [
		'#value => FMMany type: #FamixValueOfCollectionElement opposite: #collection'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfCollection class >> annotation [

	<FMClass: #OfCollection super: #FamixValueOfType>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixValueOfCollection >> addValue: anObject [
	<generated>
	^ self value add: anObject
]

{ #category : #testing }
FamixValueOfCollection >> isOfCollection [

	<generated>
	^ true
]

{ #category : #accessing }
FamixValueOfCollection >> value [
	"Relation named: #value type: #FamixValueOfCollectionElement opposite: #collection"

	<generated>
	<derived>
	^ value
]

{ #category : #accessing }
FamixValueOfCollection >> value: anObject [

	<generated>
	value value: anObject
]

{ #category : #navigation }
FamixValueOfCollection >> valueGroup [
	<generated>
	<navigation: 'Value'>
	^ MooseSpecializedGroup withAll: self value asSet
]
