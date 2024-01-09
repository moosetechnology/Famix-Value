"
A representation of Java date types like `java.util.Date` or `java.sql.Timestamp`.
This family of types has a special serialization format: all attributes are transient, and only a `long` is used to measure the epoch time.
"
Class {
	#name : #FamixValueJavaDate,
	#superclass : #FamixValueSpecialType,
	#category : #'Famix-Value-Types'
}

{ #category : #visiting }
FamixValueJavaDate >> acceptValueVisitor: visitor forObject: object [
	"Skip visiting the attribute, it is added as a constructor argument"

	^ visitor statementBlock
		  addStatement: (visitor makeVarDeclStatement: object);
		  yourself
]

{ #category : #converting }
FamixValueJavaDate >> value: date asFASTJavaExpressionOn: visitor [
	"Add epoch time attribute as constructor argument"

	^ (visitor makeNewExpression: date)
		  addArgument: (visitor model newLongLiteral primitiveValue:
					   date value first value value asString , 'L');
		  yourself
]
