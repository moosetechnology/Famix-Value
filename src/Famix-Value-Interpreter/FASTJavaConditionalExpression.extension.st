Extension { #name : 'FASTJavaConditionalExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaConditionalExpression >> staticTypeIn: executable with: loader [

	| thenType elseType |
	(self thenPart isKindOf: FASTJavaNullLiteral) ifTrue: [ ^ loader staticTypeOf: self elsePart in: executable ].
	(self elsePart isKindOf: FASTJavaNullLiteral) ifTrue: [ ^ loader staticTypeOf: self thenPart in: executable ].

	thenType := loader staticTypeOf: self thenPart in: executable.
	elseType := loader staticTypeOf: self elsePart in: executable.

	(thenType isSameTypeAs: elseType) ifTrue: [ ^ thenType ].
	(thenType name = 'boolean' and: [ elseType name = 'boolean' ]) ifTrue: [ ^ loader primitiveTypeNamed: 'boolean' ].
	(thenType isPrimitiveType and: [ elseType isPrimitiveType ]) ifTrue: [
		^ loader interpreter
			  conditionalNumericTypeOf: self thenPart
			  type: thenType
			  and: self elsePart
			  type: elseType ].

	^ loader unsupportedStaticTypeOf: self
]
