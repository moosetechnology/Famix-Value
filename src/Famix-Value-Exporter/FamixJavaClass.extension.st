Extension { #name : #FamixJavaClass }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaClass >> findSetterFor: aFamixJavaAttribute [

	| attributeName attributeNameSize setterName |
	attributeName := aFamixJavaAttribute name onlyLetters asLowercase.
	attributeNameSize := attributeName size.
	^ self allMethods detect: [ :method | 
		  method isSetter and: [ 
			  setterName := (method name allButFirst: 3) onlyLetters.
			  setterName size = attributeNameSize and: [ 
				  setterName asLowercase = attributeName ] ] ]
]
