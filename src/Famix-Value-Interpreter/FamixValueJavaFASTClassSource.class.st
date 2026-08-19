Class {
	#name : 'FamixValueJavaFASTClassSource',
	#superclass : 'FamixValueJavaClassSource',
	#instVars : [
		'compilationUnitsByClass'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'initialization' }
FamixValueJavaFASTClassSource >> addClass: fastClass [

	classes at: fastClass name put: fastClass
]

{ #category : 'initialization' }
FamixValueJavaFASTClassSource >> initialize [

	super initialize.
	compilationUnitsByClass := Dictionary new
]

{ #category : 'initialization' }
FamixValueJavaFASTClassSource >> loadCompilationUnitForClassNamed: qualifiedName [

	^ compilationUnitsByClass at: qualifiedName ifAbsent: [ nil ]
]
