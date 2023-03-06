Class {
	#name : #FamixValueEntity,
	#superclass : #MooseEntity,
	#category : #'Famix-Value-Entities-Entities'
}

{ #category : #meta }
FamixValueEntity class >> annotation [

	<FMClass: #Entity super: #MooseEntity>
	<package: #'Famix-Value-Entities'>
	<generated>
	^self
]

{ #category : #meta }
FamixValueEntity class >> metamodel [

	<generated>
	^ FamixValueModel metamodel
]

{ #category : #testing }
FamixValueEntity >> isOfCollection [

	<generated>
	^ false
]

{ #category : #testing }
FamixValueEntity >> isOfDictionary [

	<generated>
	^ false
]

{ #category : #testing }
FamixValueEntity >> isOfEnum [

	<generated>
	^ false
]

{ #category : #testing }
FamixValueEntity >> isOfObject [

	<generated>
	^ false
]

{ #category : #testing }
FamixValueEntity >> isOfPrimitiveType [

	<generated>
	^ false
]

{ #category : #testing }
FamixValueEntity >> isOfUnknownType [

	<generated>
	^ false
]

{ #category : #testing }
FamixValueEntity >> isType [

	<generated>
	^ false
]

{ #category : #testing }
FamixValueEntity >> isUnknownType [

	<generated>
	^ false
]
