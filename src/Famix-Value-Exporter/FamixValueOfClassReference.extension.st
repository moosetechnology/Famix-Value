Extension { #name : #FamixValueOfClassReference }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfClassReference >> accept: visitor [

	^ visitor visitClassReference: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfClassReference >> asFASTJavaExpressionOn: visitor [

	^ visitor model newClassProperty
		  type: (visitor makeClassTypeExpression: self value);
		  fieldName: 'class'
]
