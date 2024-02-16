Extension { #name : #FamixTParametricEntity }

{ #category : #'*Famix-Value-Exporter' }
FamixTParametricEntity >> keyType [

	^ self allTypeParameters first
]

{ #category : #'*Famix-Value-Exporter' }
FamixTParametricEntity >> typeNameOn: stream [

	stream nextPutAll: self name.
	self typeParameterNamesOn: stream
]

{ #category : #'*Famix-Value-Exporter' }
FamixTParametricEntity >> typeParameterNamesOn: stream [

	stream nextPut: $<.
	self isDictionaryType
		ifTrue: [
			self keyType typeNameOn: stream.
			stream nextPutAll: ', '.
			self valueType typeNameOn: stream ]
		ifFalse: [
			self allTypeParameters
				do: [ :parameter |
					parameter isParameterType
						ifTrue: [ stream nextPutAll: 'Object' ]
						ifFalse: [ parameter typeNameOn: stream ] ]
				separatedBy: [ stream nextPutAll: ', ' ] ].
	stream nextPut: $>
]

{ #category : #'*Famix-Value-Exporter' }
FamixTParametricEntity >> valueType [

	| typeParameters |
	^ (typeParameters := self allTypeParameters) size = 1
		  ifTrue: [ typeParameters first ]
		  ifFalse: [ typeParameters second ]
]
