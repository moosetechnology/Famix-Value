Extension { #name : #Dictionary }

{ #category : #'*Famix-Value-Importer' }
Dictionary >> asJavaJacksonValueOn: importer [

	| typeName type |
	typeName := self removeKey: importer typeKey.
	type := importer loadTypeNamed: typeName.
	^ (type isUnknownType or: [ type isDictionaryType ])
		  ifTrue: [ importer importDictionary: self of: type ]
		  ifFalse: [ importer importObject: self of: type ]
]

{ #category : #'*Famix-Value-Importer' }
Dictionary >> asPharoSTONValueOn: importer [

	^ (self removeKey: STON classNameKey ifAbsent: nil)
		  ifNotNil: [ :className | "object of an unloaded class" 
			  importer
				  importObject: self
				  of: (importer loadTypeNamed: className) ]
		  ifNil: [ "species of dictionary"
			  importer
				  importDictionary: self
				  of: (importer loadTypeNamed: self className) ]
]
