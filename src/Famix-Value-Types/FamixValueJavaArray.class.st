"
I represent Java arrays.
Famix does not take dimensions into account because it is a dependency model.
However, arrays are required to represent values faithfully, and that is my purpose.
"
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
FamixValueJavaArray >> decorate: aFamixJavaType asFASTJavaTypeExpressionOn: visitor [
	"Add array brackets to the type name."

	| expression |
	expression := aFamixJavaType asFASTJavaTypeExpressionOn: visitor.
	expression typeName name:
		expression typeName name , ('[]' repeat: dimensions).
	^ expression
]

{ #category : #accessing }
FamixValueJavaArray >> dimensions [

	^ dimensions
]

{ #category : #accessing }
FamixValueJavaArray >> dimensions: anInteger [

	dimensions := anInteger
]

{ #category : #importing }
FamixValueJavaArray >> import: rawValue on: importer [

	self shouldNotImplement
]
