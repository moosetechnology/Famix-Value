Extension { #name : 'FamixJavaParameter' }

{ #category : '*Famix-Value-Exporter' }
FamixJavaParameter >> allAccessedAttributesOf: aFamixJavaClass [

	aFamixJavaClass generateFastIfNotDoneAndBind. "Need to bind at class level"
	^ (self fastAccesses select: [ :access |
		   access isVariableExpression and: [ access name = name ] ])
		  flatCollectAsSet: [ :access |
		  access accessedAttributesOf: aFamixJavaClass ]
]
