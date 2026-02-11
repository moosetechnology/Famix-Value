Extension { #name : 'FamixValueSpecialClass' }

{ #category : '*Famix-Value-Importer' }
FamixValueSpecialClass >> import: rawValue on: importer [
	"Wrap the value as a field in an object."

	^ importer model newOfObject
		  type: self;
		  addValue: (importer model newOfObjectAttribute value:
					   (self importSpecial: rawValue on: importer));
		  yourself
]

{ #category : '*Famix-Value-Importer' }
FamixValueSpecialClass >> importSpecial: rawValue on: importer [
	"By default, let the value import itself.
	Redefine this method to implement specific import logic."

	^ rawValue asJavaJacksonValueOn: importer
]
