Extension { #name : #FamixTClass }

{ #category : #'*Famix-Value-Exporter' }
FamixTClass >> findSetterOf: aFamixJavaAttribute [

	^ self allMethods
		  detect: [ :method | 
			  method isSetter and: [ 
				  method accesses anySatisfy: [ :access | 
					  access variable = aFamixJavaAttribute ] ] ]
		  ifNone: nil
]
