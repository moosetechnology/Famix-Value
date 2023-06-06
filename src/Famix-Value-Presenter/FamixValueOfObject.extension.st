Extension { #name : #FamixValueOfObject }

{ #category : #'*Famix-Value-Presenter' }
FamixValueOfObject >> presenterChildren [

	^ value collect: #value
]
