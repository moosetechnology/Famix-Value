Class {
	#name : #FASTBuilder,
	#superclass : #Object,
	#instVars : [
		'model'
	],
	#classVars : [
		'Current'
	],
	#category : #'Famix-Value-Exporter'
}

{ #category : #accessing }
FASTBuilder class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : #accessing }
FASTBuilder >> beCurrent [

	Current := self
]

{ #category : #accessing }
FASTBuilder >> model [

	^ model ifNil: [ model := FASTJavaModel new ]
]

{ #category : #accessing }
FASTBuilder >> model: aFASTModel [

	model := aFASTModel
]
