Extension { #name : #Float }

{ #category : #'*Famix-Value-Exporter' }
Float >> asFASTJavaLiteralOn: aFASTJavaModel of: type [

	| typeName |
	typeName := type name.
	(typeName sameAs: 'double') ifTrue: [ ^ aFASTJavaModel newDoubleLiteral ].
	(typeName sameAs: 'float') ifTrue: [ ^ aFASTJavaModel newFloatLiteral ].
	self error: 'Unknown floating-point number type: ' , typeName
]
