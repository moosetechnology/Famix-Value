"
An element belonging to a collection.

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `collection` | `FamixValueOfCollectionElement` | `value` | `FamixValueOfCollection` | |
| `value` | `FamixValueOfCollectionElement` | `elementInCollections` | `FamixValueOfType` | |



"
Class {
	#name : 'FamixValueOfCollectionElement',
	#superclass : 'FamixValueEntity',
	#instVars : [
		'#collection => FMOne type: #FamixValueOfCollection opposite: #value',
		'#value => FMOne type: #FamixValueOfType opposite: #elementInCollections'
	],
	#category : 'Famix-Value-Entities-Entities',
	#package : 'Famix-Value-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixValueOfCollectionElement class >> annotation [

	<FMClass: #OfCollectionElement super: #FamixValueEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixValueOfCollectionElement >> collection [
	"Relation named: #collection type: #FamixValueOfCollection opposite: #value"

	<generated>
	^ collection
]

{ #category : 'accessing' }
FamixValueOfCollectionElement >> collection: anObject [

	<generated>
	collection := anObject
]

{ #category : 'accessing' }
FamixValueOfCollectionElement >> value [
	"Relation named: #value type: #FamixValueOfType opposite: #elementInCollections"

	<generated>
	^ value
]

{ #category : 'accessing' }
FamixValueOfCollectionElement >> value: anObject [

	<generated>
	value := anObject
]
