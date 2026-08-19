Extension { #name : 'FASTJavaNewArray' }

{ #category : '*Famix-Value-Interpreter' }
FASTJavaNewArray >> staticTypeIn: methodInfo with: loader [

	^ FamixValueJavaArrayTypeInfo new
		  componentType:
			  (loader resolveType: self type in: methodInfo compilationUnit);
		  dimensions: self arguments size
]
