Extension { #name : #FamixValueOfClosure }

{ #category : #'*Famix-Value-Entities-Extensions' }
FamixValueOfClosure >> mooseNameOn: aStream [

	sourceCode
		ifNil: [ aStream nextPutAll: '<Closure>' ]
		ifNotNil: [ aStream nextPutAll: sourceCode ]
]
