Extension { #name : #Integer }

{ #category : #'*Famix-Value-Exporter' }
Integer >> asFASTJavaExpressionOn: visitor [

	^ visitor newIntegerLiteral primitiveValue: self asString
]

{ #category : #'*Famix-Value-Exporter' }
Integer >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor newIntTypeExpression
]
