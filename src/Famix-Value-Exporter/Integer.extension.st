Extension { #name : #Integer }

{ #category : #'*Famix-Value-Exporter' }
Integer >> asFASTJavaExpressionOn: visitor [

	^ visitor model newIntegerLiteral primitiveValue: self asString
]

{ #category : #'*Famix-Value-Exporter' }
Integer >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor model newIntTypeExpression
]
