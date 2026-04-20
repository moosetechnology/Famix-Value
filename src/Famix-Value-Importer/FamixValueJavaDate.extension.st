Extension { #name : 'FamixValueJavaDate' }

{ #category : '*Famix-Value-Importer' }
FamixValueJavaDate >> importSpecial: rawValue on: importer [
	"The value is the distance to the epoch in milliseconds, represented with a long."

	^ importer model newOfPrimitiveType
		  value: rawValue;
		  type: (importer entityFinder findTypeNamed: 'long')
]
