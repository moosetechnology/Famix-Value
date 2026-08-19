Extension { #name : 'FASTJavaMethodInvocation' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaMethodInvocation >> staticTypeIn: methodInfo with: loader [

	^ (loader methodForInvocation: self) returnType
]
