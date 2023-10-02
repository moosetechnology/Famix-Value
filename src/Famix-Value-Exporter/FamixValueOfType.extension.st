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

	^ visitor makeClassTypeExpression: (self typedEntity
			   ifNotNil: [ :typedEntity | typedEntity declaredType typeName ]
			   ifNil: [ self type typeName ])
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
