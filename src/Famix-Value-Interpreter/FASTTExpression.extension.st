Extension { #name : 'FASTTExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTTExpression >> locationIn: interpreter [

	^ interpreter unsupportedLocationOf: self
]

{ #category : '*Famix-Value-Interpreter' }
FASTTExpression >> staticTypeIn: executable with: loader [

	^ loader unsupportedStaticTypeOf: self
]
