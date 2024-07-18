Extension { #name : #FamixValueUnknownType }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> acceptValueVisitor: visitor forObject: object [

	self error: 'Exporting an unknown type is not (yet?) supported.'
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> baseName [

	^ name
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> concreteTypeName [

	^ name
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> isParametricEntity [

	^ false
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> isPrimitiveType [

	^ false
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> methods [

	^ {  }
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> typeName [

	^ name
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> typeNameOn: stream [

	stream nextPutAll: name
]
