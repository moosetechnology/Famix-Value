"
An element belonging to a collection.
"
Class {
	#name : #FamixValueOfCollectionElement,
	#superclass : #FamixValueEntity,
	#instVars : [
		'#collection => FMOne type: #FamixValueOfCollection opposite: #value',
		'#value => FMOne type: #FamixValueOfType opposite: #elementInCollections'
	],
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueOfCollectionElement class >> annotation [

	<FMClass: #OfCollectionElement super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixValueOfCollectionElement >> collection [
	"Relation named: #collection type: #FamixValueOfCollection opposite: #value"

	<generated>
	<container>
	^ collection
]

{ #category : #accessing }
FamixValueOfCollectionElement >> collection: anObject [

	<generated>
	collection := anObject
]

{ #category : #navigation }
FamixValueOfCollectionElement >> collectionGroup [
	<generated>
	<navigation: 'Collection'>
	^ MooseSpecializedGroup with: self collection
]

{ #category : #accessing }
FamixValueOfCollectionElement >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #elementInCollections"

	<generated>
	<source>
	^ value
]

{ #category : #accessing }
FamixValueOfCollectionElement >> value: anObject [

	<generated>
	value := anObject
]
