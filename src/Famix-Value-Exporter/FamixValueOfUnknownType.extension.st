Extension { #name : #FamixValueOfUnknownType }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfUnknownType >> accept: visitor [

	^ visitor visitValueOfUnknownType: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfUnknownType >> asFASTJavaExpressionOn: visitor [

	^ value asFASTJavaExpressionOn: visitor
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfUnknownType >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor makeClassTypeExpression: self
]
