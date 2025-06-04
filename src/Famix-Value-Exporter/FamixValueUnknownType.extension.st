Extension { #name : 'FamixValueUnknownType' }

{ #category : '*Famix-Value-Exporter' }
FamixValueUnknownType >> acceptValueVisitor: visitor forObject: object [

	self error: 'Exporting an unknown type is not (yet?) supported.'
]

{ #category : '*Famix-Value-Exporter' }
FamixValueUnknownType >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor builder referType: self
]

{ #category : '*Famix-Value-Exporter' }
FamixValueUnknownType >> decorate: aFamixJavaType asFASTJavaTypeExpressionOn: visitor [

	^ self asFASTJavaTypeExpressionOn: visitor
]

{ #category : '*Famix-Value-Exporter' }
FamixValueUnknownType >> fullyQualifiedNameOn: aFASTJavaModel [

	^ aFASTJavaModel newQualifiedName name: name
]

{ #category : '*Famix-Value-Exporter' }
FamixValueUnknownType >> fullyQualifiedTypeNameOn: aFASTJavaModel [

	^ aFASTJavaModel newTypeName name: name
]

{ #category : '*Famix-Value-Exporter' }
FamixValueUnknownType >> needsJavaImport [

	^ ((name size = 6 or: [
		    name size = 16 and: [ name beginsWith: 'java.lang.' ] ]) and: [
		   name endsWith: 'Object' ]) not
]
