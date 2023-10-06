Extension { #name : #Integer }

{ #category : #'*Famix-Value-Exporter' }
Integer >> asFASTJavaLiteralOn: aFASTJavaModel of: type [

	| typeName |
	typeName := type name.
	((typeName beginsWith: 'int' caseSensitive: false) or: [ 
		 typeName sameAs: 'short' ]) ifTrue: [ 
		^ aFASTJavaModel newIntegerLiteral ].
	(typeName sameAs: 'long') ifTrue: [ ^ aFASTJavaModel newLongLiteral ].
	self error: 'Unknown integer type:' , typeName
]
