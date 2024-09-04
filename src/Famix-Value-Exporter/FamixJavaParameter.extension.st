Extension { #name : 'FamixJavaParameter' }

{ #category : '*Famix-Value-Exporter' }
FamixJavaParameter >> allAccessedAttributesOf: aFamixJavaClass [

	aFamixJavaClass generateFastIfNotDoneAndBind. "need to bind at class level"
	^ (self fastAccesses select: [ :access |
		   (access isKindOf: FASTJavaVariableExpression) and: [
			   access name = name ] ]) flatCollectAsSet: [ :access |
		  access accessedAttributesOf: aFamixJavaClass ]
]
