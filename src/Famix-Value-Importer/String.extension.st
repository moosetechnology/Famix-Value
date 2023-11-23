Extension { #name : #String }

{ #category : #'*Famix-Value-Importer' }
String >> asJavaJacksonValueOn: importer [

	| typeInference |
	typeInference := importer typeInference.
	^ (typeInference isNotNil and: [ typeInference name = 'Class' ])
		  ifTrue: [ importer importClassReference: self of: typeInference ]
		  ifFalse: [ "import regular string, escape special characters"
			  importer
				  importPrimitive: (self
						   copyWithRegex: '\\|"'
						   matchesTranslatedUsing: [ :match | match copyWithFirst: $\ ])
				  of: 'java.lang.String' ]
]

{ #category : #'*Famix-Value-Importer' }
String >> asPharoSTONValueOn: importer [

	^ importer importPrimitive: self of: self className
]

{ #category : #'*Famix-Value-Importer' }
String >> findClosing: close startingAt: startIndex [
	"Assume the opening character is given at startIndex. Find the matching closing character, taking nesting into account."

	| open nestLevel current |
	open := self at: startIndex.
	nestLevel := 1.
	startIndex + 1 to: self size do: [ :pos |
		(current := self at: pos) == close
			ifTrue: [ (nestLevel := nestLevel - 1) = 0 ifTrue: [ ^ pos ] ]
			ifFalse: [ current == open ifTrue: [ nestLevel := nestLevel + 1 ] ] ].
	^ 0
]
