Extension { #name : 'FASTJavaFloatLiteral' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaFloatLiteral >> staticTypeIn: executable with: loader [

	| value |
	value := self primitiveValue.

	((value endsWith: 'f') or: [ value endsWith: 'F' ]) ifTrue: [
		^ loader primitiveTypeNamed: 'float' ].

	^ loader primitiveTypeNamed: 'double'
]
