Extension { #name : #FamixStClass }

{ #category : #'*Famix-Value-Exporter' }
FamixStClass >> findSetterFor: aFamixStAttribute [

	| attributeName |
	attributeName := aFamixStAttribute name.
	^ self allMethods
		  detect: [ :method | 
			  method name endsWithAColon and: [ 
				  method name allButLast = attributeName ] ]
		  ifNone: nil
]
