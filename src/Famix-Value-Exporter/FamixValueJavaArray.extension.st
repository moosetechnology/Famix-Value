Extension { #name : 'FamixValueJavaArray' }

{ #category : '*Famix-Value-Exporter' }
FamixValueJavaArray >> acceptValueVisitor: visitor forCollection: array [

	| model arrayType initializer |
	model := visitor model.
	arrayType := model newClassTypeExpression typeName:
		             (model newTypeName name: type typeName).
	dimensions timesRepeat: [
		arrayType := model newArrayTypeExpression baseType: arrayType ].
	initializer := model newArrayInitializer initializers:
		               (array value collect: [ :element |
			                visitor ensureVisited: element value.
			                visitor makeVariableExpression: element value ]).
	^ visitor statementBlock
		  addStatement: (model newVarDeclStatement
				   type: arrayType;
				   addDeclarator: (model newVariableDeclarator
						    variable:
							    (model newVariableExpression name:
									     (visitor varNameFor: array));
						    expression: (model newNewArray
								     type: (type asFASTJavaTypeExpressionOn: visitor);
								     addArgument: model newEmptyDimExpression;
								     initializer: initializer));
				   yourself);
		  yourself
]

{ #category : '*Famix-Value-Exporter' }
FamixValueJavaArray >> decorate: aFamixJavaType asFASTJavaTypeExpressionOn: visitor [
	"Add array brackets to the type name."

	| expression |
	expression := aFamixJavaType asFASTJavaTypeExpressionOn: visitor.
	dimensions timesRepeat: [
		expression := visitor model newArrayTypeExpression baseType:
			              expression ].
	^ expression
]
