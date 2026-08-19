Extension { #name : 'FASTJavaClassProperty' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaClassProperty >> locationIn: interpreter [

	^ interpreter locationOfProperty: self
]

{ #category : '*Famix-Value-Interpreter' }
FASTJavaClassProperty >> staticTypeIn: methodInfo with: loader [

	^ loader staticTypeOfName: self fieldName in: methodInfo
]
