Extension { #name : #FamixJavaParameterizedType }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizedType >> baseName [

	^ parameterizableClass name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaParameterizedType >> typeName [

	^ String streamContents: [ :stream | 
		  stream << self parameterizableClass name << $<.
		  self arguments
			  do: [ :argument | 
				  stream << (argument isParameterizedType
					   ifTrue: [ argument parameterizableClass ]
					   ifFalse: [ argument ]) name ]
			  separatedBy: [ stream << ', ' ].
		  stream << $> ]
]
