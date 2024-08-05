Extension { #name : #FamixValueOfClosure }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfClosure >> accept: visitor [

	^ visitor visitClosure: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfClosure >> asFASTJavaExpressionOn: visitor [

	self shouldBeImplemented
]
