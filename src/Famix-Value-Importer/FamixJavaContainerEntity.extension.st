Extension { #name : 'FamixJavaContainerEntity' }

{ #category : '*Famix-Value-Importer' }
FamixJavaContainerEntity >> mooseNameWithDots [
	"Has been deprecated, adding it for retro-compatibility (somewhat, it's complicated)."

	^ self mooseName ifNotNil: [ :mName |
		  mName copyReplaceAll: '::' with: '.' ]
]
