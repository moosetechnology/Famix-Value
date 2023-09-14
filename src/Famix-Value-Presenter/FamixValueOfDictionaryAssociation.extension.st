Extension { #name : #FamixValueOfDictionaryAssociation }

{ #category : #'*Famix-Value-Presenter' }
FamixValueOfDictionaryAssociation >> inspectionValue [

	<inspectorPresentationOrder: -1 title: 'Value'>
	^ FamixValuePresenter on: self
]

{ #category : #'*Famix-Value-Presenter' }
FamixValueOfDictionaryAssociation >> presenterChildren [

	^ { key. value }
]
