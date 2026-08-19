Extension { #name : 'FASTJavaBooleanLiteral' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaBooleanLiteral >> staticTypeIn: methodInfo with: loader [

	^ loader primitiveTypeNamed: 'boolean'
]
