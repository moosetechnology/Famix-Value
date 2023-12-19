Extension { #name : #FamixValueOfType }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> accept: visitor [

	self subclassResponsibility
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> asFASTJava [

	^ self accept: FamixValue2FASTJavaVisitor new
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> asFASTJavaExpressionOn: visitor [

	self subclassResponsibility
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor makeClassTypeExpression: self type typeName
	"It would have been nice to give the type of the typed entity to the value, to use the idea of the regular practice of typing a variable with an interface and affecting a concrete type.
	However, this brings problems when we want to reconstruct the value, because we need to use setters, and the declared type of the typed entity may not have them, because it can be an abstract class, a superclass, or an interface, and they usually don't define a contract for setters."
	"(self typedEntity
			   ifNotNil: [ :typedEntity | typedEntity declaredType typeName ]
			   ifNil: [ self type typeName ])"
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> asJavaSourceCode [

	^ FASTJavaExportVisitor new export: self asFASTJava
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> asPharoAST [

	^ self accept: FamixValue2PharoVisitor new
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> asPharoSourceCode [

	^ RBSimpleFormatter format: self asPharoAST
]
