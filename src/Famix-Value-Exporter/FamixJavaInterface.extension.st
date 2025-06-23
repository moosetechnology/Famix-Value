Extension { #name : 'FamixJavaInterface' }

{ #category : '*Famix-Value-Exporter' }
FamixJavaInterface >> asFASTJavaDefaultValueOn: aFASTJavaModel [

	^ aFASTJavaModel newNullLiteral
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaInterface >> withSubHierarchy [
	"Includes subinterfaces and their implementing classes"

	| result |
	result := Set new.
	self withSubclassHierarchy do: [ :interface |
		result add: interface.
		interface implementations do: [ :implementation |
			implementation implementingClass withSubclassesDo: [ :class |
				result add: class ] ] ].
	^ result asOrderedCollection
]
