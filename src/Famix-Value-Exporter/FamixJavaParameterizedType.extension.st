Extension { #name : #FamixJavaParameterizedType }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizedType >> baseName [

	^ parameterizableClass name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizedType >> concreteTypeNameOn: stream [

	parameterizableClass concreteTypeNameOn: stream.
	self typeArgumentNamesOn: stream
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizedType >> typeArgumentNamesOn: stream [

	stream nextPut: $<.
	self isDictionaryType
		ifTrue: [ 
			self keyArgument typeNameOn: stream.
			stream nextPutAll: ', '.
			self valueArgument typeNameOn: stream ]
		ifFalse: [ 
			arguments
				do: [ :argument | argument typeNameOn: stream ]
				separatedBy: [ stream nextPutAll: ', ' ] ].
	stream nextPut: $>
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizedType >> typeNameOn: stream [

	stream nextPutAll: parameterizableClass name.
	self typeArgumentNamesOn: stream
]
