Extension { #name : #FamixTParameterizedType }

{ #category : #'*Famix-Value-Importer' }
FamixTParameterizedType >> findAttributeNamed: attributeName [

	^ parameterizableClass findAttributeNamed: attributeName
]
