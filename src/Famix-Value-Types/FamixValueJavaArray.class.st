Class {
	#name : #FamixValueJavaArray,
	#superclass : #FamixValueSpecialType,
	#instVars : [
		'dimensions'
	],
	#category : #'Famix-Value-Types'
}

{ #category : #visiting }
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

{ #category : #visiting }
FamixValueJavaArray >> acceptValueVisitor: visitor forObject: array [

	self halt. "export an array"
]

{ #category : #accessing }
FamixValueJavaArray >> dimensions [

	^ dimensions
]

{ #category : #accessing }
FamixValueJavaArray >> dimensions: anInteger [

	dimensions := anInteger
]
