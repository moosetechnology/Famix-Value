Extension { #name : #FamixValueOfType }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> containsCollection [

	^ false
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> containsObject [

	^ false
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> isReferencedInLoop [

	| count |
	count := self referenceCount.
	^ count > 1 or: [ count = 1 and: [ self isRoot ] ]
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> isRoot [

	^ self argumentInSpan isNotNil or: [
		  self resultInSpan isNotNil or: [ self receiverInSpan isNotNil ] ]
]

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
	  + variableInClosures size
]

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfType >> varName [
	"Basic variable name of a value."

	^ self typedEntity
		  ifNotNil: [ :typedEntity | typedEntity varName ]
		  ifNil: [
			  attributeInObjects size = 1
				  ifTrue: [ attributeInObjects first attribute name ]
				  ifFalse: [ self type baseName uncapitalized ] ]
]
