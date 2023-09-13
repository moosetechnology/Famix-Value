Extension { #name : #Float }

{ #category : #'*Famix-Value-Exporter' }
Float >> asFASTJavaLiteralOn: aFASTJavaModel of: type [

	| typeName |
	typeName := type name asLowercase.
	typeName = 'double' ifTrue: [ ^ aFASTJavaModel newDoubleLiteral ].
	typeName = 'float' ifTrue: [ ^ aFASTJavaModel newFloatLiteral ].
	self error: 'Unknown floating-point number type:' , type name
]
