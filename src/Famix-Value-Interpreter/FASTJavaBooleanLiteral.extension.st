Extension { #name : 'FASTJavaBooleanLiteral' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaBooleanLiteral >> staticTypeIn: executable with: loader [

	^ loader primitiveTypeNamed: 'boolean'
]
