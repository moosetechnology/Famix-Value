Extension { #name : 'Boolean' }

{ #category : '*Famix-Value-Exporter' }
Boolean >> asFASTJavaExpressionOn: visitor of: type [

	^ visitor model newBooleanLiteral primitiveValue: self asString
]
