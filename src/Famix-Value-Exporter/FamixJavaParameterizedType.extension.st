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

	stream << $<.
	arguments
		do: [ :argument | argument typeNameOn: stream ]
		separatedBy: [ stream << ', ' ].
	(arguments size = 1 and: [ self isDictionaryType ]) ifTrue: [ 
		stream << ', '.
		arguments first typeNameOn: stream ].
	stream << $>
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizedType >> typeNameOn: stream [

	stream << parameterizableClass name.
	self typeArgumentNamesOn: stream
]
