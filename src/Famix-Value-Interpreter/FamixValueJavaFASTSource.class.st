Class {
	#name : 'FamixValueJavaFASTSource',
	#superclass : 'FamixValueJavaSource',
	#instVars : [
		'compilationUnitsByType'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'loading' }
FamixValueJavaFASTSource >> addCompilationUnit: compilationUnit [

	compilationUnit classDeclarations do: [ :class |
		compilationUnitsByType
			at: (compilationUnit qualifiedNameOf: class)
			put: compilationUnit ].

	compilationUnit interfaceDeclarations do: [ :interface |
		compilationUnitsByType
			at: (compilationUnit qualifiedNameOf: interface)
			put: compilationUnit ]
]

{ #category : 'testing' }
FamixValueJavaFASTSource >> hasTypeNamed: qualifiedName [

	^ compilationUnitsByType includesKey: qualifiedName
]

{ #category : 'initialization' }
FamixValueJavaFASTSource >> initialize [

	super initialize.
	compilationUnitsByType := Dictionary new
]

{ #category : 'loading' }
FamixValueJavaFASTSource >> loadCompilationUnitForTypeNamed: qualifiedName [

	^ compilationUnitsByType at: qualifiedName ifAbsent: [ nil ]
]
