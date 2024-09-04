Extension { #name : 'Float' }

{ #category : '*Famix-Value-Exporter' }
Float >> asFASTJavaExpressionOn: visitor of: type [

	| typeName |
	typeName := type name.
	(typeName sameAs: 'double') ifTrue: [
		^ visitor model newDoubleLiteral primitiveValue: self asString ].
	(typeName sameAs: 'float') ifTrue: [
		^ visitor model newFloatLiteral primitiveValue: self asString , 'f' ].
	self error: 'Unknown floating-point number type: ' , typeName
]
