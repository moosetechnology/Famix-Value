Extension { #name : 'FamixValueJavaArray' }

{ #category : '*Famix-Value-Exporter' }
FamixValueJavaArray >> decorate: aFamixJavaType asFASTJavaTypeExpressionOn: visitor [
	"Add array brackets to the type name."

	| expression |
	expression := aFamixJavaType asFASTJavaTypeExpressionOn: visitor.
	expression typeName name:
		expression typeName name , ('[]' repeat: dimensions).
	^ expression
]
