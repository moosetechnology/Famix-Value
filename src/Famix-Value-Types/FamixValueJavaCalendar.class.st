"
A representation of `java.util.Calendar` and its subclasses.
They are serialized with a single `long` value, presumably(?) for the `time` attribute, which is ""the currently set time for this calendar, expressed in milliseconds after January 1, 1970, 0:00:00 GMT"".
"
Class {
	#name : 'FamixValueJavaCalendar',
	#superclass : 'FamixValueSpecialClass',
	#category : 'Famix-Value-Types',
	#package : 'Famix-Value-Types'
}

{ #category : 'importing' }
FamixValueJavaCalendar >> importSpecial: rawValue on: importer [
	"No clue what the value is supposed to be, maybe the gregorianCutover? (long)"

	^ importer model newOfPrimitiveType
		  value: rawValue;
		  type: (importer entityFinder findTypeNamed: 'long')
]
