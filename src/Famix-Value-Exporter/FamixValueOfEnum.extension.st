Extension { #name : #FamixValueOfEnum }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfEnum >> accept: visitor [

	^ visitor visitEnumValue: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfEnum >> asFASTJavaExpressionOn: visitor [

	^ visitor model newClassProperty
		  fieldName: self value name;
		  type: (visitor model newVariableExpression name: self type name)
]
