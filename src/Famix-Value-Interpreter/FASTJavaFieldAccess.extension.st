Extension { #name : 'FASTJavaFieldAccess' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaFieldAccess >> locationIn: interpreter [

	^ interpreter locationOfFieldAccess: self
]

{ #category : '*Famix-Value-Interpreter' }
FASTJavaFieldAccess >> staticTypeIn: methodInfo with: loader [

	| receiverType field |
	receiverType := loader staticTypeOf: self receiver in: methodInfo.
	field := receiverType fieldNamed: self fieldName.
	^ field type
]
