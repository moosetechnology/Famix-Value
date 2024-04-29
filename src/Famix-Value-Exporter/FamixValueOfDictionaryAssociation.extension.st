Extension { #name : #FamixValueOfDictionaryAssociation }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfDictionaryAssociation >> accept: visitor [

	^ visitor visitDictionaryAssociation: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfDictionaryAssociation >> asFASTJavaExpressionOn: visitor [

	self shouldNotImplement
]
