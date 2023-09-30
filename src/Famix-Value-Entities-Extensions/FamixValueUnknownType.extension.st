Extension { #name : #FamixValueUnknownType }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> baseName [

	^ name
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> concreteTypeName [

	^ name
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> isParameterizedType [

	^ false
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> isPrimitiveType [

	^ false
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> typeName [

	^ name
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueUnknownType >> typeNameOn: stream [

	stream nextPutAll: name
]
