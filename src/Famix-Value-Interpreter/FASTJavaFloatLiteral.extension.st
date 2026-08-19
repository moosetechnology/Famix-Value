Extension { #name : 'FASTJavaFloatLiteral' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaFloatLiteral >> staticTypeIn: methodInfo with: loader [

	| value |
	value := self primitiveValue.

	((value endsWith: 'f') or: [ value endsWith: 'F' ]) ifTrue: [
		^ loader primitiveTypeNamed: 'float' ].

	^ loader primitiveTypeNamed: 'double'
]
