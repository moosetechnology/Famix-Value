Extension { #name : #Dictionary }

{ #category : #'*Famix-Value-Importer' }
Dictionary >> asJavaJacksonValueOn: importer [

	| type |
	type := importer loadTypeNamed: (self removeKey: importer typeKey).
	self removeKey: importer idKey ifAbsent: nil.
	^ (type isUnknownType or: [ type isDictionaryType ])
		  ifTrue: [ importer importDictionary: self of: type ]
		  ifFalse: [ importer importObject: self of: type ]
]
