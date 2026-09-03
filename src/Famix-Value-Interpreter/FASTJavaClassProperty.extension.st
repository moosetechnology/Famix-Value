Extension { #name : 'FASTJavaClassProperty' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaClassProperty >> locationIn: interpreter [

	^ interpreter locationOfProperty: self
]

{ #category : '*Famix-Value-Interpreter' }
FASTJavaClassProperty >> staticTypeIn: executable with: loader [

	^ (loader fieldForAccess: self) type
]
