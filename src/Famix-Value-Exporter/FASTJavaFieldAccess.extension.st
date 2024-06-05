Extension { #name : #FASTJavaFieldAccess }

{ #category : #'*Famix-Value-Exporter' }
FASTJavaFieldAccess >> accessedAttributeName [

	^ fieldName
]

{ #category : #'*Famix-Value-Exporter' }
FASTJavaFieldAccess >> accessedAttributesOf: aFamixJavaClass [
	"TODO: ensure 'this' is of the given class..."

	self receiver name = 'this' ifFalse: [ ^ {  } ].
	aFamixJavaClass attributes
		detect: [ :attribute | attribute name = self fieldName ]
		ifFound: [ :attribute | ^ { attribute } ].
	^ {  }
]
