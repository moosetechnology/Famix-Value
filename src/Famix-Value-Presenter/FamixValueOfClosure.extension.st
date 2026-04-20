Extension { #name : 'FamixValueOfClosure' }

{ #category : '*Famix-Value-Presenter' }
FamixValueOfClosure >> presenterChildren [

	^ variables collect: #value
]
