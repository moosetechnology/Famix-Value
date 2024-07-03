"
I am a helper for the `FamixValue2ASTVisitor` hierarchy of classes to build AST.
"
Class {
	#name : #FASTBuilder,
	#superclass : #Object,
	#instVars : [
		'model'
	],
	#category : #'Famix-Value-Exporter-Helpers'
}

{ #category : #testing }
FASTBuilder class >> isAbstract [

	^ self == FASTBuilder
]

{ #category : #accessing }
FASTBuilder >> model [

	^ model ifNil: [ model := FASTJavaModel new ]
]

{ #category : #accessing }
FASTBuilder >> model: aFASTModel [

	model := aFASTModel
]
