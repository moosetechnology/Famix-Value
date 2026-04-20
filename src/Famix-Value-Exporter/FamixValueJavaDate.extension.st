Extension { #name : 'FamixValueJavaDate' }

{ #category : '*Famix-Value-Exporter' }
FamixValueJavaDate >> acceptValueVisitor: visitor forObject: object [
	"Skip visiting the attribute, it is added as a constructor argument."

	^ visitor statementBlock
		  addStatement: (visitor makeVarDeclStatement: object);
		  yourself
]

{ #category : '*Famix-Value-Exporter' }
FamixValueJavaDate >> value: date asFASTJavaExpressionOn: visitor [
	"Add epoch time attribute as constructor argument."

	^ (visitor makeNewExpression: date)
		  addArgument: (visitor model newLongLiteral primitiveValue:
					   date value first value value asString , 'L');
		  yourself
]
