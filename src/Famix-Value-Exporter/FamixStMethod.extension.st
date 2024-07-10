Extension { #name : #FamixStMethod }

{ #category : #'*Famix-Value-Exporter' }
FamixStMethod >> isSetterLax [

	^ self isSetter
]

{ #category : #'*Famix-Value-Exporter' }
FamixStMethod >> varName [

	| varName |
	varName := self name asSymbol.
	varName isBinary ifTrue: [
		^ (varName flatCollect: [ :each |
			   (((Character specialCharacterNames at: each)
				     copyReplaceAll: '-'
				     with: ' ') substrings collect: #capitalized) joinUsing: '' ])
			  asSymbol uncapitalized ].

	^ (((varName copyReplaceAll: ':' with: ' ') substrings collect:
		    #capitalized) joinUsing: '') asSymbol uncapitalized
]
