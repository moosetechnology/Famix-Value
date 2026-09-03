Extension { #name : 'FASTJavaIntegerLiteral' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaIntegerLiteral >> staticTypeIn: executable with: loader [

	| value |
	value := self primitiveValue.

	((value endsWith: 'l') or: [ value endsWith: 'L' ]) ifTrue: [
		^ loader primitiveTypeNamed: 'long' ].

	^ loader primitiveTypeNamed: 'int'
]
