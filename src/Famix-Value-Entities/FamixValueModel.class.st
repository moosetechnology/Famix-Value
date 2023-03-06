Class {
	#name : #FamixValueModel,
	#superclass : #MooseModel,
	#category : #'Famix-Value-Entities-Model'
}

{ #category : #accessing }
FamixValueModel class >> allSubmetamodelsPackagesNames [
	<generated>
	^ #(#'Moose-Query' #'Famix-Traits')
]

{ #category : #meta }
FamixValueModel class >> annotation [
	<FMClass: #FamixValueModel super: #MooseModel>
	<package: #'Famix-Value-Entities'>
	<generated>
]

{ #category : #testing }
FamixValueModel class >> canBeImportedFromFile [
	<generated>
	^true
]
