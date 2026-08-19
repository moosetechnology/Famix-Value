Extension { #name : 'FASTJavaPrimitiveTypeExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaPrimitiveTypeExpression >> resolveTypeWith: loader in: unitInfo [

	^ loader resolvePrimitiveType: self
]
