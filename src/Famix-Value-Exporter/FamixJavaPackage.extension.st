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

	^ parentPackage
		  ifNil: [ aFASTJavaModel newQualifiedTypeName name: name ]
		  ifNotNil: [
			  aFASTJavaModel newQualifiedTypeName
				  name: name;
				  namespace:
					  (parentPackage fullyQualifiedTypeNameOn: aFASTJavaModel) ]
]
