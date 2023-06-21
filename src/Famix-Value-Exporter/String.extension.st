Extension { #name : #String }

{ #category : #'*Famix-Value-Exporter' }
String >> asFASTJavaExpressionOn: visitor of: type [

	^ visitor model newStringLiteral primitiveValue: self
]
