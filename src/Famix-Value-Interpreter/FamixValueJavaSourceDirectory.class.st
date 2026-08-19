Class {
	#name : 'FamixValueJavaSourceDirectory',
	#superclass : 'FamixValueJavaClassSource',
	#instVars : [
		'path'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'as yet unclassified' }
FamixValueJavaSourceDirectory >> loadCompilationUnitForClassNamed: qualifiedName [

	| file |
	file := self fileForClassNamed: qualifiedName.
	file exists ifFalse: [ ^ nil ].

	^ JavaSmaCCProgramNodeImporterVisitor parseCodeString: file contents
]
