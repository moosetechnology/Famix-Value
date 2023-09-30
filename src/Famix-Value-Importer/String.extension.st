Extension { #name : #String }

{ #category : #'*Famix-Value-Importer' }
String >> asJavaJacksonValueOn: importer [

	| typeInference |
	typeInference := importer typeInference.
	^ (typeInference isNotNil and: [ typeInference name = 'Class' ])
		  ifTrue: [ importer importClassReference: self of: typeInference ]
		  ifFalse: [ importer importPrimitive: self of: 'java.lang.String' ]
]

{ #category : #'*Famix-Value-Importer' }
String >> asPharoSTONValueOn: importer [

	^ importer importPrimitive: self of: self className
]
