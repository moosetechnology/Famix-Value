Extension { #name : 'FASTJavaNewExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaNewExpression >> staticTypeIn: executable with: loader [

	^ loader resolveType: self type in: executable compilationUnit
]
