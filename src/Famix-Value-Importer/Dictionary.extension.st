Extension { #name : #Dictionary }

{ #category : #'*Famix-Value-Importer' }
Dictionary >> asJavaJacksonValueOn: importer [

	| typeName type |
	typeName := self removeKey: importer typeKey.
	type := importer typeInference ifNil: [ 
		        importer loadTypeNamed: typeName ].
	^ (type isUnknownType or: [ type isDictionaryType ])
		  ifTrue: [ importer importDictionary: self of: type ]
		  ifFalse: [ importer importObject: self of: type ]
]
