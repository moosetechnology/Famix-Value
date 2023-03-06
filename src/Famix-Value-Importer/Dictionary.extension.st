Extension { #name : #Dictionary }

{ #category : #'*Famix-Value-Importer' }
Dictionary >> asJavaJacksonValueOn: importer [

	| type |
	type := importer findTypeNamed: (self removeKey: importer typeKey).
	self removeKey: importer idKey ifAbsent: nil.
	^ (type isUnknownType or: [ importer isDictionary: type ])
		  ifTrue: [ (importer importDictionary: self) type: type ]
		  ifFalse: [ importer importObject: self of: type ]
]
