Extension { #name : 'FamixValueOfTypeReference' }

{ #category : '*Famix-Value-Exporter' }
FamixValueOfTypeReference >> accept: visitor [

	^ visitor visitTypeReference: self
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfTypeReference >> asFASTJavaExpressionOn: visitor [

	^ visitor model newClassProperty
		  type: (visitor makeClassTypeExpression: self value);
		  fieldName: 'class'
]
