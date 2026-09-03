Extension { #name : 'FASTJavaUnaryExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaUnaryExpression >> staticTypeIn: executable with: loader [

	self operator = '!' ifTrue: [ ^ loader primitiveTypeNamed: 'boolean' ].

	(#( '++' '--' ) includes: self operator) ifTrue: [
		^ loader staticTypeOf: self expression in: executable ].

	^ loader unaryNumericTypeOf:
		  (loader staticTypeOf: self expression in: executable)
]
