Extension { #name : #UndefinedObject }

{ #category : #'*Famix-Value-Exporter' }
UndefinedObject >> asFASTJavaExpressionOn: visitor [

	^ visitor model newNullLiteral
]
