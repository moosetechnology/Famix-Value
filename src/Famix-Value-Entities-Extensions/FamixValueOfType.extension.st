Extension { #name : #FamixValueOfType }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> mooseNameOn: aStream [

	self printTypeOn: aStream.
	self typedEntity ifNotNil: [ :typedEntity |
		aStream << $  << typedEntity name ].
	aStream nextPut: $=.
	self printValueOn: aStream
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> printTypeOn: aStream [

	self type
		ifNotNil: [ :type |
			type name
				ifNotNil: [ type typeNameOn: aStream ]
				ifNil: [ aStream nextPutAll: '<unnamedType>' ] ]
		ifNil: [ aStream nextPutAll: '<type>' ]
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> printValueOn: aStream [

	self value printOn: aStream
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> referenceCount [

	^ attributeInObjects size + elementInCollections size
	  + keyInDictionaries size + valueInDictionaries size
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> value [

	self subclassResponsibility
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> value: anObject [

	self subclassResponsibility
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> varName [
	"Basic variable name of a value."

	^ self typedEntity
		  ifNotNil: [ :typedEntity | typedEntity name ]
		  ifNil: [
			  attributeInObjects size = 1
				  ifTrue: [ attributeInObjects first attribute name ]
				  ifFalse: [ self type baseName uncapitalized ] ]
]
