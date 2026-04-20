Extension { #name : 'FamixValueOfObjectAttribute' }

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfObjectAttribute >> mooseNameOn: aStream [

	value printTypeOn: aStream.
	aStream << ' ' << (self attribute
		 ifNotNil: [ :attribute | attribute name ]
		 ifNil: [ '<attribute>' ]) << $=.
	value printValueOn: aStream
]

{ #category : '*Famix-Value-Entities-Extensions' }
FamixValueOfObjectAttribute >> varName [

	self attribute ifNotNil: [ :attribute | "synthetic field names (e.g. this$0) are arguably less readable (although explicit)"
		| varName |
		((varName := attribute name) includes: $$) ifFalse: [ ^ varName ] ].
	^ value varName
]
