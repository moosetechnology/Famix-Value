Extension { #name : #FamixTWithParameterizedTypeUsers }

{ #category : #'*Famix-Value-Importer' }
FamixTWithParameterizedTypeUsers >> keyArgument [

	^ (arguments size = 1 or: [ 
		   arguments first name = 'String' or: [ 
			   arguments second name ~= 'String' ] ])
		  ifTrue: [ arguments first ]
		  ifFalse: [ arguments second ]
]

{ #category : #'*Famix-Value-Importer' }
FamixTWithParameterizedTypeUsers >> valueArgument [

	^ (arguments size = 1 or: [ 
		   arguments second name = 'String' or: [ 
			   arguments first name ~= 'String' ] ])
		  ifTrue: [ arguments first ]
		  ifFalse: [ arguments second ]
]
