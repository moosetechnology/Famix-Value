Extension { #name : 'FamixJavaType' }

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> acceptValueVisitor: visitor forCollection: collection [

	^ visitor visitCollectionOfRegularType: collection
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> acceptValueVisitor: visitor forObject: object [

	^ self isStub
		  ifTrue: [ visitor visitObjectStub: object ]
		  ifFalse: [ visitor visitObjectOfRegularType: object ]
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor builder referType: self
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> concreteTypeName [
	"Answer the type name of the most commonly used concrete class of this type, e.g. List -> ArrayList"

	^ String streamContents: [ :stream | self concreteTypeNameOn: stream ]
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> concreteTypeNameOn: stream [

	stream nextPutAll: name
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> decorate: aFamixJavaType asFASTJavaTypeExpressionOn: visitor [
	"This method allows for more control by having access to both the static (argument) and dynamic (self) types of a value.
	The default behavior handles when the static type is a parameter type, then it uses the dynamic type.
	See Famix-Value-Types for special cases."

	^ aFamixJavaType isParameterType
		  ifTrue: [ self asFASTJavaTypeExpressionOn: visitor ]
		  ifFalse: [ aFamixJavaType asFASTJavaTypeExpressionOn: visitor ]
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> fullyQualifiedNameOn: aFASTJavaModel [

	^ typeContainer
		  ifNil: [ aFASTJavaModel newQualifiedName name: name ]
		  ifNotNil: [
			  aFASTJavaModel newQualifiedName
				  name: name;
				  namespace: (typeContainer fullyQualifiedNameOn: aFASTJavaModel) ]
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> fullyQualifiedTypeNameOn: aFASTJavaModel [

	^ typeContainer
		  ifNil: [ aFASTJavaModel newQualifiedTypeName name: name ]
		  ifNotNil: [
			  aFASTJavaModel newQualifiedTypeName
				  name: name;
				  namespace:
					  (typeContainer fullyQualifiedTypeNameOn: aFASTJavaModel) ]
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> needsJavaImport [

	^ typeContainer mooseName ~= 'java::lang'
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> typeName [
	"Includes type arguments, e.g. List<Map<String, Integer>>"

	^ String streamContents: [ :stream | self typeNameOn: stream ]
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaType >> value: value asFASTJavaExpressionOn: visitor [
	"hook for types with a particular serialization format"

	^ visitor makeNewExpression: value
]
