Extension { #name : 'FASTJavaMethodInvocation' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaMethodInvocation >> staticTypeIn: executable with: loader [

	^ (loader methodForInvocation: self) returnType
]
