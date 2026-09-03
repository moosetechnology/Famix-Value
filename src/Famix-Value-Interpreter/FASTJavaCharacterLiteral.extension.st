Extension { #name : 'FASTJavaCharacterLiteral' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaCharacterLiteral >> staticTypeIn: executable with: loader [

	^ loader primitiveTypeNamed: 'char'
]
