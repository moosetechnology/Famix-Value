"
A representation of Java date types such as `java.util.Date` or `java.sql.Timestamp`.
This family of types has a special serialization format: all attributes are transient, and only a `long` is used to measure the distance to the epoch in milliseconds.
"
Class {
	#name : 'FamixValueJavaDate',
	#superclass : 'FamixValueSpecialClass',
	#category : 'Famix-Value-Types',
	#package : 'Famix-Value-Types'
}

{ #category : 'visiting' }
FamixValueJavaDate >> acceptValueVisitor: visitor forObject: object [
	"Skip visiting the attribute, it is added as a constructor argument."

	^ visitor statementBlock
		  addStatement: (visitor makeVarDeclStatement: object);
		  yourself
]

{ #category : 'importing' }
FamixValueJavaDate >> importSpecial: rawValue on: importer [
	"The value is the distance to the epoch in milliseconds, represented with a long."

	^ importer model newOfPrimitiveType
		  value: rawValue;
		  type: (importer entityFinder findTypeNamed: 'long')
]

{ #category : 'converting' }
FamixValueJavaDate >> value: date asFASTJavaExpressionOn: visitor [
	"Add epoch time attribute as constructor argument."

	^ (visitor makeNewExpression: date)
		  addArgument: (visitor model newLongLiteral primitiveValue:
					   date value first value value asString , 'L');
		  yourself
]
