Extension { #name : #FamixValueUnknownType }

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> asFASTJavaTypeExpressionOn: visitor [

	^ FASTJavaBuilder current referType: self
]
