Class {
	#name : 'FamixValueJavaSourceDirectory',
	#superclass : 'FamixValueJavaSource',
	#instVars : [
		'root'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaSourceDirectory class >> on: aFileReference [

	^ self new root: aFileReference
]

{ #category : 'enumerating' }
FamixValueJavaSourceDirectory >> fileForTypeNamed: qualifiedName [

	| parts file |
	parts := qualifiedName splitOn: $..
	file := root.

	parts allButLast do: [ :part | file := file / part ].

	^ file / (parts last , '.java')
]

{ #category : 'testing' }
FamixValueJavaSourceDirectory >> hasTypeNamed: qualifiedName [

	^ (self fileForTypeNamed: qualifiedName) exists
]

{ #category : 'loading' }
FamixValueJavaSourceDirectory >> loadCompilationUnitForTypeNamed: qualifiedName [

	| file |
	file := self fileForTypeNamed: qualifiedName.
	file exists ifFalse: [ ^ nil ].

	^ ((JavaSmaCCProgramNodeImporterVisitor new parseCodeString:
		    file contents) allWithType: FASTJavaCompilationUnit) first
]

{ #category : 'accessing' }
FamixValueJavaSourceDirectory >> root [

	^ root
]

{ #category : 'accessing' }
FamixValueJavaSourceDirectory >> root: aFileReference [

	root := aFileReference
]
