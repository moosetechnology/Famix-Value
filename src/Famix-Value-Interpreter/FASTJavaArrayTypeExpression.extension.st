Extension { #name : 'FASTJavaArrayTypeExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaArrayTypeExpression >> resolveTypeWith: loader in: unitInfo [

	^ loader resolveArrayType: self in: unitInfo
]
