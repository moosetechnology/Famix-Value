Extension { #name : 'FamixValueJavaSQLDate' }

{ #category : '*Famix-Value-Importer' }
FamixValueJavaSQLDate >> importSpecial: rawValue on: importer [
	"The value is the string representation in 'yyyy-mm-dd' format."

	^ importer model newOfPrimitiveType
		  value: rawValue;
		  type: (importer entityFinder findTypeNamed: 'String')
]
