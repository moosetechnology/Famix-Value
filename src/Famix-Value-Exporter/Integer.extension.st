Extension { #name : 'Integer' }

{ #category : '*Famix-Value-Exporter' }
Integer >> asFASTJavaExpressionOn: visitor of: type [

	| typeName |
	typeName := type name.
	((typeName beginsWith: 'int' caseSensitive: false) or: [
		 typeName sameAs: 'short' ]) ifTrue: [
		^ visitor model newIntegerLiteral primitiveValue: self asString ].
	(typeName sameAs: 'long') ifTrue: [
		^ visitor model newLongLiteral primitiveValue: self asString , 'L' ].
	self error: 'Unknown integer type:' , typeName
]
