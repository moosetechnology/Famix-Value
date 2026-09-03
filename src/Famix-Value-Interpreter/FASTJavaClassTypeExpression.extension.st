Extension { #name : 'FASTJavaClassTypeExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaClassTypeExpression >> resolveTypeWith: loader in: unitInfo [

	^ loader resolveTypeNamed: self typeName fullName in: unitInfo
]
