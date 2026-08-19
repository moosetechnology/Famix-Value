Extension { #name : 'FASTJavaUnaryExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaUnaryExpression >> staticTypeIn: methodInfo with: loader [

	self operator = '!' ifTrue: [ ^ loader primitiveTypeNamed: 'boolean' ].

	(#( '++' '--' ) includes: self operator) ifTrue: [
		^ loader staticTypeOf: self expression in: methodInfo ].

	^ loader unaryNumericTypeOf:
		  (loader staticTypeOf: self expression in: methodInfo)
]
