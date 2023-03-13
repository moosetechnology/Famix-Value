Extension { #name : #FamixValueOfPrimitiveType }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfPrimitiveType >> accept: visitor [

	^ visitor visitPrimitive: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfPrimitiveType >> asFASTJavaExpressionOn: visitor [

	^ value asFASTJavaExpressionOn: visitor
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfPrimitiveType >> asFASTJavaTypeExpressionOn: visitor [

	^ value asFASTJavaTypeExpressionOn: visitor
]
