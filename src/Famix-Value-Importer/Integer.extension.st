Extension { #name : #Integer }

{ #category : #'*Famix-Value-Importer' }
Integer >> asJavaJacksonValueOn: importer [

	| typeInference |
	typeInference := importer typeInference.
	^ (typeInference isNotNil and: [
		   (importer isPrimitiveType: typeInference) not ])
		  ifTrue: [ "object reference, solved by the importer"
			  importer
				  getObjectFromIdentity: self
				  ifAbsent: [ "might be a special object with missing runtime type information"
					  importer importSpecialObject: self of: typeInference ] ]
		  ifFalse: [ importer importPrimitive: self of: 'int' ]
]
