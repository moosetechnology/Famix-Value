"
A representation of the `java.sql.Date` type which is serialized using a String representation.
"
Class {
	#name : 'FamixValueJavaSQLDate',
	#superclass : 'FamixValueJavaDate',
	#category : 'Famix-Value-Types',
	#package : 'Famix-Value-Types'
}

{ #category : 'importing' }
FamixValueJavaSQLDate >> importSpecial: rawValue on: importer [
	"The value is the string representation in 'yyyy-mm-dd' format."

	^ importer model newOfPrimitiveType
		  value: rawValue;
		  type: (importer entityFinder findTypeNamed: 'String')
]
