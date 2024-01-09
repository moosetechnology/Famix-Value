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
	"TODO: deal with generics?"

	stream nextPut: $<.
	self parameters
		do: [ :parameter |
			parameter isParameterType
				ifTrue: [ stream nextPutAll: 'Object' ]
				ifFalse: [ parameter typeNameOn: stream ] ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPut: $>
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizableClass >> typeNameOn: stream [

	stream nextPutAll: name
	"type arguments of parameterizable classes can be generics, and we cannot use them without defining them"
	"self typeArgumentNamesOn: stream"
]
