Extension { #name : #FamixValueOfEnum }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfEnum >> accept: visitor [

	^ visitor visitEnumValue: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfEnum >> asFASTJavaExpressionOn: visitor [

	^ visitor newClassProperty
		  fieldName: self value name;
		  type: (visitor newVariableExpression name: self type name)
]
