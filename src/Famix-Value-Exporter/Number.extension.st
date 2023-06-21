Extension { #name : #Number }

{ #category : #'*Famix-Value-Exporter' }
Number >> asFASTJavaExpressionOn: visitor of: type [

	^ (self asFASTJavaLiteralOn: visitor model of: type) primitiveValue:
		  self asString
]

{ #category : #'*Famix-Value-Exporter' }
Number >> asFASTJavaLiteralOn: aFASTJavaModel of: type [

	self subclassResponsibility
]
