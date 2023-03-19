Extension { #name : #FamixValueOfAttribute }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfAttribute >> mooseNameOn: stream [

	stream << (object ifNotNil: [ object type name ] ifNil: [ '<type>' ])
	<< $. << (self attribute
		 ifNotNil: [ :attribute | attribute name ]
		 ifNil: [ '<attribute>' ]) << $=.
	value printValueOn: stream
]
