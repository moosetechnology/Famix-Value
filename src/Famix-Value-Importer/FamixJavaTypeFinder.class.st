"
An importer helper for finding Java types represented by `FamixJavaType` and its subclasses in a FamixJava model.
"
Class {
	#name : #FamixJavaTypeFinder,
	#superclass : #FamixTTypeFinder,
	#category : #'Famix-Value-Importer'
}

{ #category : #enumerating }
FamixJavaTypeFinder >> parseTypeName: name [

	"TODO: restore method when VerveineJ is fixed"

	^ "(name beginsWithAnyOf: #( 'java.lang.' 'java.util.' ))
		  ifTrue: [ self findTypeWithName: (name copyAfterLast: $.) ]
		  ifFalse: [ "
		  self findTypeWithMooseName: (name copyReplaceAll: '.' with: '::') "]"
]
