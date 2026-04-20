Extension { #name : 'FamixTWithInheritances' }

{ #category : '*Famix-Value-Exporter' }
FamixTWithInheritances >> withSubHierarchy [
	"Returns the complete sub-hierarchy, see implementors for special cases"

	^ self withSubclassHierarchy
]
