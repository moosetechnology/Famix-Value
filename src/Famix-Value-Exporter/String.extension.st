Extension { #name : #String }

{ #category : #'*Famix-Value-Exporter' }
String >> asFASTJavaExpressionOn: visitor [

	^ visitor newStringLiteral primitiveValue: self
]

{ #category : #'*Famix-Value-Exporter' }
String >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor newClassTypeExpression typeName:
		  (visitor newTypeName name: #String)
]
