Extension { #name : #FamixValueOfCollection }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfCollection >> accept: visitor [

	^ visitor visitCollection: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfCollection >> asFASTJavaExpressionOn: visitor [

	^ visitor makeNewExpression: self
]
