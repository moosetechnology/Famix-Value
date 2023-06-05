"
This trait is used by Famix models.
It provides an API for creating entities and adding them to the model.
"
Trait {
	#name : #FamixValueTEntityCreator,
	#category : #'Famix-Value-Entities-Model'
}

{ #category : #meta }
FamixValueTEntityCreator classSide >> annotation [

	<FMClass: #TEntityCreator super: #Object>
	<package: #'Famix-Value-Entities'>
	<generated>
	^ self
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfCollection [

	<generated>
	^ self add: FamixValueOfCollection new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfCollectionElement [

	<generated>
	^ self add: FamixValueOfCollectionElement new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfDictionary [

	<generated>
	^ self add: FamixValueOfDictionary new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfDictionaryAssociation [

	<generated>
	^ self add: FamixValueOfDictionaryAssociation new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfEnum [

	<generated>
	^ self add: FamixValueOfEnum new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfObject [

	<generated>
	^ self add: FamixValueOfObject new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfObjectAttribute [

	<generated>
	^ self add: FamixValueOfObjectAttribute new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfPrimitiveType [

	<generated>
	^ self add: FamixValueOfPrimitiveType new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newOfUnknownType [

	<generated>
	^ self add: FamixValueOfUnknownType new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newUnknownType [

	<generated>
	^ self add: FamixValueUnknownType new
]

{ #category : #'entity creation' }
FamixValueTEntityCreator >> newUnknownTypeNamed: aName [

	<generated>
	^ self add: (FamixValueUnknownType named: aName)
]
