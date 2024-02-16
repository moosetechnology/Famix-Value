Extension { #name : #FamixJavaParametricClass }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParametricClass >> concreteTypeNameOn: stream [

	stream nextPutAll: name.
	stream nextPutAll: '<>'
]
