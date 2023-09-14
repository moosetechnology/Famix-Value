Extension { #name : #Integer }

{ #category : #'*Famix-Value-Exporter' }
Integer >> asFASTJavaLiteralOn: aFASTJavaModel of: type [

	| typeName |
	typeName := type name asLowercase.
	((typeName beginsWith: 'int') or: [ typeName = 'short' ]) ifTrue: [ 
		^ aFASTJavaModel newIntegerLiteral ].
	typeName = 'long' ifTrue: [ ^ aFASTJavaModel newLongLiteral ].
	self error: 'Unknown integer type:' , type name
]
