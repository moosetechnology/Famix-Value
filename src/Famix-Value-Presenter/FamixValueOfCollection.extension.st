Extension { #name : 'FamixValueOfCollection' }

{ #category : '*Famix-Value-Presenter' }
FamixValueOfCollection >> presenterChildren [

	^ value collect: #value
]
