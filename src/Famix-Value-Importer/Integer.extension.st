Extension { #name : #Integer }

{ #category : #'*Famix-Value-Importer' }
Integer >> asJavaJacksonValueOn: importer [

	^ (importer typeInference isNotNil and: [ 
		   (importer isPrimitiveType: importer typeInference) not ])
		  ifTrue: [ "object reference, solved by the importer" 
			  importer getObjectFromIdentity: self ]
		  ifFalse: [ "regular int"
			  importer newValueOfPrimitiveType
				  value: self;
				  type: (importer loadTypeNamed: 'int') ]
]
