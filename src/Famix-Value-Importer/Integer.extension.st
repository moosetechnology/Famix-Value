Extension { #name : #Integer }

{ #category : #'*Famix-Value-Importer' }
Integer >> asJavaJacksonValueOn: importer [

	^ importer typeInference
		  ifNotNil: [ "object reference, will be solved by the importer" 
		  self ]
		  ifNil: [ "regular int"
			  importer newValueOfPrimitiveType
				  value: self;
				  type: (importer loadTypeNamed: 'int') ]
]
