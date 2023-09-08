Extension { #name : #FamixJavaType }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> acceptValueVisitor: visitor for: object [

	^ visitor visitObjectOfRegularType: object
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> asFASTJavaTypeExpressionOn: visitor [

	^ visitor makeClassTypeExpression: self typeName
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> baseName [

	"Without type arguments, e.g. List"

	^ name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> concreteTypeName [

	"Answer the type name of the most commonly used concrete class of this type, e.g. List -> ArrayList"

	^ String streamContents: [ :stream | self concreteTypeNameOn: stream ]
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> concreteTypeNameOn: stream [

	stream nextPutAll: name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> typeName [

	"Includes type arguments, e.g. List<Map<String, Integer>>"

	^ String streamContents: [ :stream | self typeNameOn: stream ]
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> typeNameOn: stream [

	stream nextPutAll: name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> value: value asFASTJavaExpressionOn: visitor [

	"hook for types with a particular serialization format"

	^ visitor makeNewExpression: value
]
