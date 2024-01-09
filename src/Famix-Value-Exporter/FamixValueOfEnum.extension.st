Extension { #name : #FamixValueOfEnum }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfEnum >> accept: visitor [

	^ visitor visitEnumValue: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfEnum >> asFASTJavaExpressionOn: visitor [

	^ visitor model newClassProperty
		  type: (visitor makeClassTypeExpression: self type);
		  fieldName: self value name
]
