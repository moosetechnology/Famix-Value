Extension { #name : #FamixValueUnknownType }

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> baseName [

	^ name
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> concreteTypeName [

	^ name
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> typeName [

	^ name
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> typeNameOn: stream [

	stream nextPutAll: name
]
