Extension { #name : #FamixJavaPrimitiveType }

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
