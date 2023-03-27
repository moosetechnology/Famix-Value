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

	^ (name beginsWithAnyOf: #( 'java.lang.' 'java.util.' ))
		  ifTrue: [ self findTypeWithName: (name copyAfterLast: $.) ]
		  ifFalse: [ 
		  self findTypeWithFullName: ('::' join: (name splitOn: $.)) ]
]
