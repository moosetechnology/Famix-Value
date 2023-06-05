Extension { #name : #FamixValueOfObjectAttribute }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfObjectAttribute >> mooseNameOn: stream [

	stream << (object ifNotNil: [ object type name ] ifNil: [ '<type>' ])
	<< $. << (self attribute
		 ifNotNil: [ :attribute | attribute name ]
		 ifNil: [ '<attribute>' ]) << $=.
	value printValueOn: stream
]
