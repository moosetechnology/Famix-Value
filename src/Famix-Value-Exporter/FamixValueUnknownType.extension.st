Extension { #name : #FamixValueUnknownType }

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor builder referType: self
]
