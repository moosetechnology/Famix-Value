Extension { #name : 'FASTJavaClassTypeExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaClassTypeExpression >> resolveTypeWith: loader in: unitInfo [

	^ loader resolveClassType: self in: unitInfo
]
