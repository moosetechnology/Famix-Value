Extension { #name : #OrderedDictionary }

{ #category : #'*Famix-Value-Importer' }
OrderedDictionary >> asJavaJacksonValueOn: importer [

	| type |
	(self removeKey: importer typeKey ifAbsent: nil)
		ifNotNil: [ :typeName | type := importer loadTypeNamed: typeName ]
		ifNil: [
			(type := importer typeInference) ifNil: [
				self error: 'Cannot determine type.' ] ].
	^ (type isUnknownType or: [ type isDictionaryType ])
		  ifTrue: [ importer importDictionary: self of: type ]
		  ifFalse: [ importer importObject: self of: type ]
]
