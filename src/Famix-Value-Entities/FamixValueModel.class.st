Class {
	#name : 'FamixValueModel',
	#superclass : 'MooseModel',
	#traits : 'FamixValueTEntityCreator',
	#classTraits : 'FamixValueTEntityCreator classTrait',
	#category : 'Famix-Value-Entities-Model',
	#package : 'Famix-Value-Entities',
	#tag : 'Model'
}

{ #category : 'accessing' }
FamixValueModel class >> allSubmetamodelsPackagesNames [
	<generated>
	^ #(#'Moose-Query' #'Famix-Traits')
]

{ #category : 'meta' }
FamixValueModel class >> annotation [
	<FMClass: #FamixValueModel super: #MooseModel>
	<package: #'Famix-Value-Entities'>
	<generated>
]
