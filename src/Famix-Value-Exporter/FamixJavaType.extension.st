Extension { #name : #FamixJavaType }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> baseName [

	^ name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> concreteTypeName [

	^ String streamContents: [ :stream | self concreteTypeNameOn: stream ]
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> concreteTypeNameOn: stream [

	(#( 'Map' 'Set' ) includes: name)
		ifTrue: [ stream << 'Hash' ]
		ifFalse: [ 'List' = name ifTrue: [ stream << 'Array' ] ].
	stream << name
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> typeName [

	^ String streamContents: [ :stream | self typeNameOn: stream ]
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaType >> typeNameOn: stream [

	stream << name
]
