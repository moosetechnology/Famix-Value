Extension { #name : 'FamixTType' }

{ #category : '*Famix-Value-Exporter' }
FamixTType >> baseName [
	"Without type arguments, e.g. List"

	^ name
]

{ #category : '*Famix-Value-Exporter' }
FamixTType >> typeNameOn: stream [

	stream nextPutAll: name
]
