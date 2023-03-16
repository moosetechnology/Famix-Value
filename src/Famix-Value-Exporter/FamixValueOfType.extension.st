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
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfType >> asJavaSourceCode [

	^ FASTJavaExportVisitor new export: self asFASTJava
]
