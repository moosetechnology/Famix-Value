"
I represent Java arrays.
Famix does not take dimensions into account because it is a dependency model.
However, arrays are required to represent values faithfully, and that is my purpose.
"
Class {
	#name : 'FamixValueJavaArray',
	#superclass : 'FamixValueSpecialType',
	#instVars : [
		'dimensions'
	],
	#category : 'Famix-Value-Types',
	#package : 'Famix-Value-Types'
}

{ #category : 'accessing' }
FamixValueJavaArray >> dimensions [

	^ dimensions
]

{ #category : 'accessing' }
FamixValueJavaArray >> dimensions: anInteger [

	dimensions := anInteger
]

{ #category : 'importing' }
FamixValueJavaArray >> import: rawValue on: importer [

	self shouldNotImplement
]
