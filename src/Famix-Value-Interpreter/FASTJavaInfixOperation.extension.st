Extension { #name : 'FASTJavaInfixOperation' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaInfixOperation >> staticTypeIn: executable with: loader [

	| leftType rightType |
	(#( '&&' '||' '==' '!!=' '<' '<=' '>' '>=' ) includes: self operator)
		ifTrue: [ ^ loader primitiveTypeNamed: 'boolean' ].

	leftType := loader staticTypeOf: self leftOperand in: executable.

	rightType := loader staticTypeOf: self rightOperand in: executable.

	^ loader binaryNumericTypeOf: leftType with: rightType
]
