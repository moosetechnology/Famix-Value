Extension { #name : 'FASTJavaArrayAccess' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaArrayAccess >> locationIn: interpreter [

	^ interpreter locationOfArrayAccess: self
]

{ #category : '*Famix-Value-Interpreter' }
FASTJavaArrayAccess >> staticTypeIn: executable with: loader [

	^ (loader staticTypeOf: self array in: executable) elementType
]
