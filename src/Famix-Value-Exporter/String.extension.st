Extension { #name : #String }

{ #category : #'*Famix-Value-Exporter' }
String >> asFASTJavaExpressionOn: visitor [

	^ visitor model newStringLiteral primitiveValue: self
]

{ #category : #'*Famix-Value-Exporter' }
String >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor model newClassTypeExpression typeName:
		  (visitor model newTypeName name: #String)
]
