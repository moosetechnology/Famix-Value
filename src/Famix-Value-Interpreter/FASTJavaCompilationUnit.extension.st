Extension { #name : 'FASTJavaCompilationUnit' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaCompilationUnit >> packageName [

	packageDeclaration ifNil: [ ^ '' ].
	^ packageDeclaration qualifiedName fullName
]

{ #category : '*Famix-Value-Interpreter' }
FASTJavaCompilationUnit >> qualifiedNameOf: classDeclaration [

	^ self packageName isEmpty
		  ifTrue: [ classDeclaration name ]
		  ifFalse: [ self packageName , '.' , classDeclaration name ]
]
