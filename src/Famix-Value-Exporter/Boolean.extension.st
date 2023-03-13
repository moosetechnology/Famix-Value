Extension { #name : #Boolean }

{ #category : #'*Famix-Value-Exporter' }
Boolean >> asFASTJavaExpressionOn: visitor [

	^ visitor newBooleanLiteral primitiveValue: self asString
]

{ #category : #'*Famix-Value-Exporter' }
Boolean >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor newBooleanTypeExpression
]
