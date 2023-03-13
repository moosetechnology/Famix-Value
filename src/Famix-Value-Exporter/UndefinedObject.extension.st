Extension { #name : #UndefinedObject }

{ #category : #'*Famix-Value-Exporter' }
UndefinedObject >> asFASTJavaExpressionOn: visitor [

	^ visitor newNullLiteral
]
