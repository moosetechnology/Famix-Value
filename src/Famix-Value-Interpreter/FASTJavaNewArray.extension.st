Extension { #name : 'FASTJavaNewArray' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaNewArray >> staticTypeIn: executable with: loader [

	^ FamixValueJavaArrayTypeInfo new
		  componentType:
			  (loader resolveType: self type in: executable compilationUnit);
		  dimensions: self arguments size
]
