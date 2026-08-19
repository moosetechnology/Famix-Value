Extension { #name : 'FASTJavaNewExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaNewExpression >> staticTypeIn: methodInfo with: loader [

	^ loader resolveType: self type in: methodInfo compilationUnit
]
