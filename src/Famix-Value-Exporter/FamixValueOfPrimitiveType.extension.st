Extension { #name : 'FamixValueOfPrimitiveType' }

{ #category : '*Famix-Value-Exporter' }
FamixValueOfPrimitiveType >> accept: visitor [

	^ visitor visitPrimitive: self
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfPrimitiveType >> asFASTJavaExpressionOn: visitor [

	^ value asFASTJavaExpressionOn: visitor of: self type
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfPrimitiveType >> asPharoInitializationAST [

	^ RBLiteralNode value: self value
]
