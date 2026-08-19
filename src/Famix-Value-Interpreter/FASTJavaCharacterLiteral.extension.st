Extension { #name : 'FASTJavaCharacterLiteral' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaCharacterLiteral >> staticTypeIn: methodInfo with: loader [

	^ loader primitiveTypeNamed: 'char'
]
