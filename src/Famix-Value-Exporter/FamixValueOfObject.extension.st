Extension { #name : #FamixValueOfObject }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfObject >> accept: visitor [

	^ visitor visitObject: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfObject >> asFASTJavaExpressionOn: visitor [

	^ visitor makeNewExpression: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfObject >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor makeClassTypeExpression: self
]
