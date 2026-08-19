Extension { #name : 'FASTTExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTTExpression >> locationIn: interpreter [

	^ interpreter unsupportedLocationOf: self
]

{ #category : '*Famix-Value-Interpreter' }
FASTTExpression >> staticTypeIn: methodInfo with: loader [

	^ loader unsupportedStaticTypeOf: self
]
