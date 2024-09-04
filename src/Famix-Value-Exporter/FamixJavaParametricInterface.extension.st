Extension { #name : 'FamixJavaParametricInterface' }

{ #category : '*Famix-Value-Exporter' }
FamixJavaParametricInterface >> concreteTypeNameOn: stream [

	(#( Map Set ) includes: name)
		ifTrue: [ stream nextPutAll: 'Hash' ]
		ifFalse: [ 'List' = name ifTrue: [ stream nextPutAll: 'Array' ] ].
	stream nextPutAll: name.
	stream nextPutAll: '<>'
]
