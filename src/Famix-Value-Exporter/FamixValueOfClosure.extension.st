Extension { #name : #FamixValueOfClosure }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfClosure >> accept: visitor [

	^ visitor visitClosure: self
]
