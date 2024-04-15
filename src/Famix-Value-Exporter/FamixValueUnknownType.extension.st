Extension { #name : #FamixValueUnknownType }

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor builder referType: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueUnknownType >> needsJavaImport [

	^ ((name size = 6 or: [
		    name size = 16 and: [ name beginsWith: 'java.lang.' ] ]) and: [
		   name endsWith: 'Object' ]) not
]
