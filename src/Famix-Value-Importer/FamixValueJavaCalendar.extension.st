Extension { #name : 'FamixValueJavaCalendar' }

{ #category : '*Famix-Value-Importer' }
FamixValueJavaCalendar >> importSpecial: rawValue on: importer [
	"No clue what the value is supposed to be, maybe the gregorianCutover? (long)"

	^ importer model newOfPrimitiveType
		  value: rawValue;
		  type: (importer entityFinder findTypeNamed: 'long')
]
