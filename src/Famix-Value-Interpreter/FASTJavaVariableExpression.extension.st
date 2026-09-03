Extension { #name : 'FASTJavaVariableExpression' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaVariableExpression >> locationIn: interpreter [

	^ interpreter locationOfVariable: self
]

{ #category : '*Famix-Value-Interpreter' }
FASTJavaVariableExpression >> staticTypeIn: executable with: loader [

	^ loader staticTypeOfName: self name in: executable
]
