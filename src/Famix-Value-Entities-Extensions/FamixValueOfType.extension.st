Extension { #name : #FamixValueOfType }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> mooseNameOn: aStream [

	aStream
	<< (self type ifNotNil: [ :type | type name ] ifNil: [ '<type>' ])
	<< $  << (self typedEntity
		 ifNotNil: [ :typedEntity | typedEntity name ]
		 ifNil: [ '<typedEntity>' ]) << $=.
	self printValueOn: aStream
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> printValueOn: aStream [

	self value printOn: aStream
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> value [

	self subclassResponsibility
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> value: anObject [

	^ self subclassResponsibility
]
