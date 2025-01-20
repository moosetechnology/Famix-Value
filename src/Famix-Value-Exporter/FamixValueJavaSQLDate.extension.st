Extension { #name : 'FamixValueJavaSQLDate' }

{ #category : '*Famix-Value-Exporter' }
FamixValueJavaSQLDate >> value: date asFASTJavaExpressionOn: visitor [
	"Call java.sql.Date#valueOf(String) to recreate this date."

	^ visitor model newMethodInvocation
		  receiver: (visitor builder referType: type);
		  name: 'valueOf';
		  addArgument: (visitor model newStringLiteral primitiveValue:
					   date value first value value);
		  yourself
]
