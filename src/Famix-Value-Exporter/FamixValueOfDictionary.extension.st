Extension { #name : 'FamixValueOfDictionary' }

{ #category : '*Famix-Value-Exporter' }
FamixValueOfDictionary >> accept: visitor [

	^ visitor visitDictionary: self
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfDictionary >> asFASTJavaExpressionOn: visitor [

	^ visitor makeNewExpression: self
]
