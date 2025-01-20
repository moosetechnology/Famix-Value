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

{ #category : 'importing' }
FamixValueJavaDate >> importSpecial: rawValue on: importer [
	"The value is the distance to the epoch in milliseconds, represented with a long."

	^ importer model newOfPrimitiveType
		  value: rawValue;
		  type: (importer entityFinder findTypeNamed: 'long')
]
