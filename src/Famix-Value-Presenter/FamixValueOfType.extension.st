Extension { #name : 'FamixValueOfType' }

{ #category : '*Famix-Value-Presenter' }
FamixValueOfType >> inspectionValue [

	<inspectorPresentationOrder: -1 title: 'Value'>
	^ FamixValuePresenter on: self
]

{ #category : '*Famix-Value-Presenter' }
FamixValueOfType >> presenterChildren [
	^ { }
]
