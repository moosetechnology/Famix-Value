Extension { #name : 'FASTJavaInfixOperation' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaInfixOperation >> staticTypeIn: methodInfo with: loader [

	| leftType rightType |
	(#( '&&' '||' '==' '!!=' '<' '<=' '>' '>=' ) includes: self operator)
		ifTrue: [ ^ loader primitiveTypeNamed: 'boolean' ].

	leftType := loader staticTypeOf: self leftOperand in: methodInfo.

	rightType := loader staticTypeOf: self rightOperand in: methodInfo.

	^ loader binaryNumericTypeOf: leftType with: rightType
]
