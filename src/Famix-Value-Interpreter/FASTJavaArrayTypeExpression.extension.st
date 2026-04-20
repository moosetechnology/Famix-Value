Extension { #name : #FASTJavaArrayTypeExpression }

{ #category : #'*Famix-Value-Interpreter' }
FASTJavaArrayTypeExpression >> asTypeOf: famixType [

	| baseType dimensions |
	dimensions := 0.
	baseType := self.
	[
	dimensions := dimensions + 1.
	(baseType := baseType baseType) class == self class ] whileTrue.
	^ FamixValueJavaArray new
		  dimensions: dimensions;
		  type: famixType
]
