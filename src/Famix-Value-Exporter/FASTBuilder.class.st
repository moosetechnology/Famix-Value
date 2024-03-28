Class {
	#name : #FASTBuilder,
	#superclass : #Object,
	#instVars : [
		'model'
	],
	#category : #'Famix-Value-Exporter'
}

{ #category : #accessing }
FASTBuilder >> model [

	^ model ifNil: [ model := FASTJavaModel new ]
]

{ #category : #accessing }
FASTBuilder >> model: aFASTModel [

	model := aFASTModel
]
