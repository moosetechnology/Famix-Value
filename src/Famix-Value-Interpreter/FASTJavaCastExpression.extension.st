Extension { #name : 'FASTJavaCastExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaCastExpression >> staticTypeIn: executable with: loader [

	^ loader resolveType: self type in: executable compilationUnit
]
