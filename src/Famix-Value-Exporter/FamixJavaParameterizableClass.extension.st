Extension { #name : #FamixJavaParameterizableClass }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizableClass >> concreteBaseNameOn: stream [

	(#( Map Set ) includes: name)
		ifTrue: [ stream nextPutAll: 'Hash' ]
		ifFalse: [ 'List' = name ifTrue: [ stream nextPutAll: 'Array' ] ].
	stream nextPutAll: name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizableClass >> concreteTypeNameOn: stream [

	self concreteBaseNameOn: stream.
	stream nextPutAll: '<>'
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizableClass >> typeArgumentNamesOn: stream [

	stream nextPut: $<.
	self parameters
		do: [ :parameter |
			stream nextPutAll: '? extends '.
			parameter typeNameOn: stream ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPut: $>
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizableClass >> typeNameOn: stream [

	self flag: #verveinej. "duplicated elements in #parameters"
	stream nextPutAll: name
	"self typeArgumentNamesOn: stream"
]
