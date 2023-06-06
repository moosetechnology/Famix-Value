Class {
	#name : #FamixValuePresenter,
	#superclass : #SpPresenterWithModel,
	#instVars : [
		'tree',
		'label',
		'activationBlock'
	],
	#category : #'Famix-Value-Presenter'
}

{ #category : #api }
FamixValuePresenter >> activateOnSingleClick [
	tree activateOnSingleClick
]

{ #category : #initialization }
FamixValuePresenter >> initialize [
	super initialize.
	activationBlock := [ :val | ]
]

{ #category : #initialization }
FamixValuePresenter >> initializePresenters [

	tree := SpTreePresenter new.
	tree children: [ :el | el presenterChildren ].
	tree roots: { self model }.
	tree display: [ :node | 
		String streamContents: [ :stream | node mooseNameOn: stream ] ].
	label := SpLabelPresenter new.
	label label:
		(String streamContents: [ :stream | self model printOn: stream ]).
	self layout: (SpBoxLayout newTopToBottom
			 add: label expand: false fill: false;
			 add: tree expand: true fill: true;
			 yourself).
	tree whenActivatedDo: [ :selection | 
		activationBlock value: selection ]
]

{ #category : #initialization }
FamixValuePresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Value viewer';
		initialExtent: 450 @ 200
]

{ #category : #initialization }
FamixValuePresenter >> outputActivationPort [
	^ SpActivationPort newPresenter: self
]

{ #category : #enumerating }
FamixValuePresenter >> whenActivatedDo: aBlock [
	activationBlock := aBlock
]
