Class {
	#name : 'FamixValueJavaSource',
	#superclass : 'Object',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'testing' }
FamixValueJavaSource >> hasTypeNamed: qualifiedName [

	self subclassResponsibility
]

{ #category : 'loading' }
FamixValueJavaSource >> loadCompilationUnitForTypeNamed: qualifiedName [

	self subclassResponsibility
]
