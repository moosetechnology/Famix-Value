Extension { #name : #FamixTParameterizedType }

{ #category : #'*Famix-Value-Exporter' }
FamixTParameterizedType >> constructorScore [

	^ parameterizableClass constructorScore
]

{ #category : #'*Famix-Value-Exporter' }
FamixTParameterizedType >> findSetterOf: aFamixAttribute [

	^ parameterizableClass findSetterOf: aFamixAttribute
]

{ #category : #'*Famix-Value-Exporter' }
FamixTParameterizedType >> publicConstructorsWithMostImpact [

	^ parameterizableClass publicConstructorsWithMostImpact
]
