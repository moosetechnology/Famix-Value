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
FamixJavaParameterizableClass >> typeNameOn: stream [

	stream nextPutAll: name.
	stream nextPutAll: '<>'
]
