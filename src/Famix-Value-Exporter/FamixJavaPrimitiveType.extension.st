Extension { #name : #FamixJavaPrimitiveType }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaPrimitiveType >> asFASTJavaDefaultValueOn: model [

	(#( int short byte ) includes: name) ifTrue: [
		^ model newIntegerLiteral primitiveValue: '0' ].
	name = 'boolean' ifTrue: [
		^ model newBooleanLiteral primitiveValue: 'false' ].
	name = 'double' ifTrue: [
		^ model newDoubleLiteral primitiveValue: '0' ].
	name = 'long' ifTrue: [ ^ model newLongLiteral primitiveValue: '0' ].
	name = 'char' ifTrue: [
		^ model newCharacterLiteral primitiveValue: '\u0000' ].
	name = 'float' ifTrue: [ ^ model newFloatLiteral primitiveValue: '0' ].
	self error: 'Unknown primitive type:' , name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaPrimitiveType >> asFASTJavaTypeExpressionOn: visitor [

	| model |
	model := visitor model.
	name = 'int' ifTrue: [ ^ model newIntTypeExpression ].
	name = 'boolean' ifTrue: [ ^ model newBooleanTypeExpression ].
	name = 'double' ifTrue: [ ^ model newDoubleTypeExpression ].
	name = 'long' ifTrue: [ ^ model newLongTypeExpression ].
	name = 'char' ifTrue: [ ^ model newCharTypeExpression ].
	name = 'float' ifTrue: [ ^ model newFloatTypeExpression ].
	name = 'byte' ifTrue: [ ^ model newByteTypeExpression ].
	name = 'short' ifTrue: [ ^ model newShortTypeExpression ].
	self error: 'Unknown primitive type:' , name
]
