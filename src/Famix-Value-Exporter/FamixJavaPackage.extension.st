Extension { #name : 'FamixJavaPackage' }

{ #category : '*Famix-Value-Exporter' }
FamixJavaPackage >> fullyQualifiedNameOn: aFASTJavaModel [

	^ parentPackage
		  ifNil: [ aFASTJavaModel newQualifiedName name: name ]
		  ifNotNil: [
			  aFASTJavaModel newQualifiedName
				  name: name;
				  namespace: (parentPackage fullyQualifiedNameOn: aFASTJavaModel) ]
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaPackage >> fullyQualifiedTypeNameOn: aFASTJavaModel [

	| qualifiedName |
	qualifiedName := aFASTJavaModel newQualifiedTypeName name: name.
	^ parentPackage ifNil: [ qualifiedName ] ifNotNil: [
		  qualifiedName namespace:
			  (parentPackage fullyQualifiedTypeNameOn: aFASTJavaModel) ]
]
